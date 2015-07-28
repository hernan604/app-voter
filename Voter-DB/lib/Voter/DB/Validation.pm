package Voter::DB::Validation;
use Moo;
with qw|Voter::DB::Helper|;

has app => (is => 'rw');

sub validate_contest {
    my $self = shift;
    my $item = shift;
    my @errors = ();

    push @errors, "slug is required" if !$item->{slug};
    push @errors, "invalid caracters in slug"
        if $item->{slug} !~ m#^(([a-z0-9]|-)+)$#g;
    push @errors, "slug length must be 3-10"
        if length $item->{slug} < 3 || length $item->{slug} > 20;
    
    push @errors, "name is required" if !$item->{name};
    push @errors, "name length 3-10"
        if length $item->{name} < 3 || length $item->{name} > 10;
   
    push @errors, "description is optional with length 0-255"
        if ($item->{description} && length $item->{description} > 255);
  
    push @errors, "start_date is required" if !$item->{start_date};
    push @errors, "start_date format is YYYY-MM-DDTHH:MM:SSZ"
        if $item->{start_date} !~ m#^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$#;
 
    push @errors, "end_date is required" if !$item->{end_date};
    push @errors, "end_date format is YYYY-MM-DDTHH:MM:SSZ"
        if $item->{end_date} !~ m#^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$#;
    push @errors, "start_date < end_date"
        if $self->date_to_int($item->{start_date})
        > $self->date_to_int($item->{end_date})
        || $self->date_to_int($item->{start_date})
        == $self->date_to_int($item->{end_date});
    \@errors;
}

sub validate_candidate {
    my $self   = shift;
    my $item   = shift;
    my @errors = ();

#   push @errors, "id is required"     if !$item->{id};
#   push @errors, "id must be integer" if $item->{id} !~ m#^\d+$#g;

    push @errors, "name is required" if !$item->{name};
    push @errors, "name must have length 3-10"
        if length $item->{name} < 3 || length $item->{name} > 10;

    push @errors, "avatar is optional with length 0-255"
        if ($item->{avatar} && length $item->{avatar} > 255);
    \@errors;
}

1;
