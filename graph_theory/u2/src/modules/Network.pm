#!/usr/bin/perl

use strict;
use warnings;

package Network;

# ###########################################
# class representing transformators network
# connected with wires, including algorithms
# ###########################################

# Network structure:

# $network: {
# 	$from: {
# 		$to : $failures
# 	}
# }


sub new {
	my ($class) = @_;

	my $graph = {};
	bless $graph, $class;

	return $graph;
}


# parse input lines and fill network struct
sub createNetwork {
	my ($graph, $lines) = @_;

	foreach my $line (@$lines) {
		if ($line =~ /(\w+)\s?-\s?(\w+):\s(\d+)/) {
			$graph->addTransformator($1);
			$graph->addTransformator($2);
			$graph->addWire($1, $2, $3);
		}
	}
}


# add transformator node
sub addTransformator {
	my ($graph, $vertex) = @_;

	unless ($graph->{$vertex}) {
		$graph->{$vertex} = {};
	}

	return $graph;
}


# remove transformator node and it's connections with other nodes
sub removeTransformator {
	my ($graph, $vertex) = @_;

	foreach my $transformator ($graph->getTransformators()) {
		if (exists $graph->{$transformator}->{$vertex}) {
			delete $graph->{$transformator}->{$vertex};
		}
	}

	if (exists $graph->{$vertex}) {
		delete $graph->{$vertex};
	}

	return $graph;
}


# add wire bidirectional - edge between two nodes
sub addWire {
	my ($graph, $from, $to, $failures) = @_;

	my $vertexFrom = $graph->{$from};
	my $vertexTo = $graph->{$to};

	if ($vertexFrom and $vertexTo) {

		unless ( $graph->haveTransformator($from, $to) ) {
			$vertexFrom->{$to} = $failures;
		}

		unless ( $graph->haveTransformator($to, $from) ) {
			$vertexTo->{$from} = $failures;
		}
	}

	return $graph;
}


# remove wire bidirectional
sub removeWire {
	my ($graph, $from, $to) = @_;

	if (exists $graph->{$from}->{$to}) {
		delete $graph->{$from}->{$to};
	}

	if (exists $graph->{$to}->{$from}) {
		delete $graph->{$to}->{$from};
	}

	return $graph;
}


# is transformator connected to another one
sub haveTransformator {
	my ($graph, $key, $value) = @_;

	my @neighbors = keys %{$graph->{$key}};

	return "@neighbors" =~ /\b$value\b/;
}


# get list of transformators in network
sub getTransformators {
	my ($graph) = @_;

	my @vertices = keys %$graph;

	return @vertices;
}


# get transformators connected with transformator
sub getNeighborsOf {
	my ($graph, $vertex) = @_;

	my @vertices = keys %{$graph->{$vertex}};

	return @vertices;
}


# helper dev function for printing network
sub printNetwork {
	my ($graph, $name) = @_;

	print "$name structure:\n" if $name;

	foreach my $vertex (keys %$graph) {
		print "$vertex\n";
		foreach my $child (keys %{$graph->{$vertex}}) {
			print "  - $child ($graph->{$vertex}->{$child})\n";
		}
		print "\n";
	}

	print "\n";
}


# helper function for following algorithms
sub visited {
	my ($graph, $array, $value) = @_;

	return "@{$array}" =~ /\b$value\b/;
}


# ###############################################
# check for cycles in network
# uses DFS algorithm for recursive depth descent
# ###############################################


sub dfsCyclic {
	my ($graph, $vertex, $visited, $parent) = @_;

	push(@$visited, $vertex);

	foreach my $neighbor ($graph->getNeighborsOf($vertex)) {
		if (not $graph->visited($visited, $neighbor)) {
			if ($graph->dfsCyclic($neighbor, $visited, $vertex)) {
				return 1;
			}

		} elsif ($neighbor ne $parent) {
			return 1;
		}
	}

	return 0;
}


sub isCyclic {
	my ($graph) = @_;

	my @visited = [];

	foreach my $vertex ($graph->getTransformators()) {
		if (not $graph->visited(\@visited, $vertex)) {
			if ($graph->dfsCyclic($vertex, \@visited, "")) {
				return 1;
			}
		}
	}

	return 0;
}


# ###########################################################
# Minimum spanning tree implemented with Kruskal’s algorithm
# ###########################################################

# graph with failures represented as keys:

# $sorted_failures {
# 	INT $failure {
# 		$from : $to
# 	}
# }


sub sortFailures {
	my ($graph) = @_;

	my %sorted_failures = ();

	foreach my $from (keys %$graph) {
		foreach my $to (keys %{$graph->{$from}}) {
			$sorted_failures{$graph->{$from}->{$to}}{$from} = $to;
		}
	}

	return \%sorted_failures;
}


sub printMinimal {
	my ($graph) = @_;

	my $sorted_failures = $graph->sortFailures();
	my @visited = [];

	my $minimal_graph = "";
	my $minimal_failures = 0;

	foreach my $failure (sort { $a <=> $b } keys %$sorted_failures) {

		foreach my $from (keys %{$sorted_failures->{$failure}}) {
			my $to = $sorted_failures->{$failure}->{$from};

			# create new graph
			if (not $graph->visited(\@visited, $from) or not $graph->visited(\@visited, $to)) {
				push(@visited, $from);
				push(@visited, $to);

				$minimal_graph .= "$from - $to: $failure\n";
				$minimal_failures += int $failure;
			}

		}
	}

	print $minimal_graph;
	print "Hodnoceni: $minimal_failures\n";
}


# ###########################################################
# Kosaraju’s algorithm for strongly connected components
# uses DFS algorithm for recursive depth descent
# cycles on not-visited nodes represent independent clusters
# ###########################################################


sub dfsClusters {
	my ($graph, $vertex, $visited) = @_;

	push(@$visited, $vertex);

	foreach my $neighbor ($graph->getNeighborsOf($vertex)) {
		if (not $graph->visited($visited, $neighbor)) {
			$graph->dfsClusters($neighbor, $visited);
		}
	}
}


sub countClusters {
	my ($graph) = @_;

	my @visited = [];
	my $clusters = 0;

	foreach my $vertex ($graph->getTransformators()) {
		if (not $graph->visited(\@visited, $vertex)) {
			$graph->dfsClusters($vertex, \@visited);
			$clusters++;
		}
	}

	return $clusters;
}


1;
