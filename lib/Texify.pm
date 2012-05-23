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

    # Secret
    $self->secret($self->config('secret'));

    # Plugins
    $self->plugin('PODRenderer');    # docs at  "/perldoc"
    $self->plugin('Config');

    # Router
    my $r = $self->routes;

    # Normal route to controller
    $r->get('/')->to('root#index');
    $r->get('/about')->to('root#about');
    $r->get('/contact')->to('root#contact');

    # POST controller
    $r->post('/render')->to('latex#image');
}

1;
