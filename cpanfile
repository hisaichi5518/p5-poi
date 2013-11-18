requires 'perl', '5.010001';
requires 'App::Cmd';
requires 'Path::Tiny';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

