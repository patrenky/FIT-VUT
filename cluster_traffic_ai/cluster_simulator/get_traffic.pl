#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

require './modules/file_actions.pl';

my $traffic_data = getTrafficJson();
print $traffic_data . "\n";
