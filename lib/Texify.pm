package Texify;
use Mojo::Base 'Mojolicious';

use 5.014;

use Mojo::IOLoop;

use Texify::Image;

has images => sub {
    my $self = shift;
    Texify::Image->new(config => $self->config);
};

sub startup {
    my $self = shift;

    # Plugins
    $self->plugin('PODRenderer');    # docs at  "/perldoc"
    $self->plugin('Config');

    # Router
    my $r = $self->routes;

    # Normal route to controller
    $r->get('/')->to('example#welcome');

    # if it isn't predefined, assume it's LaTeX
    $r->get('/*content')->to('latex#image');
}

1;
