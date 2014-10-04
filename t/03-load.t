#! perl

use 5.006;
use strict;
use warnings;

use Test::More 0.88;

use lib 't/lib';
use Plugin::Loader;

my $loader = Plugin::Loader->new()
             || BAIL_OUT("Can't instantiate Plugin::Loader");

eval {
    $loader->load('LoadMe::Failing');
};
ok($@, "Trying to load 'LoadMe::Failing' should croak");

eval {
    $loader->load('LoadMe::HollowVoice');
};
ok(!$@, "Trying to load 'LoadMe::HollowVoice' should NOT croak");

my $result;
eval {
    $result = LoadMe::HollowVoice::hollow_voice();
};
ok(!$@ && $result eq 'plugh',
   "On loading 'LoadMe::HollowVoice' we should be able to call its function");

done_testing;

