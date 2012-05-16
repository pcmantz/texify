package Texify::Root;
use Mojo::Base 'Mojolicious::Controller';

sub index { shift->render_static('index.html'); }

1;
