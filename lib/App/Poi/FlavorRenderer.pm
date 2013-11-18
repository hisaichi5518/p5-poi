package App::Poi::FlavorRenderer;
use Mouse;

sub render_path {
    my ($self, $text) = @_;

    $text =~ s/MyApp/<% \$path.name %>/g; #=> Foo/Bar

    $text = $self->_render($text);

    $text;
}

sub render_body {
    my ($self, $text) = @_;

    $text =~ s/MyApp/<% \$module.name %>/g; #=> Foo::Bar

    $text = $self->_render($text);

    $text;
}

sub _render {
    my ($self, $text) = @_;

    # hyphen
    $text =~ s/my-app/<% \$dist.name.with_hyphen.downcase %>/g; #=> foo-bar
    $text =~ s/MY-APP/<% \$dist.name.with_hyphen.upcase %>/g;   #=> FOO-BAR


    # underscore
    $text =~ s/my_app/<% \$dist.name.with_undersocre.downcase %>/g; #=> foo_bar
    $text =~ s/MY_APP/<% \$dist.name.with_undersocre.upcase %>/g;   #=> FOO_BAR

    $text;
}

1;
