package App::Voter;
use base qw|Mojolicious|;

sub startup {
    my $self = shift;
    $self->load_config;
    $self->init_routes;
    $self->load_helpers;
}

sub load_config {
    my $self = shift;
    my $file = $ENV{APP_VOTER_CONFIG};
    my $config = $self->plugin("Config" => {file => $ENV{APP_VOTER_CONFIG}});
    do { $self->helper($_ => $config->{$_}) }
        for keys %{$config};
}

sub init_routes {
    my $self = shift;
    $self->load_route_contest;
    $self->load_route_candidade;
    $self->load_route_vote;
    $self->load_route_token;
}

sub load_route_contest {
    my $self = shift;
    my $r    = $self->routes;
    $r->get('/contests')
        ->to(controller => 'REST::Contest', action => 'get');
    $r->post('/contests')
        ->to(controller => 'REST::Contest', action => 'post');
}

sub load_route_token {
    my $self = shift;
    my $r    = $self->routes;
    $r->post('/contests/:contest_slug/token/create')
        ->to( controller => 'REST::Token', action => 'post' );
}

sub load_route_candidade {
    my $self = shift;
    my $r    = $self->routes;
    $r->get('/contests/:contest_slug/candidates')
        ->to(controller => 'REST::Candidate', action => 'get');
    $r->post('/contests/:contest_slug/candidates')
        ->to(controller => 'REST::Candidate', action => 'post');
}

sub load_route_vote {
    my $self = shift;
    my $r    = $self->routes;
    $r->get('/votes/:contest_slug')
        ->to(controller => 'REST::Vote', action => 'get');
    $r->get('/votes/:contest_slug/:id_candidate')
        ->to(controller => 'REST::Vote', action => 'get_candidate');
    $r->post('/votes/:contest_slug/:id_candidate')
        ->to(controller => 'REST::Vote', action => 'post');
}

sub load_helpers {
    my $self = shift;
}

1;
