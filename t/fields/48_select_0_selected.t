#!/usr/bin/env perl

use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;
use File::Basename;
use File::Spec;

Test::More::diag( Mojolicious->VERSION );

plugin 'FormFieldsFromJSON' => {
  dir => File::Spec->catdir( dirname( __FILE__ ) || '.', 'conf' ),
};

my $selected = Mojolicious->VERSION < 6.16 ? '="selected"' : '';

my $config_name = basename __FILE__;
$config_name    =~ s{\A \d+_ }{}xms;
$config_name    =~ s{\.t \z }{}xms;

get '/' => sub {
  my $c = shift;
  my ($field) = $c->form_fields( $config_name, choose => { selected => 0 } );
  $c->render(text => $field);
};

my $t = Test::Mojo->new;
$t->get_ok('/')->status_is(200)->content_is(join '',
  '<select id="choose" name="choose">',
  qq~<option selected$selected value="0">No</option>~,
  '<option value="1">Yes</option>',
  '</select>',
);

done_testing();

