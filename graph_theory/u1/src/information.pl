#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Graph;

#
# Spracovanie STDIN
#

my $vertices;
my @edges;

my $line = 1;

while (<STDIN>) {
	chomp;
	if ($line == 1) {
		$vertices = $_;
	} else {
		push @edges, $_;
	}

	$line++;
}

my @vertices = split(/,\s?/, $vertices);

#
# Graf priatelstiev na soc. sieti
#

my $graph = new Graph();

$graph->addVertices(@vertices);

foreach my $edge (@edges) {
	my ($from, $to);

	if ($edge =~ /([\w]+)\s?-.*/) {
		$from = $1;
	}
	if ($edge =~ /.*-\s?([\w]+)/) {
		$to = $1;
	}

	if ($from and $to) {
		$graph->addEdgeBidirect($from, $to);
	}
}

# hladanie uzlu s najvacsim stupnom uzlov

my $max_vertices = 0;

foreach my $vertex (@vertices) {
	my $vertex_neighbors = scalar $graph->getVerticesOf($vertex);
	if ($vertex_neighbors > $max_vertices) {
		$max_vertices = $vertex_neighbors;
	}
}


sub mergeArrays {
	my (@A, @B) = @_;

	my %seen;
	return grep( !$seen{$_}++, @A, @B);
}

#
# Cyklus v ktorom sa vypisuju uzivatelia zostupne podla poctu priatelov
# a zaroven sa vytvara siet ludi, ktorych poznaju 3 ludia s najvacsim
# poctom priatelov
#

my @cluster_vertices = ();
my @cluster_neighbors = ();

print("Task 1:\n");

while ($max_vertices >= 0) {
	foreach my $vertex (@vertices) {
		my @vertex_neighbors = $graph->getVerticesOf($vertex);

		if (scalar @vertex_neighbors == $max_vertices) {
			print($vertex . " (" . scalar @vertex_neighbors . ")\n");

			if (scalar @cluster_vertices < 3) {
				push(@cluster_vertices, $vertex);
				@cluster_neighbors = mergeArrays(@cluster_neighbors, @vertex_neighbors);
			}
		}
	}

	$max_vertices--;
}

# prepocitanie unikatnych uzivatelov (odstranenie duplicit)

my $uniq_neighbors = 0;

foreach my $neighbor (@cluster_neighbors) {
	unless ( grep( /^$neighbor$/, @cluster_vertices ) ) {
		$uniq_neighbors++;
	}
}

print("\nTask 2:\n");

print(join(", ", @cluster_vertices));
print(" (" . $uniq_neighbors . ")");
print("\n");
