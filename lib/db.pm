#
#===============================================================================
#
#         FILE: db.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 05/22/2021 03:54:23 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

package db;
use Moo;

has is_initialized => ( is => 'rw' );
has dbd_type => ( is => 'rw' );
has handle => ( is => 'rw' );

use DBI;
use Carp;

sub init
{
  my $self = shift;
  my $type = shift;
  my $filepath = shift;
  if($type ne 'SQLite')
  {
    croak "only SQLite is currently supported\n";
  }
  if($self->is_initialized)
  {
    return;
  }
  $self->dbd_type($type);
  my $dbh = DBI->connect("dbi:SQLite:dbname=$filepath", "", "") or croak $DBI::errstr;
  $self->handle($dbh);
  $self->is_initialized(1);
}

sub get_ride_data
{
  my $self = shift;
  croak "not initialized" unless $self->is_initialized;

  my $sql = "select id, name, miles, regionloc from ride";

  my $sth = $self->handle->prepare($sql) or croak $self->handle->errstr;
  $sth->execute or croak $sth->errstr;

  my $retval = [];
  my $row = {};
  while($row = $sth->fetchrow_hashref)
  {
    push @$retval, $row;
  }
  return $retval;
}

1;
