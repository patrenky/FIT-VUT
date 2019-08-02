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

my $network = new Network();

$network->createNetwork(\@lines);

$network->printMinimal();
