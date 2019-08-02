#!/usr/bin/perl

use strict;
use warnings;

package Graph;

my $INF = ~0;


# ###############################################
#     Class for representing graph structure
# ###############################################


# Graph structure:

# $graph: {
# 	$from: {
# 		$to : $cost
# 	}
# }


sub new {
	my ($class) = @_;

	my $graph = {};
	bless $graph, $class;

	return $graph;
}


sub createMatrix {
	my ($graph) = @_;

	my $matrix = {};

	foreach my $primary (keys %$graph) {
		foreach my $secondary (keys %$graph) {
			my $value = $graph->{$primary}->{$secondary};
			$matrix->{$primary}->{$secondary} = $value ? $value : "0";
		}
	}

	return $matrix;
}


# is node connected to another one
sub isConnected {
	my ($graph, $from, $to) = @_;

	return 0 unless $graph->{$from};

	my @neighbors = keys %{$graph->{$from}};

	return "@neighbors" =~ /\b$to\b/;
}


# add directed edge between two nodes
sub addDirectEdge {
	my ($graph, $from, $to, $cost) = @_;

	unless ( $graph->isConnected($from, $to) ) {
		$graph->{$from}->{$to} = $cost;
	}

	return $graph;
}


# add bidirected edge between two nodes
sub addBidirectEdge {
	my ($graph, $from, $to, $cost) = @_;

	$graph->addDirectEdge($from, $to, $cost);
	$graph->addDirectEdge($to, $from, $cost);

	return $graph;
}


# helper function to print graph structure
sub printGraph {
	my ($graph) = @_;

	print "Graph structure:\n";

	foreach my $node (keys %$graph) {
		print "$node\n";
		foreach my $child (keys %{$graph->{$node}}) {
			print "  - $child ($graph->{$node}->{$child})\n";
		}
		print "\n";
	}

	print "\n";
}


sub printMatrix {
	my ($graph, $matrix) = @_;

	print "Matrix structure:\n";

	foreach my $secondary (keys %$matrix) {
		print "\t" . substr($secondary, 0, 3);
	}
	print "\n";

	foreach my $primary (keys %$matrix) {
		print substr($primary, 0, 5);
		foreach my $secondary (keys %$matrix){
			print "\t" . $matrix->{$primary}->{$secondary};
		}
		print "\n";
	}
}


# ###############################################
#            Dijskra's shortest path
# ###############################################


sub minDistance() {
	my ($graph, $distances, $visited) = @_;

	my $min = $INF;
	my $min_index;

	foreach my $node (keys %$graph) {
		if ($visited->{$node} == 0 and $distances->{$node} <= $min) {
			$min = $distances->{$node};
			$min_index = $node;
		}
	}

	return $min_index;
}


sub dijskra {
	my ($graph, $src) = @_;

	my %distances = ();
	my %predecessor = ();
	my %visited = ();

	foreach my $node (keys %$graph) {
		$distances{$node} = $INF;
		$predecessor{$node} = "";
		$visited{$node} = 0;
	}

	$distances{$src} = 0;

	# relax edges repeatedly
	foreach my $i (1 .. scalar keys %$graph) {
		my $u = $graph->minDistance(\%distances, \%visited);

		$visited{$u} = 1;

		foreach my $v (keys %$graph) {
			my $w = $graph->{$u}->{$v};
			if (not $visited{$v} and $w and $distances{$u} != $INF and $distances{$u} + $w < $distances{$v}) {
				$distances{$v} = $distances{$u} + $w;
				$predecessor{$v} = $u;
			}
		}
	}

	return \%distances;
}


# ###############################################
#                 Euler's path
# ###############################################


sub eulerPath {
	my ($graph, $src) = @_;

	my %visited = ();
	my $path = "$src";
	my $distance = 0;
	my $node = $src;

	foreach my $i (keys %$graph) {
		my $distances = $graph->dijskra($node);

		foreach my $n (sort keys %$distances) {
			if (int($distances->{$n}) and $path !~ /$n/) {
				$path .= " - $n";
				$distance += int($distances->{$n});
				$node = $n;
				last;
			}
		}
	}
	$path .= ": $distance\n";

	return $path;
}


# ###############################################
#           Bellman–Ford shortest path
# ###############################################


sub bellmanFord {
	my ($graph, $src) = @_;

	my %distances = ();
	my %predecessor = ();

	# init graph
	foreach my $node (keys %$graph) {
		$distances{$node} = $INF;
		$predecessor{$node} = "";
	}

	$distances{$src} = 0;

	# relax edges repeatedly
	foreach my $i (1 .. scalar keys %$graph) {
		foreach my $u (keys %$graph) {
			foreach my $v (keys %{$graph->{$u}}) {
				my $w = $graph->{$u}->{$v};
				if ($distances{$u} != $INF and $distances{$u} + $w < $distances{$v}) {
					$distances{$v} = $distances{$u} + $w;
					$predecessor{$v} = $u;
				}
			}
		}
	}

	# check for negatiwe weight cycles
	foreach my $u (keys %$graph){
		foreach my $v (keys %{$graph->{$u}}){
			if ($distances{$u} + $graph->{$u}->{$v} < $distances{$v}) {
				die "Graph contains negative weight cycle\n";
			}
		}
	}

	return \%predecessor;
}


# ###########################################################
# Kosaraju’s algorithm for strongly connected components
# uses DFS algorithm for recursive depth descent
# cycles on not-visited nodes represent independent clusters
# ###########################################################


sub visited {
	my ($graph, $array, $value) = @_;

	return "@{$array}" =~ /\b$value\b/;
}


sub getNeighborsOf {
	my ($graph, $vertex) = @_;

	my @vertices = keys %{$graph->{$vertex}};

	return @vertices;
}


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

	foreach my $vertex (keys %$graph) {
		if (not $graph->visited(\@visited, $vertex)) {
			$graph->dfsClusters($vertex, \@visited);
			$clusters++;
		}
	}

	if ($clusters > 1) {
		die "Invalid graph: $clusters graph components\n";
	}
}


1;
