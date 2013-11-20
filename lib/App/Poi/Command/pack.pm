package App::Poi::Command::pack;
use 5.10.1;
use strict;
use warnings;
use utf8;
use App::Poi -command;
use Path::Tiny qw(path);
use Encode;
use App::Poi::FlavorRenderer;
use App::Poi::Packer;

# ABSTRACT: YOU SHOULD RUN 'poi help pack'.

sub description {
    my ($self) = @_;
    my $class  = ref $self;
    `perldoc -T $class`;
}

sub opt_spec { (["ignore=s@", "Ignore files/directories matching this pattern."]) }

sub match {
    my ($path, $patterns) = @_;

    for my $pattern (@$patterns) {
        return 1 if $path =~ $pattern;
    }
}

sub execute {
    my ($self, $opts, $args) = @_;

    my $ignore_patterns = [map { qr/$_/ } @{$opts->{'ignore'}}];
    my $template_dir    = Path::Tiny->cwd->absolute;

    my $renderer = App::Poi::FlavorRenderer->new;
    my $itr      = $template_dir->iterator({recurse => 1});
    my %result;
    while (my ($path) = $itr->()) {
        next if $path->is_dir;
        next if $path =~ m{\.git/};

        if (match $path, $ignore_patterns) {
            warn "SKIP: $path";
            next;
        }

        $result{$renderer->render_path($path->relative)}
            = $renderer->render_body($path->slurp_utf8);

    }

    my @flavor_names = split "-", $template_dir->basename; # App-Poi-Flavor-FlavorName
    my $flavor_name  = join "::", @flavor_names;           # App::Poi::Flavor::FlavorName
    my $flavor_path  = $flavor_names[-1] . ".pm";          # FlavorName.pm

    App::Poi::Packer->pack(
        name  => $flavor_name, # App::Poi::Flavor::FlavorName
        path  => $flavor_path, # FlavorName.pm
        files => \%result,
    );
}

1;
__END__

=encoding utf-8

=head1 USAGE

  $ poi pack

=head1 DESCRIPTION

実行したディレクトリ以下にあるファイルを全てFlavorファイルにまとめます。

NOTE: ただし、PATHに.git/を含むファイルは省く。

詳しくは、perldoc -m App::Poi::Command::pack

=head1 変換文字

=head2 MyApp

  ファイルのパス(path): <% $path.name %>   # Foo/Bar
  ファイルの中身(body): <% $module.name %> # Foo::Bar

=head2 my-app

  ファイルのパス(path): <% $dist.name.with_hyphen.downcase %> # foo-bar
  ファイルの中身(body): <% $dist.name.with_hyphen.downcase %> # foo-bar

=head2 MY-APP

  ファイルのパス(path): <% $dist.name.with_hyphen.upcase %> # FOO-BAR
  ファイルの中身(body): <% $dist.name.with_hyphen.upcase %> # FOO-BAR

=head2 my_app

  ファイルのパス(path): <% $dist.name.with_undersocre.downcase %> # foo_bar
  ファイルの中身(body): <% $dist.name.with_undersocre.downcase %> # foo_bar

=head2 MY_APP

  ファイルのパス(path): <% $dist.name.with_undersocre.upcase %> # FOO_BAR
  ファイルの中身(body): <% $dist.name.with_undersocre.upcase %> # FOO_BAR

=cut
