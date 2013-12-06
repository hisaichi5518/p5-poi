requires 'perl', '5.010001';
requires 'App::Cmd';
requires 'Path::Tiny';
requires 'Mouse';
requires 'Text::Xslate';
requires 'Encode';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

