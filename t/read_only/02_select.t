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

get '/done/:yn' => sub {
  my $c = shift;
  my $entity = {
    "done" => {selected => $c->param("yn")},
    "read_only" => "1"
  };
  my ($textfield) = $c->form_fields( $config_name, %$entity);
  $c->render(text => $textfield);
};


get '/overridden_hash' => sub {
  my $c = shift;
  my $entity = {
    "done" => {selected => 0, data => { 0 => "oh", 1 => "one"}},
    "read_only" => "1"
  };
  my ($textfield) = $c->form_fields( $config_name, %$entity);
  $c->render(text => $textfield);
};

get '/overridden_array' => sub {
  my $c = shift;
  my $entity = {
    "done" => {selected => 0, data => [0,1]},
    "read_only" => "1"
  };
  my ($textfield) = $c->form_fields( $config_name, %$entity);
  $c->render(text => $textfield);
};

get '/overridden_aoh' => sub {
  my $c = shift;
  my $entity = {
    "done" => {selected => 0, data => [{1 => "one"}, {0 => "zero"}]},
    "read_only" => "1"
  };
  my ($textfield) = $c->form_fields( $config_name, %$entity);
  $c->render(text => $textfield);
};

get '/overridden_multi' => sub {
  my $c = shift;
  my $entity = {
    "done" => {selected => [0,1], data => [{1 => "one"}, {0 => "zero"}]},
    "read_only" => "1"
  };
  my ($textfield) = $c->form_fields( $config_name, %$entity);
  $c->render(text => $textfield);
};

my $close = Mojolicious->VERSION >= 5.73 ? '' : " /";

my $t = Test::Mojo->new;
$t->get_ok('/done/0')->status_is(200)->content_is("no");
$t->get_ok('/done/1')->status_is(200)->content_is("yes");
$t->get_ok('/overridden_hash')->status_is(200)->content_is("oh");
$t->get_ok('/overridden_array')->status_is(200)->content_is("0");
$t->get_ok('/overridden_aoh')->status_is(200)->content_is("zero");
$t->get_ok('/overridden_multi')->status_is(200)->content_is("one, zero");


done_testing();

