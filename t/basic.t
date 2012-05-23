use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Texify');
$t->get_ok('/')->status_is(200)->content_like(qr/Texify/i);

# Test some basic paths
$t->get_ok('/about')->status_is(200)->content_like(qr/About/i);
$t->get_ok('/contact')->status_is(200)->content_like(qr/Contact/i);

done_testing;
