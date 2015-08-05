use strict;
use warnings;
use HTTP::Tiny;
use Test::More;
use JSON::PP;
use URI;
use Parallel::ForkManager;
use DateTime;
use DateTime::Duration;

use Time::HiRes qw|gettimeofday tv_interval|;


my $ua  = HTTP::Tiny->new;
my $url = URI->new("http://192.168.5.114/contests");
$url->path('/contests');
my $total_req = 1000;

my $t0            = [gettimeofday];
my $i             = 0;
my $MAX_PROCESSES = 8;
my $pm            = Parallel::ForkManager->new($MAX_PROCESSES);

DATA_LOOP:
foreach my $data (1 .. $total_req) {
    # Forks and returns the pid for the child:
    my $pid = $pm->start and next DATA_LOOP;

    my $res = $ua->request('GET', $url,
        {headers => {Accept => 'application/json'},});
    warn $res->{content};

    $pm->finish;    # Terminates the child process
}

my $elapsed = tv_interval($t0, [gettimeofday]);

my $req_per_sec = $total_req / $elapsed;
warn "Req/s: $req_per_sec";


done_testing;
