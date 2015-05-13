package Plack::Middleware::RevisionPlate;
use 5.008001;
use strict;
use warnings;

use Plack::Util::Accessor qw/path revision_filename/;
use Plack::Response;
use File::Slurp qw/read_file/;
use parent qw/Plack::Middleware/;

our $VERSION = "0.01";

sub call {
    my $self = shift;
    my $env  = shift;
    return $self->_may_handle_request($env) // $self->app->($env);
}

sub prepare_app {
    my $self = shift;
    $self->_read_revision_file_at_first;
}

sub _read_revision_file_at_first {
    my $self = shift;
    $self->{revision} = -e $self->_revision_filename && read_file($self->_revision_filename);
}

sub _may_handle_request {
    my ($self, $env) = @_;
    my $path_match = $self->path or return;
    my $path = $env->{PATH_INFO};

    for ($path) {
        my $matched = 'CODE' eq ref $path_match ? $path_match->($_, $env) : $_ =~ $path_match;
        return unless $matched;
    }

    my $method = $env->{REQUEST_METHOD};
    return Plack::Response->new(405)->finalize if $method ne 'GET' && $method ne 'HEAD'; # 405: method not allowed

    my $res = Plack::Response->new;
    $res->content_type('text/plain');
    if (defined $self->{revision}) {
        if (-e $self->_revision_filename) {
            $res->status(200);
            $res->body($self->{revision});
        } else {
            $res->status(404);
            $res->body("REVISION_FILE_REMOVED\n");
        }
    } else {
        $res->status(404);
        $res->body("REVISION_FILE_NOT_FOUND\n");
    }

    $res->body('') if $method eq 'HEAD';
    return $res->finalize;
}

sub _revision_filename {
    my $self = shift;
    $self->{_revision_filename} //= $self->revision_filename // './REVISION';
}

1;
__END__

=encoding utf-8

=head1 NAME

Plack::Middleware::RevisionPlate - It's new $module

=head1 SYNOPSIS

    use Plack::Middleware::RevisionPlate;

=head1 DESCRIPTION

Plack::Middleware::RevisionPlate is ...

=head1 LICENSE

Copyright (C) Asato Wakisaka.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Asato Wakisaka E<lt>asato.wakisaka@gmail.comE<gt>

=cut

