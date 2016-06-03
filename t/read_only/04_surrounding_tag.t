#!/usr/bin/env perl

use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;
use File::Basename;
use File::Spec;

plugin 'FormFieldsFromJSON' => {
  dir => File::Spec->catdir( dirname( __FILE__ ) || '.', 'conf' ),
  static_tag => 'span'
};

my $config_name = basename __FILE__;
$config_name    =~ s{\A \d+_ }{}xms;
$config_name    =~ s{\.t \z }{}xms;

get '/surround_with_tag' => sub {
  my $c = shift;
  my $entity = {
    "fee" => {data => 100},
    "read_only" => "1"
  };
  my ($textfield) = $c->form_fields( $config_name, %$entity);
  $c->render(text => $textfield);
};

get '/surround_empty_value' => sub {
  my $c = shift;
  my $entity = {
    "read_only" => "1"
  };
  my ($textfield) = $c->form_fields( $config_name, %$entity);
  $c->render(text => $textfield);
};

my $close = Mojolicious->VERSION >= 5.73 ? '' : " /";

my $t = Test::Mojo->new;
$t->get_ok('/surround_with_tag')->status_is(200)->content_is('<span class="number">100</span>');
$t->get_ok('/surround_empty_value')->status_is(200)->content_is('<span class="number">&nbsp;</span>');
 
done_testing();

