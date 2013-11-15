package App::Poi::Command::new;
use 5.10.1;
use strict;
use warnings;
use utf8;
use App::Poi -command;
use Text::Xslate;
use Path::Tiny;

# ABSTRACT: create skeleton by flavor.

sub opt_spec {
    return (
        ["flavor|f=s", "set flavor(require)"],
    );
}

sub validate_args {
    my ($self, $opts, $args) = @_;

    $self->usage_error("poi new --flavor=FlavorName Hoge") if !@$args;
}

sub load_class { # copied Plack::Util#load_class
    my($self, $class, $prefix) = @_;

    if ($prefix) {
        unless ($class =~ s/^\+// || $class =~ /^$prefix/) {
            $class = "$prefix\::$class";
        }
    }

    my $file = $class;
    $file =~ s!::!/!g;
    require "$file.pm"; ## no critic

    return $class;
}

sub execute {
    my ($self, $opts, $args) = @_;

    my $module_name = $args->[0]    or die "poi new -f <flavor> <distname>";
    my $flavor_name = $opts->flavor or die "require flavor";
    my $klass       = $self->load_class($flavor_name, "App::Poi::Flavor");

    my $files = $klass->files;
    my $view  = Text::Xslate->new(module => ["Text::Xslate::Bridge::Star"]);

    # setup
    my @module_names = split "::", $module_name;
    my $path_name = join "/", @module_names;

    my $dist = {
        name => {
            with_hyphen => {
                upcase   => scalar(join "-", map { uc $_ } @module_names),
                downcase => scalar(join "-", map { lc $_ } @module_names),
            },
            with_underscore => {
                upcase   => scalar(join "_", map { uc $_ } @module_names),
                downcase => scalar(join "_", map { lc $_ } @module_names),
            },
        },
    };
    my $base_dir = path($dist->{name}{with_hyphen}{downcase});
    die "exists $base_dir." if -d $base_dir;
    $base_dir->mkpath;

    my $vars = {
        path   => {name => $path_name},
        module => {name => $module_name},
        dist   => $dist,
    };
    for my $f (keys %$files) {
        my $path = $view->render_string($f, $vars);
        my $body = $view->render_string($files->{$f}, $vars);

        my $file = path($base_dir, $path);
        my $parent = $file->parent;
        $parent->mkpath if !-d $parent;

        say "generate $file";
        # save file
        my $fh = $file->openw;
        $fh->print($body);
        $fh->close;
    }
}

1;
