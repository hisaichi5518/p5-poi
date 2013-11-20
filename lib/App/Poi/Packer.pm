package App::Poi::Packer;
use 5.10.1;
use Mouse;
use Encode qw(encode_utf8);
use Path::Tiny qw(path);

sub pack {
    my ($self, %args) = @_;
    my $flavor_name = $args{name};
    my $flavor_path = $args{path};
    my $files       = $args{files};
    my $result      = "";

    for my $file (keys %$files) {
        $result .= qq!'$file' => <<'__APP_POI_PACKER__',\n!;
        $result .= $files->{$file};
        $result .= qq!__APP_POI_PACKER__\n!;
    }

    my $flavor = encode_utf8 <<"...";
package $flavor_name;
use Mouse;
with "App::Poi::Role::Flavor";
no Mouse;

sub files {
    {
        $result
    };
}

1;
...

    my $path = path("$flavor_path");
    die "you have a $path" if -e $path;

    say "generate flavor: $path";
    my $fh = $path->openw;
    $fh->print($flavor);
    $fh->close;
}

1;
