package App::Voter::Controller::REST::Contest;
use base qw|Mojolicious::Controller|;

=head

A entidade `Contest` possui os seguintes atributos:

* `slug` [type: string, mandatory: true, min-size: 3, max-size: 20] **ID field**
* `name` [type: string, mandatory: true, min-size: 3, max-size: 10]
* `description` [type: string, mandatory: false, min-size: 0, max-size: 255]
* `start_date` [type: date, mandatory: true]
* `end_date` [type: date, mandatory: true]

Espera-se as seguintes ações:

- `GET /contests` - obtém a lista de votações
- `POST /contests` - cria um `Contest`

*Regras para esta rota*

- `start_date` precisa ser menor do que `end_date`
- `start_date` e `end_date` no formato [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601)

=cut

sub get {
    my $self = shift;
    $self->respond_to(
        json => sub {
            my $self = shift;
            $self->render(json => $self->voter->contest->list);
        }
    );
}

sub post {
    my $self = shift;
    $self->respond_to(
        json => sub {
            my $self = shift;
            my $item = $self->voter->contest->add($self->tx->req->json);
            $self->render(json => $item->as_hash) and return 0
                if !$item->has_errors;
            $self->render(json => {errors => $item->_errors}, status => 412);
        }
    );
}

1;
