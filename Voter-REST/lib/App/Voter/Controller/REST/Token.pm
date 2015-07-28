package App::Voter::Controller::REST::Token;
use base qw|Mojolicious::Controller|;

sub post {
    my $self = shift;
    $self->respond_to(
        json => sub {
            my $self    = shift;
            my $contest = $self->voter->contest->find($self->param('contest_slug'));
            $self->render(json => {token => $contest->token->create})
                and return 0
                if $contest;
            $self->render(
                json   => {errors => 'contest not found'},
                status => 403
            );
        }
    );
}

1;
