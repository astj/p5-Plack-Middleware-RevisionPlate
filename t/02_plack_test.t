use strict;
use warnings;
use File::Temp qw/tempfile/;
use Plack::Builder;
use Plack::Test;
use Test::More;
use HTTP::Request::Common qw/GET POST HEAD/;

use Plack::Middleware::RevisionPlate;

my ($fh1, $filename1) = tempfile(UNLINK => 1);
my ($fh2, $filename2) = tempfile(UNLINK => 1);

# fh2 exists at first;fh1 not.
print $fh2 "deadbeaf\n";
close $fh2;
unlink $filename1;

my $app = builder {
    enable 'Plack::Middleware::RevisionPlate', path => '/site/sha_file_not_exists', revision_filename => $filename1;
    enable 'Plack::Middleware::RevisionPlate', path => '/site/sha_filename_specified', revision_filename => $filename2;
    sub { return [200, [], ['response from app']]; }
};
my $test = Plack::Test->create($app);

my $res_exists = $test->request(GET '/site/sha_filename_specified');
is $res_exists->code, 200;
is $res_exists->content, "deadbeaf\n";

my $res_nonexists = $test->request(GET '/site/sha_file_not_exists');
is $res_nonexists->code, 404;
is $res_nonexists->content, "REVISION_FILE_NOT_FOUND\n";

note "revision file removed after app provisioned";
unlink $filename2;
my $res_removed = $test->request(GET '/site/sha_filename_specified');
is $res_removed->code, 404;
is $res_removed->content, "REVISION_FILE_REMOVED\n";

note "check one instance's statuc change doesn't affect another.";
my $res_still_nonexists = $test->request(GET '/site/sha_file_not_exists');
is $res_still_nonexists->code, 404;
is $res_still_nonexists->content, "REVISION_FILE_NOT_FOUND\n";

done_testing;
