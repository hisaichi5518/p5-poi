package App::Poi::Command::new;
use 5.10.1;
use strict;
use warnings;
use utf8;
use App::Poi -command;
use Text::Xslate;
use Path::Tiny;
use App::Poi::Util;

# ABSTRACT: YOU SHOULD RUN 'poi help new'.

sub description {
    my ($self) = @_;
    my $class  = ref $self;
    `perldoc -T $class`;
}

sub opt_spec { (["flavor|f=s", "set flavor(require)"]) }

sub validate_args {
    my ($self, $opts, $args) = @_;

    $self->usage_error("need flavor")  if !$opts->{flavor};
    $self->usage_error("need AppName") if !@$args;
}

sub execute {
    my ($self, $opts, $args) = @_;

    my $module_name = $args->[0];
    my $flavor_name = $opts->{flavor};
    my $klass       = App::Poi::Util::load_class($flavor_name, "App::Poi::Flavor");

    my $files = $klass->files;
    my $view  = Text::Xslate->new(
        module     => ["Text::Xslate::Bridge::Star"],
        tag_start  => "<%",
        tag_end    => "%>",
        line_start => "%%",
    );

    # setup
    my @module_names = split "::", $module_name; # Fuga::Bar
    my $path_name    = join "/", @module_names;  # Fuga/Bar
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
__END__

=encoding utf-8

=head1 USAGE

  $ poi new --flavor=<FlavorName> <AppName>
  or
  $ poi new -f <FlavorName> <AppName>

=head1 DESCRIPTION


=head1 SEE ALSO

L<App::Poi::Command::pack>

=cut
