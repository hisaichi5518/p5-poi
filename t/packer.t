use strict;
use warnings;
use Test::More;
use Path::Tiny;

use_ok "App::Poi::Packer";

subtest "pack" => sub {
    my $tempdir  = Path::Tiny->tempdir;
    $tempdir->mkpath;

    my $tempfile = $tempdir->child("Poi.pm");
    my $packer   = App::Poi::Packer->new;

    $packer->pack(
        name  => "Test::App::Poi",
        path  => "$tempfile",
        files => {
            "test.t"  => "use Test::More; pass;\n",
            "test2.t" => "use strict;\nuse Test::More;pass;",
        },
    );
    eval $tempfile->slurp;
    ok !$@;

    my $files = Test::App::Poi->files;
    ok $files->{"test.t"};
    ok $files->{"test2.t"};
};

done_testing;
