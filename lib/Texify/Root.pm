package Texify::Root;
use Mojo::Base 'Mojolicious::Controller';

sub index { shift->render(message => 'Templates are working well, I see.'); }

# I am lazy
sub about   { shift->render(); }
sub contact { shift->render(); }

1;
