#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

require './modules/file_actions.pl';

my @updates = @ARGV;
# $updates[0] = "nodes=3";

my $topology = getTopology();

foreach my $update (@updates) {
	if ($update =~ /(.*)=(.*)/) {
		my $key = $1;
		my $value = $2;

		$topology->{$key} = $value;
	} else {
		warn("invalid topology update '$update'");
	}
}

# print Dumper $topology;

updateTopology($topology);
