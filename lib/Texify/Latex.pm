package Texify::Latex;
use Mojo::Base 'Mojolicious::Controller';

use 5.014;

use Mojo::IOLoop;

use Cwd::Guard qw(cwd_guard);
use File::Temp qw(tempfile tempdir);
use Digest::SHA qw(sha256_base64);

sub image {
    my $self = shift;

    my $content = $self->param('content');

    # this may take a while...
    $self->render_later;
    Mojo::IOLoop->stream($self->tx->connection)->timeout(300);

    my $image_fname = $self->app->images->get($content);

    my $eqn = {
        content   => $content,
        image_url => $image_fname,
    };

    return defined $image_fname
        ? $self->render_json($eqn)
        : $self->render_exception('could not find or render tex');
}

1;
