#!/usr/bin/env perl

use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;
use File::Basename;
use File::Spec;
use lib "lib";

plugin 'FormFieldsFromJSON' => {
  dir => File::Spec->catdir( dirname( __FILE__ ) || '.', 'conf' ),
};

my $config_names = ["textfield", "unset_required"];

get '/errors' => sub {
  my $c = shift;
  my %errors = $c->validate_form_fields( $config_names );
  my $ok = (scalar grep {defined $errors{$_}} keys %errors)>0;
  $c->render(text => ( $ok ? 'Not ok: '.(scalar grep {defined $errors{$_}} keys %errors) : 'Everything ok' ) );
};

get '/output' => sub {
  my $c = shift;
  my $validator = $c->validate_form_fields( $config_names , output => "original");
  $c->render(json => {
    output => $validator->output,
    error => $validator->{error},
    has_error => $validator->has_error
  } );
};

my $t = Test::Mojo->new;
$t->get_ok('/errors?name=test&anything=test')->status_is(200)->content_is('Everything ok');
$t->get_ok('/errors?name=t')->status_is(200)->content_is('Not ok: 2');
$t->get_ok('/errors?name=test')->status_is(200)->content_is('Not ok: 1');


$t->get_ok('/output?name=test&anything=test')
  ->status_is(200)
  ->json_is('/has_error','')
  ->json_is('/error',{})
  ->json_is('/output', {name=>"test", anything=>"test"});

$t->get_ok('/output?name=t')
  ->status_is(200)
  ->json_is('/has_error',1)
  ->json_is('/error',{anything => ["required"], name => ["size",1,2,5]})
  ->json_is('/output',{});

$t->get_ok('/output?name=test')
  ->status_is(200)
  ->json_is('/has_error',1)
  ->json_is('/error',{anything => ["required"]} )
  ->json_is('/output',{name => "test"});

done_testing();

