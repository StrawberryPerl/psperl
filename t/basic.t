
use strict;
use warnings;
use version;
use Test::More;

( my $travis_perl_version = $ENV{TRAVIS_PERL_VERSION} ) =~
  s/^perl[^-]+\-([0-9]+\.[0-9]+\.[0-9]+).*$/$1/;
$travis_perl_version = version->parse($travis_perl_version);

note "perl executable is $^X";

is $^V, $travis_perl_version,
  "$^V matches $travis_perl_version ($ENV{TRAVIS_PERL_VERSION})";

done_testing;
