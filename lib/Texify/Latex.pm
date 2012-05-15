package Texify::Latex;

use 5.014;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::Template;
use Mojo::Home;

use Cwd::Guard qw(cwd_guard);
use File::Temp qw(tempfile tempdir);
use Digest::SHA qw(sha256_base64);

# XXX: Remove
use Data::Printer;

has tmpl_fname => sub {
    my $self = shift;
    $self->app->home->rel_file($self->app->config->{template_file});
};

sub welcome {
    my $self = shift;
}

sub image {
    my $self = shift;

    $self->app->log->debug(p $self->app->config);

    my $content = $self->param('content');
    my $latex = Mojo::Template->new->render_file($self->tmpl_fname, $content);
    $self->app->log->debug("latex: $latex");

    my $sha_key = (sha256_base64($latex) =~ s{/}{-}gr);

    if (!-e qq{public/$sha_key.png}) {
        $self->stash(latex   => $latex);
        $self->stash(sha_key => $sha_key);
        $self->make_dvi();
    }

    return $self->render_static(qq{public/$sha_key.png});
}

# XXX: move the 'make_*' functions into a model

sub make_dvi {
    my $self = shift;

    my $latex   = $self->stash->{latex};
    my $sha_key = $self->stash->{sha_key};

    my $dir   = tempdir();
    my $fname = "$dir/$sha_key.tex";
    open my $fh, '>', $fname;
    binmode $fh;
    print {$fh} $latex;
    close $fh;

    my @latex_cmd;
    push @latex_cmd, $self->app->config->{latex} || 'latex';
    push @latex_cmd, qw(-interaction=batchmode -output-format=dvi);
    push @latex_cmd, $fname;

    $self->app->log->debug(p @latex_cmd);

    COMMAND: {
        my $guard = cwd_guard($dir)
            || $self->render_exception(
            "can't change dir: $Cwd::Guard::Error");

        system @latex_cmd;

        if ($? != 0) {
            return $self->render_exception("LaTeX command failed.: $!");
        }
    }

    $self->stash(tmp_dir => $dir);
    return $self->make_img();
}

sub make_img {
    my $self = shift;

    my $tmp_dir = $self->stash->{tmp_dir};
    my $sha_key = $self->stash->{sha_key};

    my @dvipng_cmd;
    push @dvipng_cmd, $self->app->config->{dvipng} || 'dvipng';
    push @dvipng_cmd, qw(-bg transparent);
    push @dvipng_cmd, "$sha_key.dvi";

    COMMAND: {
        my $guard = cwd_guard($tmp_dir)
            || $self->render_exception(
            "can't change dir: $Cwd::Guard::Error");

        system @dvipng_cmd;
        if ($? != 0) {
            return $self->render_exception('dvipng command failed.');
        }
    }

    link "$tmp_dir/$sha_key.png",
        $self->app->home->rel_file("public/$sha_key.png");
}

sub cleanup {
    my $self    = shift;
    my $tmp_dir = $self->stash->{tmp_dir};
}

1;
