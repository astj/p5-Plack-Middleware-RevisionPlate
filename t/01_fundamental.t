use strict;
use warnings;
use Test::More;
use parent qw/Test::Class/;

use Plack::Middleware::RevisionPlate;

sub with_revision_filename_specified : Tests {
    my $middleware = Plack::Middleware::RevisionPlate->new( path => '/otherpath', revision_filename => 't/assets/REVISION_FILE' );
    is $middleware->path, '/otherpath';
    is $middleware->_revision_filename, 't/assets/REVISION_FILE', 'specified filename';

    is $middleware->_read_revision_file_at_first, "deadbeaf\n", 'Can read content of revision_file';
}

sub with_default_revision_filename : Tests {
    my $middleware = Plack::Middleware::RevisionPlate->new( path => '/somepath' );
    is $middleware->path, '/somepath';
    is $middleware->_revision_filename, './REVISION', 'fallback to default';

    is $middleware->_read_revision_file_at_first, undef, 'revision file not exists, so undef';
}

__PACKAGE__->runtests;
