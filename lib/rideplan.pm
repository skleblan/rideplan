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
  { name => "Dashboard", link => uri_for('/dashboard') }
];

get '/' => sub {
  template('index', { title=>'RidePlan Home', footlinks => $footlinks });
};

get '/dashboard' => sub {
  my $data = { title => 'Dashboard',
    rides => [
      { name => 'Flint Hills Ride' },
      { name => 'Kevins bday' }
    ],
    footlinks => $footlinks
  };
  template('dashboard', $data);
};

1;
