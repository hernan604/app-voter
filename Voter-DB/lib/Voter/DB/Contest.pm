package Voter::DB::Contest;
use Moo;
use Voter::DB::Candidate;
use Voter::DB::Token;
with qw|Voter::DB::Helper|;
my $fields = [
    qw|
        slug
        name
        description
        start_date
        end_date
        |
];
has app => (is => 'rw');
has index_key => (is => 'rw', default => sub { 'contests' });
has fields => (
    is      => 'rw',
    default => sub {
        $fields;
    }
);

has $fields => (is => 'rw');

has candidate => (
    is      => 'lazy',
    default => sub {
        my $self = shift;
        return undef if !$self->slug;
        Voter::DB::Candidate->new(
            app             => $self->app,
            related_contest => $self
        );
    }
);

has token => (
    is      => 'lazy',
    default => sub {
        my $self = shift;
        Voter::DB::Token->new(app => $self->app, related_contest => $self);
    }
);

has inflate_fields => (is => 'rw', default => sub { [qw|app|] });
has _errors => ( is => 'rw', default => sub { [] } );

sub add {
    my $self    = shift;
    my $contest = shift;
    my $errors = $self->_has_errors( $contest );
    return $self->inflate({_errors => $errors}) if scalar @{$errors};
    my $slug    = $contest->{slug};
    if ($self->app->redis->sadd($self->index_key, $slug)) {
        $self->app->redis->hmset($slug => %{$contest});
        return $self->inflate($contest);
    }
    return $self->inflate({_errors=>['contest already in db']});;
}

sub list {
    my $self = shift;
    $self->app->redis->smembers($self->index_key) || [];
}

sub del {
    my $self = shift;
    my $slug = shift;
    $self->app->redis->del($slug) and return 1
        if $self->app->redis->srem($self->index_key, $slug);
    return 0;
}

sub find {
    my $self = shift;
    my $slug = shift;
    return undef if !$self->app->redis->exists($slug);
    my @fields = @{$self->fields};
    my $i      = 0;
    $self->inflate({
            map { $fields[$i++] => $_ }
                @{$self->app->redis->hmget($slug, @fields)}
        }
    );
}

sub is_active {
    my $self       = shift;
    my $start_date = $self->date_to_int($self->start_date);
    my $end_date   = $self->date_to_int($self->end_date);
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)
        = localtime(time);
    my $now
        = ($year + 1900)
        . $self->leadzero($mon + 1)
        . $self->leadzero($mday)
        . $self->leadzero($hour)
        . $self->leadzero($min)
        . $self->leadzero($sec);

    $now >= $start_date and $now <= $end_date ? 1 : 0;
}

sub _has_errors {
    my $self = shift;
    my $item = shift;
    return $self->app->validation->validate_contest( $item );
}

1;
