package Texify;
use Mojo::Base 'Mojolicious';

sub startup {
    my $self = shift;

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
