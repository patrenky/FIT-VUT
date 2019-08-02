#!/usr/bin/perl

use strict;
use warnings;

package Building;


sub new {
	my ($class, $name, $x, $y, $cars) = @_;

	my $obj = {
		name => $name,
		x => $x,
		y => $y,
		cars => $cars,
		parked => 0
	};
	bless $obj, $class;

	return $obj;
}


1;
