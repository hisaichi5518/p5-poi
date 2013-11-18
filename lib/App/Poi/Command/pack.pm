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

sub execute {
    my ($self, $opts, $args) = @_;

    my $base_dir     = $args->[0] or die "YOU SHOULD RUN `poi pack .`";
    my $template_dir = path($base_dir)->absolute;

    my $renderer = App::Poi::FlavorRenderer->new;
    my $itr      = $template_dir->iterator({recurse => 1});
    my %result;
    while (my ($path) = $itr->()) {
        next if $path->is_dir;
        next if $path =~ m{\.git/};

        $result{$renderer->render_path($path->relative)}
            = $rendeerer->render_body($path->slurp_utf8);

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

  $ poi pack <template dir>

=head1 DESCRIPTION

  <template dir>以下にあるファイルを全てFlavorファイルにまとめます。
  NOTE: ただし、PATHに.git/を含むファイルは省く。

  詳しくは、perldoc -m App::Poi::Command::pack

=head1 SEE ALSO

L<App::Poi::Command::pack>

=cut
