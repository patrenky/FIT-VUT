#!/usr/bin/perl

use strict;
use warnings;
use modules::Graph;

my @lines;

while (<STDIN>) {
	chomp;
	push @lines, $_;
}


my $graph = new Graph();

foreach my $line (@lines) {
	if ($line =~ /(\w+)\s-\s(\w+):\s(\d+)/) {
		if (int($3) < 1) {
			die "Value $1 - $2 should be positive\n"; # TODO check this
		}
		$graph->addBidirectEdge($1, $2, $3);
	}
}

$graph->countClusters();

my $distances = $graph->dijskra("Vy");

foreach my $node (sort { $distances->{$a} <=> $distances->{$b} } keys %$distances) {
	my $distance = $distances->{$node};
	print "$node: " . ($distance ? "-$distance" : "$distance") . "\n";
}
