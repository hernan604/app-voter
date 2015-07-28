use Test::More;
use Voter::DB;
use Redis;
use DDP;
use DateTime;
use DateTime::Duration;

my $v = Voter::DB->new(redis => Redis->new, token_interval => 10);

my $duration1  = DateTime::Duration->new(seconds => 1);
my $duration15 = DateTime::Duration->new(seconds => 15);
my $contest1   = {
    slug        => 'primeiro-contest',
    name        => 'Primeiro',
    description => 'bla bla bla',
    start_date =>
        DateTime->now(time_zone => 'local')->add_duration($duration1)
        . 'Z',    #starts within 1sec
    end_date =>
        DateTime->now(time_zone => 'local')->add_duration($duration15)
        . 'Z',    #closes in 15sec
};

my $contest2 = {
    slug        => 'segundo-contest',
    name        => 'Segundo',
    description => 'bla bla bla',
    start_date =>
        DateTime->now(time_zone => 'local')->add_duration($duration1)
        . 'Z',    #starts within 1sec
    end_date =>
        DateTime->now(time_zone => 'local')->add_duration($duration15)
        . 'Z',    #closes in 15sec
};

ok($v->contest->add($contest1), 'add');
ok($v->contest->add($contest2), 'add');

$contest2 = $v->contest->find('segundo-contest');
ok !$contest2->is_active;
warn "sleep 2 seconds...";
sleep 2;
ok $contest2->is_active;
my $candidato1 = {name => 'joe',  avatar => 'http://joe.com'};
my $candidato2 = {name => 'mary'};
ok $contest2->candidate->add($candidato1);
ok $contest2->candidate->add($candidato2);

is_deeply $contest2->candidate->list, [1, 2];

$contest1 = $v->contest->find('primeiro-contest');
is_deeply $contest1->candidate->list, [];
ok $contest1->candidate->add({name => 'bla', avatar => 'http://bla'});
ok $contest1->candidate->add({name => 'ble', avatar => 'http://ble'});
ok $contest1->candidate->add({name => 'bli', avatar => 'http://bli'});
is_deeply $contest1->candidate->list, [1, 2, 3];

my $cand3
    = $contest1->candidate->add({name => 'blo', avatar => 'http://blo'});

my $token = $contest1->token->create;

TENTA_VOTAR_MAIS_QUE_5_VEZES_NA_SEQUENCIA:

ok $contest1->candidate->find($cand3->id)->votes == 0,
    'candidato tem 0 votos';
ok $cand3->vote($token);
ok $contest1->candidate->find($cand3->id)->votes == 1,
    'candidato tem 1 votos';
ok $cand3->vote($token);
ok $contest1->candidate->find($cand3->id)->votes == 2,
    'candidato tem 2 votos';
ok $cand3->vote($token);
ok $contest1->candidate->find($cand3->id)->votes == 3,
    'candidato tem 3 votos';
ok $cand3->vote($token);
ok $contest1->candidate->find($cand3->id)->votes == 4,
    'candidato tem 4 votos';
ok $cand3->vote($token);
ok $contest1->candidate->find($cand3->id)->votes == 5,
    'candidato tem 5 votos';

JA_VOTOU_5_VEZES__AGORA_TEM_QUE_ESEPERAR_EXPIRAR_OS_10_MIN: #limite de 5 votos cada 10min

ok !$cand3->vote($token);
ok $contest1->candidate->find($cand3->id)->votes == 5,
    'candidato tem 5 votos';
ok !$cand3->vote($token);
ok $contest1->candidate->find($cand3->id)->votes == 5,
    'candidato tem 5 votos';
ok !$cand3->vote($token);

# wait 10 seconds/minuts and vote again using same token. should be allowed to vote now
warn "sleep 10 seconds...";
sleep 10;
ok $cand3->vote($token);
ok $contest1->candidate->find($cand3->id)->votes == 6,
    'candidato tem 6 votos';
ok $cand3->vote($token);
ok $contest1->candidate->find($cand3->id)->votes == 7,
    'candidato tem 7 votos';
ok $cand3->vote($token);
ok $contest1->candidate->find($cand3->id)->votes == 8,
    'candidato tem 8 votos';
ok $cand3->vote($token);
ok $contest1->candidate->find($cand3->id)->votes == 9,
    'candidato tem 9 votos';
ok $cand3->vote($token);
ok $contest1->candidate->find($cand3->id)->votes == 10,
    'candidato tem 10 votos';
ok !$cand3->vote($token); #ja votou 5 vezes no my intervalo estipulado
my $today = DateTime->now( time_zone=>'local' );
ok $contest1->candidate->find($cand3->id)->votes == 10,
    'candidato tem 10 votos';

ok !$cand3->vote("invalid token"); #tenta votar com token inexistente
ok $contest1->candidate->find($cand3->id)->votes == 10,
    'candidato tem 10 votos';

#let the contest finish... sleep some seconds. should *not* be possible to vote now
warn "sleep 15 seconds...";
sleep 15;
ok !$cand3->vote($token);
ok !$contest1->is_active;


done_testing;
