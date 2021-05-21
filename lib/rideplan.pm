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

my $footlinks = [
  { name => "Home", link => uri_for('/') },
  { name => "Dashboard", link => uri_for('/dashboard') },
  { name => "Login", link=>uri_for('/templogin') },
  { name => "Logout", link=>uri_for('/templogout') }

];

get '/' => sub {
  template('index', { title=>'RidePlan Home', footlinks => $footlinks });
};

get '/templogin' => sub {
  template('templogin', { title => 'Login', loginurl => uri_for('/templogin'), footlinks => $footlinks } );
};

post '/templogin' => sub {
  session 'username' => body_parameters->get('username');
  redirect uri_for('/dashboard');
};

post '/templogout' => sub {
  app->destroy_session;
  redirect uri_for('/');
};

get '/dashboard' => sub {
  my $data = { title => 'Dashboard',
    rides => [
      { name => 'Flint Hills Ride' },
      { name => 'Kevins bday' }
    ],
    username => session('username'),
    footlinks => $footlinks
  };
  template('dashboard', $data);
};

1;
