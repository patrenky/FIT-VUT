#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Graph;

#
# Spracovanie STDIN
#

my $verticesA;
my $verticesB;
my @edges;

my $line = 1;

while (<STDIN>) {
	chomp;
	if ($line == 1) {
		$verticesA = $_;
	} elsif ($line == 2) {
		$verticesB = $_;
	} else {
		push @edges, $_;
	}

	$line++;
}

my @verticesA = split(/,\s?/, $verticesA);
my @verticesB = split(/,\s?/, $verticesB);

#
# Vytvorenie grafu ciest prvej firmy zjednotenych
# s cestami druhej firmy
#

my $fullGraph = new Graph();

$fullGraph->addVertices(@verticesA);
$fullGraph->addVertices(@verticesB);

foreach my $edge (@edges) {
	my ($from, $to);

	if ($edge =~ /([\w]+)\s?->.*/) {
		$from = $1;
	}
	if ($edge =~ /.*->\s?([\w]+)/) {
		$to = $1;
	}

	if ($from and $to) {
		$fullGraph->addEdgeDirect($from, $to);
	}
}

#
# Vytvorenie redukovaneho grafu ktoreho uzly su v kapitalkach
# a na zaklade tohoto grafu vyhodnocovanie nepotrebnych ciest
#

my $reducedGraph = new Graph();
my $usedPaths = "";
my $unusedPaths = "";

foreach my $from ($fullGraph->getVertices()) {
	foreach my $to ($fullGraph->getVerticesOf($from)) {
		my $ucFrom = uc($from);
		my $ucTo =  uc($to);

		$reducedGraph->addVertex($ucFrom);
        $reducedGraph->addVertex($ucTo);

        unless ($reducedGraph->haveVertex($ucFrom, $ucTo)) {
            $reducedGraph->addEdgeDirect($ucFrom, $ucTo);
            $usedPaths .= "$from -> $to\n";
        } else {
            $unusedPaths .= "$from -> $to\n";
        }
	}
}

print($usedPaths);
print("----\n");
print($unusedPaths);
