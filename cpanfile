requires 'perl', '5.008001';
requires 'Plack::Middleware';
requires 'Plack::Response';
requires 'File::Slurp';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Plack::Test';
    requires 'Test::Class';
    requires 'File::Temp';
    requires 'HTTP::Request::Common';
};

