#!perl

use strict;
use warnings;

use Data::Dumper;
use JSON;

use Test::More;
use Test::RequiresInternet;

use OpenAPI::Client::OpenAI;

if ( !$ENV{OPENAI_API_KEY} ) {
    plan skip_all => 'This test requires an OPENAI_API_KEY environment variable';
}

my $openai = OpenAPI::Client::OpenAI->new();

my @test_cases = (
    {
        method => 'createEdit',
        params => {
            model       => 'text-davinci-edit-001',
            input       => 'What day of the wek is it?',
            instruction => 'Fix the spelling mistakes',
            temperature => 0,
        },
        expected_text_re => qr{What day of the week is it\?},
    },
);

for my $test (@test_cases) {
    my ( $method, $params, $expected_text_re ) = @{$test}{qw/method params expected_text_re/};

    my $tx = $openai->$method( { body => $params } );

    my $response = $tx->res->json;

    like( $response->{choices}[0]{text}, $expected_text_re )
        or diag( Dumper $response );
}

done_testing();
