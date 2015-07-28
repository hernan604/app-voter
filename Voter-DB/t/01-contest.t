use Test::More;
use Voter::DB;
use Redis;
use DDP;
use DateTime;
use DateTime::Duration;

`redis-cli -c "flushall"`;

my $v = Voter::DB->new( redis => Redis->new );
my $duration1  = DateTime::Duration->new(seconds => 1);

my $contests = $v->contest->list;

my $contest = {
    slug        => 'primeiro-contest',
    name        => 'Primeiro',
    description => 'bla bla bla',
    start_date  => DateTime->now(time_zone => 'local').'Z',
    end_date    => DateTime->now(time_zone => 'local')->add_duration($duration1).'Z',
};

#there are no contents now, so the array of contests is empty
is_deeply( $v->contest->list, [], 'Contest list is empty' );
ok( $v->contest->add($contest) , "contest addd successfully" );

# não pode criar 2 contest com mesmo slug
my $contest_clone = {map{$_=>$contest->{$_}}keys%{$contest}};
ok($v->contest->add($contest_clone)->has_errors , "cant add contest with same slug twice" );

# incluiu primeiro contest
is_deeply( $v->contest->list, ['primeiro-contest'], 'Contest list is empty' );

is_deeply( $v->contest->find('primeiro-contest')->as_hash, $contest, 'primeiro contest cadastrado com sucesso' );

ok( $v->contest->del( 'primeiro-contest' ), 'deletado com sucesso' );

my $contest2 = {
    slug        => 'segundo-contest',
    name        => 'Segundo',
    description => 'bla bla bla',
    start_date  => DateTime->now(time_zone => 'local').'Z',
    end_date    => DateTime->now(time_zone => 'local')->add_duration($duration1).'Z',
};

ok( $v->contest->add($contest2),'addd' );
my $contest_clone2 = {map{$_=>$contest->{$_}}keys%{$contest}};
ok( $v->contest->add($contest_clone2),'addd' );
is_deeply( $v->contest->list, ['segundo-contest','primeiro-contest'], 'Contest list' );

ok( $v->contest->del( 'primeiro-contest' ) );
ok( $v->contest->del( 'segundo-contest' ) );
ok(!$v->contest->del( 'segundo-contest' ) ); #already deleted

ok $v->contest->add({
    slug        => '[]seet', #<- invalid slug
    name        => 'Segundo',
    description => 'bla bla bla',
    start_date  => DateTime->now(time_zone => 'local').'Z',
    end_date    => DateTime->now(time_zone => 'local')->add_duration($duration1).'Z',
})->has_errors;

ok $v->contest->add({
    slug        => 'segundo-contest',
    name        => 'BIG NAME AAAAAAAAAAAAAAAAAAAA',#big name
    description => 'bla bla bla',
    start_date  => DateTime->now(time_zone => 'local').'Z',
    end_date    => DateTime->now(time_zone => 'local')->add_duration($duration1).'Z',
})->has_errors;

ok $v->contest->add({
    slug        => 'long-slug-long-loooooooooooooooooooooong-invalid',
    name        => 'BIG ',#big name
    description => 'bla bla bla',
    start_date  => DateTime->now(time_zone => 'local').'Z',
    end_date    => DateTime->now(time_zone => 'local')->add_duration($duration1).'Z',
})->has_errors;

ok $v->contest->add({
    slug        => 'valid-slug',
    name        => 'BIG ',#big name
  # description => 'bla bla bla', <- without description
    start_date  => DateTime->now(time_zone => 'local').'Z',
    end_date    => DateTime->now(time_zone => 'local')->add_duration($duration1).'Z',
});

done_testing;
