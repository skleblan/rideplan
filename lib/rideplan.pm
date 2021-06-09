#!/usr/bin/env perl
#===============================================================================
#
#         FILE: rideplan.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 04/28/2021 12:03:25 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

package rideplan;
use Dancer2;
use db;

my $db = db->new;

hook before => sub {
  die "Missing SQLITE_DB env var" unless $ENV{'SQLITE_DB'};
};

sub getfootlinks {
  my $footlinks = [
    { name => "Home", link => uri_for('/') },
    { name => "Dashboard", link => uri_for('/dashboard') },
    { name => "Create New Ride", link => uri_for('/ride/new') },
    { name => "Login", link=>uri_for('/templogin') },
    { name => "Logout", link=>uri_for('/templogout') }

  ];
  return $footlinks;
}

get '/' => sub {
  template('index', { title=>'RidePlan Home', footlinks => getfootlinks() });
};

get '/templogin' => sub {
  template('templogin', { title => 'Login', loginurl => uri_for('/templogin'), footlinks => getfootlinks() } );
};

post '/templogin' => sub {
  session 'username' => body_parameters->get('username');
  redirect uri_for('/dashboard');
};

get '/templogout' => sub {
  app->destroy_session;
  redirect uri_for('/');
};

get '/dashboard' => sub {
  $db->init("SQLite", $ENV{'SQLITE_DB'});

  my $data = { title => 'Dashboard',
    rides => $db->get_ride_data,
    footlinks => getfootlinks()
  };
  if(session('username'))
  {
    $data->{ username } = session('username');
  }
  template('dashboard', $data);
};

get '/ride/new' => sub {
  template('newride', { title => 'Create New Ride', footlinks => getfootlinks() });
};

post '/ride/new' => sub {
  my $name = body_parameters->get("name");
  my $loc = body_parameters->get("location");
  my $miles = body_parameters->get("miles");

  $db->init("SQLite", $ENV{'SQLITE_DB'});
  $db->create_ride($name, $loc, $miles);
  redirect uri_for('/dashboard');
};

1;
