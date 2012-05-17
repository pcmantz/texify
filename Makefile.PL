use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    VERSION   => '0.01',
    PREREQ_PM => {
        'Cwd::Guard'    => '0.01',
        'Mojolicious'   => '2.95',
        'Digest::SHA'   => '5.71',
        'Test::Compile' => '0.17',
    },
    test => { TESTS => 't/*.t' }
);
