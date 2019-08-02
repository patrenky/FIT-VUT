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
	if ($line =~ /(\w+)\s-\s(\w+)/) {
		$graph->addBidirectEdge($1, $2, 1);
	}
}

my $groups = $graph->greedy();

my %printed = ();

foreach my $v (keys %$graph) {
	$printed{$v} = 0;
}

foreach my $v (keys %$graph) {
	my $line = "";
	foreach my $u (keys %$graph) {
		if ($groups->{$u} eq $v) {
			$line .= "$u ";
		}
	}
	if (length($line)) {
		print "$line\n";
	}
}

