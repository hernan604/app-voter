use Test::More;
use Test::Mojo;
use DDP;
use DateTime;
use DateTime::Duration;

`redis-cli -c "flushall"`;

my $duration1 = DateTime::Duration->new(seconds => 10);
my $t = Test::Mojo->new('App::Voter');
$t->get_ok('/contests' => {Accept => 'application/json',})->status_is(200)
    ->json_is([]);
#   ->json_is('/0', 'segundo-contest')->json_is('/1', 'primeiro-contest')
#   ->json_is('/2', 'valid-slug');

$t->post_ok(
    '/contests' => {Accept => 'application/json'},
    json        => {
        slug        => 'primeiro-contest',
        name        => 'Primeiro',
        description => 'bla bla bla',
        start_date  => DateTime->now(time_zone => 'local') . 'Z',
        end_date =>
            DateTime->now(time_zone => 'local')->add_duration($duration1)
            . 'Z'
    }
)->status_is(200);

$t->post_ok(
    '/contests' => {Accept => 'application/json'},
    json        => {
        slug        => 'primeiro-contest',
        name        => 'Primeiro',
        description => 'bla bla bla',
        start_date  => DateTime->now(time_zone => 'local') . 'Z',
        end_date =>
            DateTime->now(time_zone => 'local')->add_duration($duration1)
            . 'Z'
    }
    )->status_is(412)->json_has('/errors')
    ->json_is('/errors/0/', 'contest already in db');

$t->post_ok(
    '/contests' => {Accept => 'application/json'},
    json        => {
        slug       => 'outro-contest',
        name       => 'Outro',
        start_date => DateTime->now(time_zone => 'local') . 'Z',
        end_date =>
            DateTime->now(time_zone => 'local')->add_duration($duration1)
            . 'Z'
    }
)->status_is(200);
$t->get_ok('/contests' => {Accept => 'application/json',})->status_is(200)
    ->json_is(['primeiro-contest','outro-contest'])
    ->json_is('/1', 'outro-contest')->json_is('/0', 'primeiro-contest');

$t->post_ok('/contests/primeiro-contest/token/create' =>
        {Accept => 'application/json',})->status_is(200);
my $token_contest1 = $t->tx->res->json->{token};

$t->post_ok(
    '/contests/invalid-slug/token/create' => {Accept => 'application/json',})
    ->status_is(403);

# ADD SOME CANDIDATES
$t->post_ok(
    '/contests/primeiro-contest/candidates' =>
        {Accept => 'application/json'},
    json => {name => 'bla1', avatar => 'http://bla1'}
)->status_is(200);

# INSERT CAIDIDATES FOR CONTEST primeiro-contest

$t->post_ok(
    '/contests/primeiro-contest/candidates' =>
        {Accept => 'application/json'},
    json => {name => 'bla2', avatar => 'http://bla2'}
)->status_is(200);

$t->post_ok(
    '/contests/primeiro-contest/candidates' =>
        {Accept => 'application/json'},
    json => {name => 'bla3', avatar => 'http://bla3'}
)->status_is(200);

$t->post_ok(
    '/contests/IVALID-contest/candidates' => {Accept => 'application/json'},
    json => {name => 'bla3', avatar => 'http://bla3'}
)->status_is(400);

# LIST CANDIDATES

$t->get_ok(
    '/contests/primeiro-contest/candidates' => {Accept => 'application/json'}
    )->status_is(200)->json_is(

    [
        {avatar => "http://bla1", id => 1, name => "bla1", votes => 0},
        {avatar => "http://bla2", id => 2, name => "bla2", votes => 0},
        {avatar => "http://bla3", id => 3, name => "bla3", votes => 0}
    ]

    );

# INSERT CANDIDATES FOR CONTEST outro-contest

$t->post_ok(
    '/contests/outro-contest/candidates' => {Accept => 'application/json'},
    json => {name => 'xxx1', avatar => 'http://xxx1'}
)->status_is(200);

$t->post_ok(
    '/contests/outro-contest/candidates' => {Accept => 'application/json'},
    json => {name => 'xxx2', avatar => 'http://xxx2'}
)->status_is(200);

$t->post_ok(
    '/contests/outro-contest/candidates' => {Accept => 'application/json'},
    json => {name => 'xxx3', avatar => 'http://xxx3'}
)->status_is(200);

$t->get_ok(
    '/contests/outro-contest/candidates' => {Accept => 'application/json'})
    ->status_is(200)->json_is(

    [
        {avatar => "http://xxx1", id => 1, name => "xxx1", votes => 0},
        {avatar => "http://xxx2", id => 2, name => "xxx2", votes => 0},
        {avatar => "http://xxx3", id => 3, name => "xxx3", votes => 0}
    ]

    );

# VOTE WITHOUT TOKEN
$t->post_ok('/votes/primeiro-contest/1' => {Accept => 'application/json',})
    ->status_is(400);
# CONTEST NOT FOUND
$t->post_ok(
    '/votes/not-created-contest/1' => {Accept => 'application/json',})
    ->status_is(400);
# CANDIDATE_ID NOT FOUND
$t->post_ok(
    '/votes/not-created-contest/9999999' => {Accept => 'application/json',})
    ->status_is(400);
# VOTE WITH TOKEN
$t->post_ok(
    '/votes/primeiro-contest/1' => {
        Accept       => 'application/json',
        'user-token' => $token_contest1,      # <- token no header
    }
)->status_is(200);

do {
    $t->post_ok(
        '/votes/primeiro-contest/1' => {
            Accept       => 'application/json',
            'user-token' => $token_contest1,      # <- token no header
        }
    )->status_is(200);
    }
    for (1 .. 4);

