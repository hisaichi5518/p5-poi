package App::Poi::Role::Flavor;
use 5.10.1;
use Mouse::Role;
use Text::Xslate;
use Path::Tiny;


has module => (
    is => "rw",
    isa => "Str",
    required => 1,
);

has vars => (
    is => "rw",
    isa => "HashRef",
    default => sub { +{} },
);

has renderer => (
    is => "rw",
    isa => "Object",
    default => sub {
        Text::Xslate->new(
            module     => ["Text::Xslate::Bridge::Star"],
            tag_start  => "<%",
            tag_end    => "%>",
            line_start => "%%",
        );
    },
);

has base_dir => (
    is => "rw",
    isa => "Path::Tiny",
    required => 1,
);

requires qw(files);

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    my $args  = $class->$orig(@_);

    my $base_dir     = $args->{base_dir};
    my $module_name  = $args->{module};
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

    my $vars = {
        path   => {name => $path_name},
        module => {name => $module_name},
        dist   => $dist,
    };

    {
        vars     => $vars,
        module   => $module_name,
        base_dir => $base_dir || path($vars->{dist}{name}{with_hyphen}{downcase}),
    };
};

no Mouse::Role;


sub run {
    my ($self) = @_;

    my $files    = $self->files;
    my $renderer = $self->renderer;
    my $vars     = $self->vars;

    my $base_dir = $self->base_dir;
    die "exists $base_dir." if -d $base_dir;
    $base_dir->mkpath;

    for my $f (keys %$files) {
        my $path = $renderer->render_string($f, $vars);
        my $body = $renderer->render_string($files->{$f}, $vars);

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
