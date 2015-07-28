package App::Voter::Controller::REST::Candidate;
use base qw|Mojolicious::Controller|;

=head 

A entidade `Candidate` possui os seguintes atributos:

* `id` [type: integer, mandatory: true] **ID field**
* `name` [type: string, mandatory: true, min-size: 3, max-size: 10]
* `avatar` [type: string, mandatory: false, min-size: 0, max-size: 255]

Espera-se as seguintes ações:

- `GET /contest/:contest_slug/candidates` - obtém a lista de candidatos de dado `Contest`
- `POST /contest/:contest_slug/candidates` - cria um `Candidate` para um `Contest`

* * *
=cut 

sub get {
    my $self = shift;
    $self->respond_to(
        json => sub {
            my $self = shift;
            my $contest
                = $self->voter->contest->find($self->param('contest_slug'));
            if ($contest) {
                my $candidates
                    = [map { $contest->candidate->find($_)->as_hash }
                        @{$contest->candidate->list}];
                $self->render(json => $candidates) and return 0;
            }
            $self->render(
                json   => {errors => ['contest not found']},
                status => 400
            );
        }
    );
}

sub post {
    my $self = shift;
    $self->respond_to(
        json => sub {
            my $self          = shift;
            my $new_candidate = $self->tx->req->json;
            my $contest
                = $self->voter->contest->find($self->param('contest_slug'));
            $self->render(json => $user) and return 0
                if $contest
                and my $user = $contest->candidate->add($new_candidate);
            $self->render(json=>{errors=>['contest not found']}, status => 400);
        }
    );
}

1;