do {
#already voted 5 times with this token
    $t->post_ok(
        '/votes/primeiro-contest/1' => {
            Accept       => 'application/json',
            'user-token' => $token_contest1,      # <- token no header
        }
    )->status_is(400);
    }
    for (1 .. 5);

$t->get_ok('/votes/primeiro-contest/1' => {Accept => 'application/json'})
    ->status_is(200)->json_has('/votes')->json_is('/votes', 5)
    ; #votou 10 vezes com mesmo token no intervalo de 10min. portanto foram registrados 5 votos.

$t->post_ok('/contests/primeiro-contest/token/create' =>
        {Accept => 'application/json',})->status_is(200);
my $token2_contest1 = $t->tx->res->json->{token};

$t->post_ok(
    '/votes/primeiro-contest/2' => {
        Accept       => 'application/json',
        'user-token' => $token2_contest1,     # <- token no header
    }
)->status_is(200);

$t->get_ok('/votes/primeiro-contest/2' => {Accept => 'application/json'})
    ->status_is(200)->json_has('/votes')->json_is('/votes', 1);

$t->post_ok(
    '/votes/primeiro-contest/1' => {
        Accept       => 'application/json',
        'user-token' => $token2_contest1,     # <- token no header
    }
)->status_is(200);

$t->get_ok('/votes/primeiro-contest/1' => {Accept => 'application/json'})
    ->status_is(200)->json_has('/votes')->json_is('/votes', 6);

$t->post_ok(
    '/votes/primeiro-contest/1' => {
        Accept       => 'application/json',
        'user-token' => $token2_contest1,     # <- token no header
    }
)->status_is(200);

$t->get_ok('/votes/primeiro-contest/1' => {Accept => 'application/json'})
    ->status_is(200)->json_has('/votes')->json_is('/votes', 7);

$t->post_ok(
    '/votes/primeiro-contest/2' => {
        Accept       => 'application/json',
        'user-token' => $token2_contest1,     # <- token no header
    }
)->status_is(200);

$t->get_ok('/votes/primeiro-contest/2' => {Accept => 'application/json'})
    ->status_is(200)->json_has('/votes')->json_is('/votes', 2);

$t->get_ok('/votes/primeiro-contest/3' => {Accept => 'application/json'})
    ->status_is(200)->json_has('/votes')->json_is('/votes', 0);

# GET /votes/:contest_slug
$t->get_ok('/votes/primeiro-contest' => {Accept => 'application/json'})
    ->status_is(200)->json_is([
        {avatar => "http://bla1", id => 1, name => "bla1", votes => 7},
        {avatar => "http://bla2", id => 2, name => "bla2", votes => 2},
        {avatar => "http://bla3", id => 3, name => "bla3", votes => 0}
    ]
    );


# NOW TEST outro-contest

$t->get_ok('/votes/outro-contest' => {Accept => 'application/json'})
    ->status_is(200)->json_is([
        {avatar => "http://xxx1", id => 1, name => "xxx1", votes => 0},
        {avatar => "http://xxx2", id => 2, name => "xxx2", votes => 0},
        {avatar => "http://xxx3", id => 3, name => "xxx3", votes => 0}
    ]
    );

# Vote in outro-contest with token created for the other contest.. NOT ALLOWED
$t->post_ok(
    '/votes/outro-contest/2' => {
        Accept       => 'application/json',
        'user-token' => $token2_contest1,     # <- token no header
    }
)->status_is(400);

# now create a proper token for outro-contest
$t->post_ok(
    '/contests/outro-contest/token/create' => {Accept => 'application/json',}
)->status_is(200);
my $token_contest2 = $t->tx->res->json->{token};
#now vote with correct token
$t->post_ok('/votes/outro-contest/2' =>
        {Accept => 'application/json', 'user-token' => $token_contest2,})
    ->status_is(200);

$t->post_ok('/votes/outro-contest/2' =>
        {Accept => 'application/json', 'user-token' => $token_contest2,})
    ->status_is(200);

$t->post_ok('/votes/outro-contest/3' =>
        {Accept => 'application/json', 'user-token' => $token_contest2,})
    ->status_is(200);
do {
    $t->post_ok('/votes/outro-contest/1' =>
            {Accept => 'application/json', 'user-token' => $token_contest2,})
        ->status_is(200);
    }
    for (1 .. 2);

# now create another token and use to vote

$t->post_ok(
    '/contests/outro-contest/token/create' => {Accept => 'application/json',}
)->status_is(200);
$token2_contest2 = $t->tx->res->json->{token};

do {
    $t->post_ok(
        '/votes/outro-contest/2' => {
            Accept       => 'application/json',
            'user-token' => $token2_contest2,
        }
    )->status_is(200);
    }
    for (1 .. 5);

# used all my 5 votes
$t->post_ok('/votes/outro-contest/2' =>
        {Accept => 'application/json', 'user-token' => $token2_contest2,})
    ->status_is(400);

$t->get_ok('/votes/outro-contest' => {Accept => 'application/json'})
    ->status_is(200)->json_is([
        {avatar => "http://xxx1", id => 1, name => "xxx1", votes => 2},
        {avatar => "http://xxx2", id => 2, name => "xxx2", votes => 7},
        {avatar => "http://xxx3", id => 3, name => "xxx3", votes => 1}
    ]
    );

# try create token for invalid contest
$t->post_ok('/contests/invalid-contest/token/create' =>
        {Accept => 'application/json',})->status_is(403);


#   $t->post_ok('/contests' => {Accept => 'application/json'}, json => {
#       slug        => 'querto-contest',
#       name        => 'Quarto',
#       start_date  => DateTime->now(time_zone => 'local').'Z',
#       end_date    => DateTime->now(time_zone => 'local')->add_duration($duration1).'Z'
#   } )->status_is(200)
#   ->json_has('/slug')
#   ->json_has('/name');

done_testing;
