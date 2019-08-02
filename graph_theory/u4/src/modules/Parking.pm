#!/usr/bin/perl

use strict;
use warnings;

package Parking;


sub new {
	my ($class, $name, $x, $y, $capacity) = @_;

	my $obj = {
		name => $name,
		x => $x,
		y => $y,
		capacity => $capacity,
		parked => 0
	};
	bless $obj, $class;

	return $obj;
}


1;
