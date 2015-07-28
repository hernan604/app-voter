package Voter::DB::Token;
use Moo;

has related_contest => ( is => 'rw' );
has app             => ( is => 'rw' );
has contest_tokens_index => (
    is      => 'lazy',
    default => sub { join "_", shift->related_contest->slug . 'tokens' }
);

sub create {
    my $self = shift;
    my $token = join ":", $self->related_contest->slug, rand;
    $self->app->redis->sadd( $self->contest_tokens_index, $token );
    $token;
}

sub votes {
    my $self  = shift;
    my $token = shift;
    $self->app->redis->get($token);
}

sub exists {
    my $self  = shift;
    my $token = shift;
    $self->app->redis->sismember( $self->contest_tokens_index, $token );
}

1;
