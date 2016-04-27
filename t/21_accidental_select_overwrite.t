#!/usr/bin/env perl

use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;
use File::Basename;
use File::Spec;

plugin 'FormFieldsFromJSON' => {
  dir                => File::Spec->catdir( dirname( __FILE__ ) || '.', 'conf' ),
  template           => '<%= $field %>',
};

my $config_name = basename __FILE__;
$config_name    =~ s{\A \d+_ }{}xms;
$config_name    =~ s{\.t \z }{}xms;

get '/preselect' => sub {
  my $c = shift;
  my ($selectfield) = $c->form_fields( $config_name."_preselect");
  $c->render(text => $selectfield);
};

get '/preselect_overwrite' => sub {
  my $c = shift;
  my ($selectfield) = $c->form_fields( $config_name."_preselect", status => {data => 'inactive'});
  $c->render(text => $selectfield);
};

get '/overwrite' => sub {
  my $c = shift;
  my ($selectfield) = $c->form_fields( $config_name , status => {data => 'inactive'});
  $c->render(text => $selectfield);
};

get '/' => sub {
  my $c = shift;
  my ($selectfield) = $c->form_fields( $config_name );
  $c->render(text => $selectfield);
};

my $t = Test::Mojo->new;
$t->get_ok('/preselect')
  ->status_is(200)
  ->content_is(qq~<select id="status" name="status"><option selected value="active">active</option><option value="inactive">inactive</option></select>\n~);

$t->get_ok('/preselect_overwrite')
  ->status_is(200)
  ->content_is(qq~<select id="status" name="status"><option value="active">active</option><option selected value="inactive">inactive</option></select>\n~);

$t->get_ok('/overwrite')
  ->status_is(200)
  ->content_is(qq~<select id="status" name="status"><option value="active">active</option><option selected value="inactive">inactive</option></select>\n~);

# make sure selected overwrite not persists
$t->get_ok('/')
  ->status_is(200)
  ->content_is(qq~<select id="status" name="status"><option value="active">active</option><option value="inactive">inactive</option></select>\n~);

done_testing();

