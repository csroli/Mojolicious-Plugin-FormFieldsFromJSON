#!/usr/bin/env perl

use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;
use File::Basename;
use File::Spec;

plugin 'FormFieldsFromJSON' => {
  dir => File::Spec->catdir( dirname( __FILE__ ) || '.', 'conf' ),
};

my $config_name = basename __FILE__;
$config_name    =~ s{\A \d+_ }{}xms;
$config_name    =~ s{\.t \z }{}xms;

get '/' => sub {
  my $c = shift;
  my $validation = $c->validate_form_fields( $config_name , output => "original");
	return $c->render(text => 'Not ok') if(exists $validation->{error}{name});
	# got the validated $c->param too?
	return $c->render(text => 'Data missing') unless (defined $validation->{output}{name});
	return $c->render(text => 'Everything ok');
};

get '/optional' => sub {
  my $c = shift;
  my $validation = $c->validate_form_fields( $config_name , output => "original");
	return $c->render(text => defined $validation->{output}{note}? 'Got optional' : 'Optional missing')
};

my $t = Test::Mojo->new;
$t->get_ok('/?name=test')->status_is(200)->content_is('Everything ok');
$t->get_ok('/')->status_is(200)->content_is('Not ok');

$t->get_ok('/optional?name=test')->status_is(200)->content_is('Optional missing');
$t->get_ok('/optional?name=test&note=something')->status_is(200)->content_is('Got optional');

done_testing();

