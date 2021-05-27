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

sub getfootlinks {
  my $footlinks = [
    { name => "Home", link => uri_for('/') },
    { name => "Dashboard", link => uri_for('/dashboard') },
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
  my $data = { title => 'Dashboard',
    rides => [
      { name => 'Flint Hills Ride' },
      { name => 'Kevins bday' }
    ],
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
};

1;
