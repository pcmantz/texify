package Texify::Latex;

use 5.014;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::Template;
use Mojo::Home;
use Mojo::IOLoop;

use Cwd::Guard qw(cwd_guard);
use File::Temp qw(tempfile tempdir);
use Digest::SHA qw(sha256_base64);

# XXX: Remove
use Data::Printer;

has tmpl_fname => sub {
    my $self = shift;
    $self->app->home->rel_file($self->config('template_file'));
};

sub welcome {
    my $self = shift;
}

sub image {
    my $self = shift;

    my $content = $self->param('content');

    # this may take a while...
    $self->render_later;
    Mojo::IOLoop->stream($self->tx->connection)->timeout(300);

    my $image_fname = $self->app->images->get($content);

    return defined $image_fname
        ? $self->render_static($image_fname)
        : $self->render_exception('could not find or render tex');
}

1;
