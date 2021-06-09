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
use Dancer2;

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
  debug "database handle initialized";
}

sub get_ride_data
{
  my $self = shift;
  my $id = shift;
  croak "not initialized" unless $self->is_initialized;

  my $sql; 
  if($id)
  {
    $sql = "select * from ride where id = ?";
  }
  else
  {
    $sql = "select id, name, miles, regionloc from ride";
  }

  my $sth = $self->handle->prepare($sql) or croak $self->handle->errstr;
  if($id)
  {
    $sth->execute($id) or croak $sth->errstr;
  }
  else
  {
    $sth->execute or croak $sth->errstr;
  }

  my $retval = [];
  my $row = {};
  while($row = $sth->fetchrow_hashref)
  {
    push @$retval, $row;
  }
  return $retval;
}

sub _get_new_ride_id
{
  my $dbh = shift;
  my $sth = $dbh->prepare("select max(id) as lastid from ride")
    or croak $dbh->errstr;
  $sth->execute or croak $sth->errstr;
  my $row = $sth->fetchrow_hashref or croak $sth->errstr;
  my $keyct = scalar(keys %$row);
  #carp "returned $keyct cols\n";
  #carp join ",", keys %$row;
  #carp "\n";
  my $max = $row->{lastid};
  #carp "max id for ride is $max\n";
  return 1 + $max;
}

sub create_ride
{
  my $self=shift;
  my ($name, $loc, $miles, $start, $end) = @_;
  croak "at least one missing: name, loc, miles\n" 
      unless ($name && $loc && $miles);
  croak "not initialized" unless $self->is_initialized;
  my $newid = _get_new_ride_id($self->handle);
  #carp "newid for ride is $newid\n";
  my $sql = "insert into ride (id, name, regionloc, miles, start, end) values (?, ?, ?, ?, ?, ?)";

  my $sth = $self->handle->prepare($sql) or croak $self->handle->errstr;

  $sth->execute($newid, $name, $loc, $miles, $start, $end) or croak $sth->errstr;
}

1;
