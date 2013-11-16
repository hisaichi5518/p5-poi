package App::Poi::Command::build;
use 5.10.1;
use strict;
use warnings;
use utf8;
use App::Poi -command;
use Cwd qw(getcwd);
use Path::Tiny qw(path);
use Data::Dumper;
use Encode;

# ABSTRACT: build template for poi.

sub execute {
    my ($self, $opts, $args) = @_;

    my $base_dir     = $args->[0] or die "YOU SHOULD RUN `poi build .`";
    my $template_dir = path($base_dir)->absolute;
    my $flavor_name  = $template_dir->basename;

    my $flavor_path  = (split "-", $flavor_name)[-1];
    $flavor_name =~ s/-/::/;

    my $files  = $self->build($template_dir);
    $self->generate_flavor(
        name  => $flavor_path,
        path  => $flavor_path,
        files => $files,
    );
}

sub generate_flavor {
    my ($self, %args) = @_;
    my $flavor_name = $args{name};
    my $flavor_path = $args{path};
    my $files       = $args{files};
    my $result = "";

    for my $file (keys %$files) {
        $result .= qq!'$file' => <<'...',\n!;
        $result .= $files->{$file} . "\n";
        $result .= qq!...\n!;
    }

    my $flavor = encode_utf8 <<"...";
package App::Poi::Flavor::$flavor_name;
use strict;
use warnings;

sub files {
    {
        $result
    };
}

1;
...
    say "generate flavor: $flavor_path.pm";
    my $fh = path("$flavor_path.pm")->openw;
    $fh->print($flavor);
    $fh->close;

}

sub build {
    my ($self, $dir) = @_;
    my $itr = $dir->iterator({recurse => 1});

    my %result;
    while (my ($path) = $itr->()) {
        next if $path->is_dir;
        next if $path =~ m{\.git/};

        $result{$self->build_path($path->relative)}
            = $self->build_file($path->slurp_utf8);
    }

    \%result;
}

sub build_path {
    my ($self, $text) = @_;

    $text =~ s/MyApp/<: \$path.name :>/g; #=> Foo/Bar

    $text = $self->_build($text);

    $text;
}

sub build_file {
    my ($self, $text) = @_;

    $text =~ s/MyApp/<: \$module.name :>/g; #=> Foo::Bar

    $text = $self->_build($text);

    $text;
}

sub _build {
    my ($self, $text) = @_;

    # hyphen
    $text =~ s/my-app/<: \$dist.name.with_hyphen.downcase :>/g; #=> foo-bar
    $text =~ s/MY-APP/<: \$dist.name.with_hyphen.upcase :>/g;   #=> FOO-BAR


    # underscore
    $text =~ s/my_app/<: \$dist.name.with_undersocre.downcase :>/g; #=> foo_bar
    $text =~ s/MY_APP/<: \$dist.name.with_undersocre.upcase :>/g;   #=> FOO_BAR

    $text;
}

sub usage       { "poi build <template dir>" }
sub description { "build flavor for poi." }

1;
