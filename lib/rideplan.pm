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
  if(!session('username'))
  {
    if(request->path !~ m{^/$} and
      request->path !~ m{^/[a-z]*login})
    {
      #warning "unauth req".(request->path);
      #forward '/templogin';
      redirect uri_for('/templogin');
      #TODO: preserve original request
    }
  }
};

sub getfootlinks {
  my $anon_links = [
    { name => "Home", link => uri_for('/') },
    { name => "Login", link=>uri_for('/templogin') }
    ];

  my $auth_links = [
    { name => "Dashboard", link => uri_for('/dashboard') },
    { name => "Create New Ride", link => uri_for('/ride/new') },
    { name => "Logout", link=>uri_for('/templogout') }

  ];

  if(session('username'))
  {
    return $auth_links;
  }
  else
  {
    return $anon_links;
  }
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
  my $rides = $db->get_ride_data;
  foreach my $r (@$rides)
  {
    $r->{url} = uri_for('/ride/'.$r->{id});
  }

  my $data = { title => 'Dashboard',
    rides => $rides,
    footlinks => getfootlinks()
  };
  if(session('username'))
  {
    $data->{ username } = session('username');
  }
  template('dashboard', $data);
};

get '/ride/:id' => sub {
  my $id = route_parameters->get('id');
  $db->init("SQLite", $ENV{'SQLITE_DB'});
  my $ridearray = $db->get_ride_data($id);
  my $riders = $db->get_rider_list($id);
  if(not scalar(@$ridearray))
  {
    send_error("Not found", 404);
  }
  my $ride = $ridearray->[0];

  if(@$riders)
  {
    $ride->{riderlist} = $riders;
  }

  template('viewride', { title => $ride->{name}, footlinks => getfootlinks(), ride => $ride });
};

get '/ride/:id/edit' => sub {
  my $id = route_parameters->get('id');
  $db->init("SQLite", $ENV{'SQLITE_DV'});
  my $ridearray = $db->get_ride_data($id);
  my $riders = $db->get_rider_list($id);
  if(not scalar(@$ridearray))
  {
    send_error("Not found", 404);
  }
  my $ride = $ridearray->[0];

  if(@$riders)
  {
    $ride->{riderlist} = $riders;
  }

  template('editride', { title => $ride->{name}."(Edit)", footlinks => getfootlinks(), ride => $ride });
};

get '/ride/new' => sub {
  template('newride', { title => 'Create New Ride', footlinks => getfootlinks() });
};

post '/ride/:id/edit' => sub {
  my $id = route_parameters->get("id");
  my $name = body_parameters->get("name");
  my $loc = body_parameters->get("location");
  my $miles = body_parameters->get("miles");
  my $start = body_parameters->get("start");
  my $end = body_parameters->get("end");

  $db->init("SQLite", $ENV{'SQLITE_DB'});
  $db->update_ride($id, $name, $loc, $miles, $start, $end);
  redirect uri_for('/ride/'.$id);
};

post '/ride/new' => sub {
  my $name = body_parameters->get("name");
  my $loc = body_parameters->get("location");
  my $miles = body_parameters->get("miles");
  my $start = body_parameters->get("start");
  my $end = body_parameters->get("end");

  $db->init("SQLite", $ENV{'SQLITE_DB'});
  $db->create_ride($name, $loc, $miles, $start, $end);
  redirect uri_for('/dashboard');
};

1;
