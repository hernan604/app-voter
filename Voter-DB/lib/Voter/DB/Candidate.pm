package Voter::DB::Candidate;
use Moo;
with qw|Voter::DB::Helper|;

my $fields = [qw|id name avatar votes|];
has related_contest => ( is => 'rw' );
has app             => ( is => 'rw' );
has $fields         => ( is => 'rw' );
has fields          => ( is => 'rw', default => sub { $fields } );
has index_key => (
    is      => 'lazy',
    default => sub { join "_", shift->related_contest->slug, "candidates" }
);
has pk_key => (
    is => 'lazy',
    default =>
      sub { join "", shift->related_contest->slug, 'candidate_id_counter' }
);
has inflate_fields =>
  ( is => 'rw', default => sub { [qw|app related_contest|] } );
has _errors => ( is => 'rw', default => sub { [] } );

sub _has_errors {
    my $self = shift;
    my $item = shift;
    return $self->app->validation->validate_candidate( $item );
}

sub add {
    my $self      = shift;
    my $candidate = shift;
    my $errors = $self->_has_errors( $candidate );
    return $self->inflate({_errors => $errors}) if scalar @{$errors};
    my $id        = $self->app->redis->incr( $self->pk_key );
    do {
        my $pk = join ":", $self->index_key, $id;
        $candidate->{votes} = 0;
        $candidate->{id}    = $id;
        $self->app->redis->hmset( $pk => %{$candidate} );
        return $self->inflate($candidate);
    } if ( $self->app->redis->sadd( $self->index_key, $id ) );
    return $self->inflate({errors => ['candidate already in db'] });
}

sub del {
    my $self = shift;
    my $slug = shift;
    $self->app->redis->del($slug) and return 1
      if $self->app->redis->srem( $self->index_key, $slug );
    return 0;
}

sub list {
    my $self = shift;
    $self->app->redis->smembers( $self->index_key ) || [];
}

sub find {
    my $self = shift;
    my $id   = shift;
    my $pk   = join ":", $self->index_key, $id;
    return undef if !$self->app->redis->exists($pk);
    my @fields = @{ $self->fields };
    my $i      = 0;
    $self->inflate(
        {
            map { $fields[ $i++ ] => $_ }
              @{ $self->app->redis->hmget( $pk, @fields ) }
        }
    );
}

sub vote {
    my $self        = shift;
    my $token       = shift;
    return 0 if !$self->related_contest->is_active;
    my $current_pin = $self->app->oath->totp($token);  #auto changes every 10min
    my $vote_count_per_10_min_pin = join ":", $token, $current_pin;
    my $pk = join ":", $self->index_key, $self->id;

    my $token_still_valid = $self->related_contest->token->exists($token)
      && (!$self->app->redis->get($vote_count_per_10_min_pin)
        || $self->app->redis->get($vote_count_per_10_min_pin) < 5 );
    $self->app->redis->incr($vote_count_per_10_min_pin)
      and $self->app->redis->hincrby( $pk, 'votes', 1 )
      and return 1
      if $token_still_valid;
    return 0;
}

1;
