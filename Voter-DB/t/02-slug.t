use utf8;
use Test::More;
use Voter::DB;

my $v = Voter::DB;
ok( $v->to_slug(" áÁ é[-]=|rap=") eq "aa-e-rap", "teste slug");
ok( $v->to_slug(" -[ lasoDć 3á2é1\\í|ó;ú;a2b~cßdáe©r") eq "lasod-3a2e1-i-o-u-a2b-c-dae-r", "teste slug");

done_testing;
