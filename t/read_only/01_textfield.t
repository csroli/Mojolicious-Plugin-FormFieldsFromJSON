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

get '/empty' => sub {
  my $c = shift;
  my $entity = {
    "name" => {data => "xx"},
    "read_only" => ""
  };
  my ($textfield) = $c->form_fields( $config_name, %$entity);
  $c->render(text => $textfield);
};

get '/only_value' => sub {
  my $c = shift;
  my $entity = {
    "name" => {data => "xx"},
    "read_only" => "1"
  };
  my ($textfield) = $c->form_fields( $config_name, %$entity);
  $c->render(text => $textfield);
};

get '/field_conf' => sub {
  my $c = shift;
  my $entity = {
    "name" => {data => "xx", "read_only" => "1"}
  };
  my ($textfield) = $c->form_fields( $config_name, %$entity);
  $c->render(text => $textfield);
};

my $close = Mojolicious->VERSION >= 5.73 ? '' : " /";

my $t = Test::Mojo->new;
$t->get_ok('/empty')->status_is(200)->content_is(qq~<input id="name" name="name" type="text" value="xx"$close>~);
$t->get_ok('/only_value')->status_is(200)->content_is("xx");
$t->get_ok('/field_conf')->status_is(200)->content_is("xx");

done_testing();

