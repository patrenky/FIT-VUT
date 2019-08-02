#!/usr/bin/perl

use strict;
use warnings;
use modules::Graph;

my @lines;

while (<STDIN>) {
	chomp;
	push @lines, $_;
}

my $total_group = 0;
my $start = "M01";
my $finish = "EXIT";
my $graph = new Graph();

foreach my $line (@lines) {
	unless ($total_group) {
		if ($line =~ /(\w+):\s(\d+)/) {
			$start = $1;
			$total_group = $2;
		}
	} elsif ($line =~ /\w+:\s(\w+)\s>\s(\w+)\s(\d+)/) {
		if (int($3) < 1) {
			die "Value $1 > $2 should be positive\n";
		}
		$graph->addBidirectEdge($1, $2, $3);
	}
}

my ($max_flow, $cycles) = $graph->maxFlow($total_group, $start, $finish);

print "Group size: $max_flow\n";

foreach my $line (@lines) {
	if ($line =~ /(\w+):\s(\w+)\s>\s(\w+)\s(\d+)/) {
		my $door = $1;
		my $from = $2;
		my $to = $3;
		my $capacity = $4;

		if ( int($graph->{$from}->{$to}) < int($capacity) ) {
			print "$door: " . $graph->{$from}->{$to} . "\n";
		} else {
			print "$door: ]" . $capacity . "[\n";
		}
	}
}

print "Time: $cycles\n";
