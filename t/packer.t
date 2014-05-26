use strict;
use warnings;
use Test::More;
use Path::Tiny;
use Digest::SHA qw/sha1_hex/;

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


subtest "stable pack" => sub {
    my $tempdir  = Path::Tiny->tempdir;
    $tempdir->mkpath;

    my $tempfile = $tempdir->child("Poi.pm");
    my $packer   = App::Poi::Packer->new;

    my $target_digest;
    for (1..10) {
        $tempfile->remove;
        $packer->pack(
            name  => "Test::App::Poi",
            path  => "$tempfile",
            files => {
                "test.t"  => "use Test::More; pass;\n",
                "test2.t" => "use strict;\nuse Test::More;pass;",
                "t/test3.t" => "use strict;\nuse Test::More;pass;",
                "t/test4.t" => "use strict;\nuse Test::More;pass;",
            },
        );
        my $digest = sha1_hex($tempfile->slurp);
        $target_digest ||= $digest;

        is $digest, $target_digest;
    }
};

done_testing;
