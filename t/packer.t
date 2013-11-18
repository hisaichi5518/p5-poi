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
            "test.t" => "use Test::More; pass;\n",
        },
    );

    eval $tempfile->slurp;
    ok !$@;
};

done_testing;
