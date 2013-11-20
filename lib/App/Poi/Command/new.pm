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

sub opt_spec {
    (
        ["flavor|f=s", "set flavor(require)"],
        ["inc|I=s", "test"]
    )
}

sub validate_args {
    my ($self, $opts, $args) = @_;

    $self->usage_error("need flavor")  if !$opts->{flavor};
    $self->usage_error("need AppName") if !@$args;
}

sub execute {
    my ($self, $opts, $args) = @_;
    my $module_name = $args->[0];
    my $flavor_name = $opts->{flavor};

    push @INC, $opts->{inc} if $opts->{inc};

    my $klass = App::Poi::Util::load_class($flavor_name, "App::Poi::Flavor");
    $klass->new(module => $module_name)->run();
}

1;
__END__

=encoding utf-8

=head1 USAGE

  $ poi new --flavor=<FlavorName> <AppName>
  $ poi new -Ilib -f <FlavorName> <AppName>

=head1 DESCRIPTION

新しいアプリを作るときに使うよ。Flavor名とアプリ名が必須だよ。

=head1 SEE ALSO

L<App::Poi::Command::pack>

=cut
