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
my $start = "";
my $finish = "";

foreach my $line (@lines) {
	if ($line =~ /(\w+)(\+)?:\s(.*)/) {
		my $from = $1;
		my $bonus = $2;
		my @routes = split(/,\s?/, $3);

		$start = $from unless $start;
		$finish = $from;

		foreach my $route (@routes) {
			if ($route =~ /(\w+)\((\-?\d+)\)/) {
				my $to = $1;
				my $cost = int($2);
				$cost = $bonus ? $cost + 1 : $cost;

				$graph->addDirectEdge($from, $to, -$cost);
			}
		}
	}
}

$graph->countClusters();

my $steps = $graph->bellmanFord($start);

my $cost = 0;
my $path = "$finish";
my $step = $finish;

foreach my $i (0 .. scalar keys %$graph) {
	my $new_step = $steps->{$step};
	if ($new_step) {
		$path .= " - $new_step";
		$cost += -$graph->{$new_step}->{$step};
	}
	$step = $new_step;
}

print reverse($path) . ": $cost\n";
