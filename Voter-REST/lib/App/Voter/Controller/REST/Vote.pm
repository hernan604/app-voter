package App::Voter::Controller::REST::Vote;
use base qw|Mojolicious::Controller|;

=head

A entidade `Vote` possui o seguinte atributo:

* `result` [type: int, mandatory: true]

Espera-se as seguintes ações:

- `GET /votes/:contest_slug` - obtém a votação geral
- `GET /votes/:contest_slug/:id_candidate` - obtém a votação por candidato
- `POST /votes/:contest_slug/:id_candidate` - vota no `Candidate` para um `Contest`, se trata de um post sem parametros e com um token no header `user-token`.

*Regras para esta rota*

- Deverá permitir apenas 5 votos a cada 10 minutos para um token
- Não deverá permitir votar em um candidato passando outro evento (`Contest`)

=cut

sub get {
    my $self = shift;
    $self->respond_to(
        json => sub {
            my $self          = shift;
            my $contest       = $self->find_contest || return 0;
            my @candidate_ids = @{$contest->candidate->list};
            my $result
                = [map { $contest->candidate->find($_)->as_hash } @candidate_ids];
            $self->render(json => $result);
        }
    );
}

sub find_contest {
    my $self         = shift;
    my $contest_slug = $self->param('contest_slug');
    my $contest      = $self->voter->contest->find($contest_slug);
    $self->render(
        json   => {errors => ['contest_slug not found']},
        status => 400
        )
        and return 0
        if !$contest;
    $contest;
}

sub find_candidate {
    my $self      = shift;
    my $contest   = $self->find_contest || return 0;
    my $candidate = $contest->candidate->find($self->param('id_candidate'));
    $self->render(
        json   => {errros => ['candidate not found']},
        status => 400
        )
        and return 0
        if !$candidate;
    $candidate;
}

sub get_candidate {
    my $self = shift;
    $self->respond_to(
        json => sub {
            my $self = shift;
            my $candidate = $self->find_candidate || return 0;
            $self->render(json => $candidate->as_hash);
        }
    );
}

sub post {
    my $self = shift;
    $self->respond_to(
        json => sub {
            my $self = shift;
            $self->render(
                json   => {errors => ['user-token is required in header']},
                status => 400
                )
                and return 0
                if !$self->tx->req->headers->header('user-token');
            my $candidate = $self->find_candidate || return 0;
            my $token = $self->tx->req->headers->header('user-token');
            $self->render(json => {result => $candidate->as_hash->{votes}})
                and return 0
                if $candidate->vote($token);
            $self->render(
                json   => {errors => ['cant vote with this token']},
                status => 400
            );
        }
    );
}

1;
