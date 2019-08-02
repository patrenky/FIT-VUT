#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

package Graph;

# new Graph(@vertices)
sub new {
	my ($class, @vertices) = @_;

	my $graph = {};
	bless $graph, $class;

	if (@vertices) {
		$graph->addVertices(@vertices);
	}

	return $graph;
}


# $graph->addVertices(@vertices)
sub addVertices {
	my ($graph, @vertices) = @_;

	foreach my $vertex (@vertices) {
		$graph->addVertex($vertex);
	}

	return $graph;
}


# $graph->addVertex($vertex)
sub addVertex {
	my ($graph, $vertex) = @_;

	unless ($graph->{$vertex}) {
		$graph->{$vertex} = [];
	}

	return $graph;
}


# $graph->addEdge($from, $to)
sub addEdgeDirect {
	my ($graph, $from, $to) = @_;

	my $vertexFrom = $graph->{$from};

	if ($vertexFrom and $graph->{$to}) {

		unless ( $graph->haveVertex($from, $to) ) {
			push @{$vertexFrom}, $to;
		}
	}

	return $graph;
}


sub addEdgeBidirect {
	my ($graph, $from, $to) = @_;

	$graph->addEdgeDirect($from, $to);
	$graph->addEdgeDirect($to, $from);

	return $graph;
}


# $graph->addPath($start, $vertex1, $vertex2, ...)
sub addPathDirect {
	my ($graph, $from, @vertices) = @_;

	foreach my $to (@vertices) {
		$graph->addEdge($from, $to);
		$from = $to;
	}

	return $graph;
}


sub haveVertex {
	my ($graph, $key, $value) = @_;

	return "@{$graph->{$key}}" =~ /\b$value\b/;
}


# $graph->getVertices()
# scalar or array
sub getVertices {
	my ($graph) = @_;

	my @vertices = keys %$graph;

	return @vertices;
}


sub getVerticesOf {
	my ($graph, $vertex) = @_;

	my @vertices = @{$graph->{$vertex}};

	return @vertices;
}


sub getNumEdges {
	my ($graph) = @_;
	my $edges = 0;

	foreach my $vertex (keys %$graph) {
		$edges += $graph->getVerticesOf($vertex);
	}

	return $edges;
}


sub printGraph {
	my ($graph, $name) = @_;

	print "Graph $name structure:\n";

	foreach my $vertex (keys %$graph) {
		print "$vertex : @{ $graph->{$vertex} }\n";
	}

	print "\n";
}

1;