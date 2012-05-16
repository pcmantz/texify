package Texify::Image;
use Mojo::Base 'Mojolicious';

use 5.014;

use Mojo::Template;

use Cwd;
use Cwd::Guard qw(cwd_guard);
use File::Temp qw(tempfile tempdir);
use File::Copy;
use Digest::SHA qw(sha256_base64);

use Data::Printer;

has tmp_dir => sub { tempdir('/tmp/texify.XXXXXXXX'); };

has image_dir => sub {
    my $self = shift;
    return $self->app->home->rel_file($self->app->config('image_dir')
            || 'public/img');
};

has tmpl_fname => sub {
    my $self          = shift;
    my $rel_tmpl_file = $self->app->config('template_file');
    return $self->app->home->rel_file($rel_tmpl_file);
};

sub get {
    my ($self, $content) = @_;

    # XXX: debug: remove
    # $self->app->log->debug('images->app: ' . p $self->app);

    my $image_fname = $self->find($content) // $self->add($content);

    die "image $image_fname failed to render!" if !defined $image_fname;

    my $static_image_fname = ($image_fname =~ s{^.*public/}{}r);

    return $static_image_fname;
}

sub find {
    my ($self, $content) = @_;

    my ($latex, $sha_key) = $self->_c2lh($content);
    my $image_fname = $self->image_dir . '/' . "$sha_key.png";

    return (-e $image_fname) ? $image_fname : undef;
}

sub add {
    my ($self, $content) = @_;

    my ($latex, $sha_key) = $self->_c2lh($content);
    my $image_fname = $self->image_dir . "/$sha_key.png";
    $self->app->log->debug("image_fname: $image_fname");

    $self->_make_dvi($latex, $sha_key);
    my $tmp_image_fname = $self->_make_image($sha_key);
    $self->app->log->debug("tmp_image_fname: $tmp_image_fname");
    -e $tmp_image_fname
        || die "error: $tmp_image_fname doesn't exist!";

    copy($tmp_image_fname, $image_fname)
        || die "copy: $tmp_image_fname -> $image_fname failed!";

    die qq{error: $image_fname doesn't exist!} if !-e $image_fname;

    return $image_fname;
}

sub _make_dvi {
    my ($self, $latex, $sha_key) = @_;

    my $tex_fname = $self->tmp_dir . "/$sha_key.tex";

    open my $fh, '>', $tex_fname;
    binmode $fh;
    print {$fh} $latex;
    close $fh;

    my @latex_cmd;
    push @latex_cmd, $self->app->config('latex') || 'latex';
    push @latex_cmd, qw(-interaction=batchmode -output-format=dvi);
    push @latex_cmd, $tex_fname;

    $self->app->log->debug(p @latex_cmd);

    COMMAND: {

        # XXX: should probably not render here
        my $guard = cwd_guard($self->tmp_dir)
            || $self->render_exception(
            "can't change dir: $Cwd::Guard::Error");

        $self->app->log->debug('in directory: ' . getcwd);

        system @latex_cmd;
        if ($? != 0) {

            # XXX: we don't check the return code here, we should probably
            # just die or throw some other exception
            return undef;
        }
    }
}

sub _make_image {
    my ($self, $sha_key) = @_;

    my @dvipng_cmd;
    push @dvipng_cmd, $self->app->config('dvipng') || 'dvipng';
    push @dvipng_cmd, qw(-bg transparent);
    push @dvipng_cmd, "$sha_key.dvi";

    my $image_fname = $self->tmp_dir . '/' . $sha_key . '1.png';
    COMMAND: {

        # XXX: should probably not render here
        my $guard = cwd_guard($self->tmp_dir)
            || $self->render_exception(
            "can't change dir: $Cwd::Guard::Error");

        $self->app->log->debug('in directory: ' . getcwd);

        system(@dvipng_cmd) == 0
            || die qq{dvipng command failed: $?};

        die qq{error: $image_fname doesn't exist!} if !-e $image_fname;
    }

    return $image_fname;
}

sub _c2lh {
    my ($self, $content) = @_;

    $self->app->log->debug('content: ' . $content);
    my $latex = Mojo::Template->new->render_file($self->tmpl_fname, $content);

    # XXX: debug
    # $self->app->log->debug("latex: $latex");

    my $sha_key = (sha256_base64($latex) =~ s{/}{-}gr);

    return ($latex, $sha_key);
}

1;

=head1 NAME

Texify::Image - model class for representing images

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

Paul C. Mantz <pcmantz@gmail.com>

=cut
