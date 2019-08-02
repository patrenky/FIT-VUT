#!/usr/bin/perl

use strict;
use warnings;
use modules::Graph;
use Data::Dumper;

my @lines;
my $start = "";

while (<STDIN>) {
	chomp;
	push @lines, $_;
}


my $graph = new Graph();

foreach my $line (@lines) {
	if ($line =~ /(\w+)\s-\s(\w+):\s(\d+)/) {
        $graph->addBidirectEdge($1, $2, $3);
		$start = $1 unless $start;
	}
}

$graph->countClusters();

my $path = $graph->eulerPath($start);
print $path;
