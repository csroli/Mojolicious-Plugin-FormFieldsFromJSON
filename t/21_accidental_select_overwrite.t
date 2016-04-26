#!/usr/bin/env perl

use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;
use File::Basename;
use File::Spec;

plugin 'FormFieldsFromJSON' => {
  dir                => File::Spec->catdir( dirname( __FILE__ ) || '.', 'conf' ),
  template           => '<label for="<%= $id %>"><%= $label %>:</label><div><%= $field %></div>',
};

my $config_name = basename __FILE__;
$config_name    =~ s{\A \d+_ }{}xms;
$config_name    =~ s{\.t \z }{}xms;

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
$t->get_ok('/overwrite')
  ->status_is(200)
  ->content_is(qq~<label for="status">Status:</label><div><select id="status" name="status"><option value="active">active</option><option selected value="inactive">inactive</option></select></div>\n~);

# make sure selected overwrite not persists
$t->get_ok('/')
  ->status_is(200)
  ->content_is(qq~<label for="status">Status:</label><div><select id="status" name="status"><option value="active">active</option><option value="inactive">inactive</option></select></div>\n~);

done_testing();

