#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Graph;

#
# Spracovanie STDIN
#

my $inputA;
my $inputB;

my $line = 1;

while (<STDIN>) {
	chomp;
	if ($line == 1) {
		$inputA = $_;
	} elsif ($line == 2) {
		$inputB = $_;
	}

	$line++;
}

my @inputA = split(/,\s?/, $inputA);
my @inputB = split(/,\s?/, $inputB);


#
# Vytvorenie atomu A
#

my $graphA = new Graph();

foreach my $edge (@inputA) {
	my ($from, $to);

	if ($edge =~ /([\w]+)-.*/) {
		$from = $1;
	}
	if ($edge =~ /.*-([\w]+)/) {
		$to = $1;
	}

	if ($from and $to) {
		$graphA->addVertex($from);
		$graphA->addVertex($to);
		$graphA->addEdgeBidirect($from, $to);
	}
}

# TODO reomove
# $graphA->printGraph("ATOM A");


#
# Vytvorenie atomu B
#

my $graphB = new Graph();

foreach my $edge (@inputB) {
	my ($from, $to);

	if ($edge =~ /([\w]+)-.*/) {
		$from = $1;
	}
	if ($edge =~ /.*-([\w]+)/) {
		$to = $1;
	}

	if ($from and $to) {
		$graphB->addVertex($from);
		$graphB->addVertex($to);
		$graphB->addEdgeBidirect($from, $to);
	}
}

# TODO reomove
# $graphB->printGraph("ATOM B");


#
# Porovnanie uzlov a hran
#


sub boolToString {
	my ($bool) = @_;
	return $bool ? "true" : "false";
}

print("* |U1| = |U2|: " .  boolToString($graphA->getVertices() == $graphB->getVertices()). "\n");
print("* |H1| = |H2|: " .  boolToString($graphA->getNumEdges() == $graphB->getNumEdges()). "\n");


# 
# Porovnanie postupnosti uzlov
# 

my %vertex_followers = ();

foreach my $vertexA ($graphA->getVertices()) {
	$vertex_followers{$vertexA} = scalar $graphA->getVerticesOf($vertexA);
}

foreach my $vertexB ($graphB->getVertices()) {
	foreach my $vertexA (keys %vertex_followers) {
		if (scalar $graphB->getVerticesOf($vertexB) == $vertex_followers{$vertexA}) {
			$vertex_followers{$vertexA} = 0;
			next;
		}
	}
}

my $same_followers = 1;

foreach my $vertexA (keys %vertex_followers) {
	if ($vertex_followers{$vertexA}) {
		$same_followers = 0;
		last;
	}
}

print("* Grafy mají stejnou posloupnost stupňů uzlů: " .  boolToString($same_followers). "\n");
print("* Pak pro každý uzel v z U platí\n");
print("  – stupeň uzlu v je roven stupni uzlu φ(v): " . boolToString($same_followers). "\n");


# TODO
# * Jsou-li u, v sousední uzly, pak i (u), (v) jsou sousední uzly: false
# * Pak pro každý uzel v z U platí
# – stupeň uzlu v je roven stupni uzlu φ(v): false
# – množina stupňů sousedů uzlu v je rovna množině stupňů sousedů uzlu φ(v): false
# * Pak pro každý sled platí
# – obraz sledu je opět sled: false
# – obraz tahu je opět tah: true
# – obraz cesty je opět cesta: true
# – délka sledu zůstává zachována: false

