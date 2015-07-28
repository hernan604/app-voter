package Voter::DB;
use utf8;
use Voter::DB::Contest;
use Moo;
use Authen::OATH;
use Voter::DB::Validation;

has redis => (is => 'rw');
has token_interval => (is => 'rw', default => sub { 60 * 10 })
    ;    #10min default
has oath => (
    is      => 'lazy',
    default => sub {
        Authen::OATH->new(timestep => shift->token_interval);
    }
);

has contest => (
    is      => 'rw',
    default => sub {
        my $self = shift;
        Voter::DB::Contest->new(app => $self);
    }
);

has validation => (
    is      => 'rw',
    default => sub {
        my $self = shift;
        Voter::DB::Validation->new(app => $self);
    }
);

sub to_slug {
    my $self = shift;
    my $str  = lc shift;
    $str
        =~ tr#àáâãäçèéêëìíîïñòóôõöùúûüýÿÀÁÂÃÄÇÈÉÊËÌÍÎÏÑÒÓÔÕÖÙÚÛÜÝ#aaaaaceeeeiiiinooooouuuuyyAAAAACEEEEIIIINOOOOOUUUUY#;
    $str =~ s#\s{2,}# #g;
    $str =~ s#([^a-z0-9]+)#-#gi;
    $str =~ s#-{2,}$#-#g;
    $str =~ s#^-|-$##g;
    $str;
}

1;
