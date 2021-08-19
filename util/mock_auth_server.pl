#!/usr/bin/env perl
#===============================================================================
#
#         FILE: mock_auth_server.pl
#
#        USAGE: ./mock_auth_server.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 08/19/2021 03:53:34 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use Dancer2;

my $html = "<html><body>Login in using google account \"lisa\"?".
  "<a href=\"/accept\">accept</a><a href=\"decline\">decline</a>".
  "</body></html>";

#NOTE: this utility emulates 2 separate hosts
  #accounts.google.com
  #oauth2.googleapis.com

get '/o/oauth2/v2/auth' => sub {
  for my $param (('state', 'redirect_uri', 'client_id'))
  {
    session $param => query_parameters->get($param);
  }

  return $html;
};

get '/accept' => sub {
  redirect session('redirect_uri'), { code => '4/P7q7W91a-oMsCeLvIaQm6bTrgtp7' };
};

get '/decline' => sub {
  redirect session('redirect_uri'), { error => 'access_denied' };
};

post '/token' => sub {
  send_error("Not implemented", 500);
};

dance;
