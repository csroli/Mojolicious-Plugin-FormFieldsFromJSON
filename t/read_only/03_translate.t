#!/usr/bin/env perl

use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;
use File::Basename;
use File::Spec;

plugin 'FormFieldsFromJSON' => {
  dir => File::Spec->catdir( dirname( __FILE__ ) || '.', 'conf' ),
  translate_labels   => 1,
  translate_options   => 1,
  translation_method => \&loc,
};

sub loc {
    my ($c, $value) = @_;

    my %translation = ( yes => 'Ja' , no => "Nein", oh => "Nicht");
    return $translation{$value} // $value;
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

my $close = Mojolicious->VERSION >= 5.73 ? '' : " /";

my $t = Test::Mojo->new;
$t->get_ok('/done/0')->status_is(200)->content_is("Nein");
$t->get_ok('/done/1')->status_is(200)->content_is("Ja");
$t->get_ok('/overridden_hash')->status_is(200)->content_is("Nicht");


done_testing();

