#!/usr/bin/perl

use strict;
use warnings;
use modules::Graph;
use modules::Parking;
use modules::Building;
use Data::Dumper;

my @lines;

while (<STDIN>) {
	chomp;
	push @lines, $_;
}

my $graph = new Graph();
my %parkings = ();
my %buildings = ();

# first check all parkings
foreach my $line (@lines) {
	if ($line =~ /(P\d+)\s(\d+),(\d+):\s(\d+)/) {
		$parkings{$1} = new Parking($1, $2, $3, $4);
	}
}


sub distance {
	my ($x1, $y1, $x2, $y2) = @_;
	return sqrt( ((int($x2) - int($x1) )**2) + ((int($y2) - int($y1) )**2));
}

# second check all buildings and distances
foreach my $line (@lines) {
	if ($line =~ /(B\d+)\s(\d+),(\d+):\s(\d+)/) {
		my $name = $1;
		my $x = $2;
		my $y = $3;
		my $cars = $4;
		$buildings{$name} = new Building($name, $x, $y, $cars);

		# count distances between buildings and each parking
		foreach my $parking (keys %parkings){
			my $distance = distance($parkings{$parking}->{x}, $parkings{$parking}->{y}, $x, $y);
			$graph->addDirectEdge($distance, $name, $parkings{$parking}->{name});
		}
	}
}

my $total = 0;

# in sorted distances
foreach my $dist (reverse sort { $a <=> $b } keys %$graph ) {
	foreach my $building (keys %{$graph->{$dist}}) {
		my $parking = $graph->{$dist}->{$building};

		# try to park car
		foreach my $car ($buildings{$building}->{parked} + 1 .. $buildings{$building}->{cars}) {
			if ($parkings{$parking}->{parked} < $parkings{$parking}->{capacity}) {
				print $building . "_" . ($buildings{$building}->{parked} + 1);
				print " " . $parking . "_" . $car;
				print " " . int($dist) . "\n";

				$buildings{$building}->{parked}++;
				$parkings{$parking}->{parked}++;

				$total += int($dist);
			}
		}
	}
}

print "Celkem: $total\n";
