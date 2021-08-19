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

#NOTE: this utility emulates 3 separate hosts
  #accounts.google.com
  #oauth2.googleapis.com
  #currently unknown profile service url

#google has an "OAuth 2.0 Playground" for testing
#there is a link in the "Web Server: OAuth 2.0" developer documentation page

# API name: Google OAuth2 API v2
# https://www.googleapis.com/auth/userinfo.email
# https://www.googleapis.com/auth/userinfo.profile

get '/' => sub {
  return "use /1 /2 or /3 for auth, token, and profile respectively";
};

get '/1' => sub {
  return "/o/oauth2/v2/auth (state, redirect_uri, client_id, response_type".
    ", scope, access_type";
};

get '/o/oauth2/v2/auth' => sub {
  my @params_needed = ('state', 'redirect_uri', 'client_id', 'response_type',
    'scope', 'access_type');
  debug request->query_parameters;
  for my $param (@params_needed)
  {
    my $temp = query_parameters->get($param);
    if($temp)
    {
      session $param => $temp;
    }
    else
    {
      send_error("Missing param $param", 400);
    }
  }

  return $html;
};

#TODO: not working correctly...
get '/accept' => sub {
  my $uri = URI->new( session('redirect_uri') );
  my $params = {
    code => '4/P7q7W91a-oMsCeLvIaQm6bTrgtp7',
    state => session('state')
  };
  $uri->query_form($params);
  redirect $uri;
};

get '/decline' => sub {
  redirect session('redirect_uri'), { error => 'access_denied' };
};

get '/2' => sub {
  return "/token body(code, redirect_uri";
};

get '/3' => sub {
  send_error("profile access not implemented", 400);
};

post '/token' => sub {
  my $code = body_parameters->get('code');
  my $redirect = body_parameters->get('redirect_uri');

  my $retval = {
    'access_token' => '1/fFAGRNJru1FTz70BzhT3Zg',
    'expires_in' => 3920,
    'token_type' => 'Bearer',
    'scope' => 'https://www.googleapis.com/auth/drive.metadata.readonly',
    'refresh_token' => '1//xEoDL4iW3cxlI7yDbSRFYNG01kVKM2C-259HOF2aQbI'
  };

  return encode_json($retval);
};

dance;
