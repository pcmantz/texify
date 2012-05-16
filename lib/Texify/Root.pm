package Texify::Root;
use Mojo::Base 'Mojolicious::Controller';

sub index { shift->render(message => 'Templates are working well, I see.'); }

1;
