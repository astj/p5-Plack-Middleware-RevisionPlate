requires 'perl', '5.008001';
requires 'Plack::Middleware';
requires 'Plack::Response';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

