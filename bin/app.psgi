#!/usr/bin/env perl
use warnings; use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";

use rideplan;

rideplan->to_app;
