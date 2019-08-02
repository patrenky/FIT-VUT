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
#    Ford-Fulkerson Algorithm for Maximum Flow
# ###############################################


sub bfs {
	my ($graph, $start, $finish, $parent) = @_;

	my %visited = ();
	my @queue = ();

	push(@queue, $start);
	$parent->{$start} = -1;
	$visited{$start} = 1;

	while (@queue) {
		my $u = shift @queue;

		foreach my $v (keys %$graph) {
			if (not $visited{$v} and $graph->{$u}->{$v} and $graph->{$u}->{$v} > 0) {
				push(@queue, $v);
				$parent->{$v} = $u;
				$visited{$v} = 1;
			}
		}
	}

	return $visited{$finish};
}


sub min {
	my ($graph, @items) = @_;
	my @sorted = sort { $a <=> $b } @items;
	return shift @sorted;
}


sub maxFlow {
	my ($graph, $total_group, $start, $finish) = @_;

	my %parent = ();
	my $max_flow = 0;
	my $cycles = 0;

	while ($graph->bfs($start, $finish, \%parent)) {
		my $path_flow = $INF;

		for (my $v = $finish; $v ne $start; $v = $parent{$v}) {
			my $u = $parent{$v};
			$path_flow = $graph->min($path_flow, $graph->{$u}->{$v});
		}

		for (my $v = $finish; $v ne $start; $v = $parent{$v}) {
			my $u = $parent{$v};
			$graph->{$u}->{$v} -= $path_flow;
			$graph->{$v}->{$u} += $path_flow;
		}

		$max_flow += $path_flow;
		$cycles++;
	}

	return ($max_flow, $cycles);
}


# ###############################################
#      Greedy Algorithm for Graph Coloring
# ###############################################


sub greedy {
	my ($graph) = @_;

	my %result = ();
	my %available = ();

	# init result and color hash
	foreach my $v (keys %$graph) {
		$result{$v} = -1;
		$available{$v} = 0;
	}

	foreach my $v (keys %$graph) {

		# process all adjacent vertices and flag their colors as unavailable
		foreach my $adj ( keys %{$graph->{$v}} ) {
			if ($result{$adj} ne -1) {
				$available{ $result{$adj} } = 1;
			}
		}

		# find the first available color
		my $color;
		foreach my $c (keys %$graph) {
			if ($available{$c} == 0) {
				$color = $c;
				last;
			}
		}

		# assign the found color
		$result{$v} = $color;

		# reset the values back to false for the next iteration
		foreach my $c (keys %$graph) {
			if ($result{$c} ne -1) {
				$available{ $result{$c} } = 0;
			}
		}
	}

	return \%result;
}


1;
