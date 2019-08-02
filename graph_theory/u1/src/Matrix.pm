#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

package Matrix;

# new Matrix(@vertices)
sub new {
	my ($class, @vertices) = @_;

	my $matrix = {};
	bless $matrix, $class;

	if (@vertices) {
		foreach my $primary (@vertices) {
			foreach my $secondary (@vertices){
				$matrix->{$primary}->{$secondary} = 0;
			}
		}
	}

	return $matrix;
}


sub setEdge {
	my ($matrix, $from, $to, $value) = @_;

	if ($matrix->{$from} and $matrix->{$to}) {
		$matrix->{$from}->{$to} = $value;
	}

	return $matrix;
}


sub getEdge {
	my ($matrix, $from, $to) = @_;

	return $matrix->{$from}->{$to};
}


sub printMatrix {
	my ($matrix, $name) = @_;

	print "Matrix $name structure:\n";

	foreach my $secondary (keys %$matrix) {
		print "\t" . $secondary;
	}
	print "\n";

	foreach my $primary (keys %$matrix) {
		print $primary;
		foreach my $secondary (keys %$matrix){
			print "\t" . $matrix->{$primary}->{$secondary};
		}
		print "\n";
	}
}


sub numVertices {
	my ($matrix) = @_;

	return scalar keys %$matrix;
}


sub numEdges {
	my ($matrix) = @_;

	my $edges = 0;

	foreach my $primary (keys %$matrix) {
		foreach my $secondary (keys %$matrix){
			$edges += $matrix->{$primary}->{$secondary};
		}
	}

	return $edges;
}

1;