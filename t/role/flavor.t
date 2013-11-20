use strict;
use warnings;
use Test::More;
use Path::Tiny;

package App::Poi::Flavor::Test {
    use Mouse;
    with "App::Poi::Role::Flavor";

    sub files {
        {
            'lib/<% $path.name %>.pm' => "use Test::More;pass;",
        };
    }
};


subtest "vars" => sub {
    my $f = App::Poi::Flavor::Test->new(module => "Foo::Bar");
    is_deeply $f->vars, {
        module => {name => "Foo::Bar"},
        path   => {name => "Foo/Bar"},
        dist   => {
            name => {
                with_hyphen => {
                    upcase   => "FOO-BAR",
                    downcase => "foo-bar",
                },
                with_underscore => {
                    upcase   => "FOO_BAR",
                    downcase => "foo_bar",
                },
            }
        },
    };
};


subtest "run" => sub {
    my $base_dir = Path::Tiny->tempdir->child("foo-bar");
    my $f = App::Poi::Flavor::Test->new(
        module   => "Foo::Bar",
        base_dir => $base_dir,
    );
    $f->run;
    ok -e $base_dir->child("lib/Foo/Bar.pm");
};

done_testing;
