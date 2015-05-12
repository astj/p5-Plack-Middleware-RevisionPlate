package Plack::Middleware::RevisionPlate;
use 5.008001;
use strict;
use warnings;

use Plack::Response;
use parent qw/Plack::Middleware/;

our $VERSION = "0.01";

sub call {
    my $self = shift;
    my $env  = shift;

    my $res = $self->_may_handle_request($env);
    return $res // $self->app->($env);
}

sub _may_handle_request {
    my($self, $env) = @_;

    my $path_match = $self->path or return;
    my $path = $env->{PATH_INFO};

    for ($path) {
        my $matched = 'CODE' eq ref $path_match ? $path_match->($_, $env) : $_ =~ $path_match;
        return unless $matched;
    }

    my $res = Plack::Response->new(200);
    return $res; # TODO
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

