#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use modules::Network;

my @lines;

while (<STDIN>) {
	chomp;
	push @lines, $_;
}

my $full_network = new Network();
$full_network->createNetwork(\@lines);

my $valid = $full_network->countClusters();

if ($valid > 1) {
	die "Invalid graph\n";
}

# in each cycle remove input line and create new network
foreach my $i (0 .. scalar @lines - 1) {
	if ($lines[$i] =~ /(\w+)\s?-\s?(\w+):\s(\d+)/) {
		my $from = $1;
		my $to = $2;

		my $network = new Network();
		$network->createNetwork(\@lines);
		$network->removeWire($from, $to);

		my $clusters = $network->countClusters();

		if ($clusters > 1) {
			print "$from - $to\n";
		}
	}
}

# remove individual transformators
foreach my $transformator ($full_network->getTransformators()) {
	my $network = new Network();
	$network->createNetwork(\@lines);
	$network->removeTransformator($transformator);

	my $clusters = $network->countClusters();

	if ($clusters > 1) {
		print "$transformator\n";

	}
}
