package Voter::DB::Helper;
use Moo::Role;

sub as_hash {
    my $self = shift;
    return {map { $_ => $self->$_ } @{$self->fields}};
}

sub inflate {
    my $self           = shift;
    my $object         = shift;
    my @default_values = map { $_, $self->$_ } @{$self->inflate_fields};
    my $new            = $self->new(@default_values);
    $new->$_($object->{$_}) for @{$self->fields},'_errors';
    $new;
}

sub date_to_int {
    my $self = shift;
    join '',
        map { $_ }
        (shift =~ m#(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})#);

}

sub leadzero {
    my $self = shift;
    sprintf("%02d",shift);
}

sub has_errors {
    my $self = shift;
    defined $self->_errors and scalar @{$self->_errors} ? 1 : 0;
}

1;
