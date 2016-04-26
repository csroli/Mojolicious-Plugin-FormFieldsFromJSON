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
	translate_options => 1,
  translation_method => \&loc,
};

my $config_name = basename __FILE__;
$config_name    =~ s{\A \d+_ }{}xms;
$config_name    =~ s{\.t \z }{}xms;

get '/array' => sub {
  my $c = shift;
  my ($selectfield) = $c->form_fields( $config_name."_array" );
  $c->render(text => $selectfield);
};

get '/hash' => sub {
  my $c = shift;
  my ($selectfield) = $c->form_fields( $config_name."_hash" );
  $c->render(text => $selectfield);
};

get '/global' => sub {
  my $c = shift;
  my ($selectfield) = $c->form_fields( $config_name."_global" );
  $c->render(text => $selectfield);
};

sub loc {
    my ($c, $value) = @_;

    my %translation = ( 
			active => 'Active',  
			inactive => 'Inactive'
		);
    return $translation{$value} // $value;
};

my $close = Mojolicious->VERSION >= 5.73 ? '' : " /";

my $t = Test::Mojo->new;
$t->get_ok('/array')
  ->status_is(200)
  ->content_is(qq~<label for="status">Status:</label><div><select id="status" name="status"><option value="active">Active</option><option value="inactive">Inactive</option></select></div>\n~);

$t->get_ok('/hash')
  ->status_is(200)
  ->content_is(qq~<label for="status">Status:</label><div><select id="status" name="status"><option value="0">Inactive</option><option value="1">Active</option></select></div>\n~);

$t->get_ok('/global')
  ->status_is(200)
  ->content_is(qq~<label for="status">Status:</label><div><select id="status" name="status"><option value="active">Active</option><option value="inactive">Inactive</option></select></div>\n~);

done_testing();

