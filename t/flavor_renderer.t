use strict;
use warnings;
use Test::More;

use_ok "App::Poi::FlavorRenderer";

subtest "render_path" => sub {
    my $renderer = App::Poi::FlavorRenderer->new;
    my $path     = $renderer->render_path("lib/MyApp/Test.pm");

    is $path, 'lib/<% $path.name %>/Test.pm';
};

subtest "render_body" => sub {
    my $renderer = App::Poi::FlavorRenderer->new;
    my $body     = $renderer->render_body('package MyApp::Test;');

    is $body, 'package <% $module.name %>::Test;';
};

subtest "_render" => sub {
    my $renderer = App::Poi::FlavorRenderer->new;
    my $text     = $renderer->_render('my-app:MY-APP:my_app:MY_APP');

    is $text, '<% $dist.name.with_hyphen.downcase %>:<% $dist.name.with_hyphen.upcase %>:<% $dist.name.with_undersocre.downcase %>:<% $dist.name.with_undersocre.upcase %>';
};

done_testing;
