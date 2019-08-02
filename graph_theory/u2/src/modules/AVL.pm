#!/usr/bin/perl

use strict;
use warnings;

package AVL;

# ####################################################
# class representing one Node with informations about
# value, height, right and left nodes pointer
# ####################################################
{
	use strict;
	use warnings;

	package Node;


	sub new {
		my ($class, $value) = @_;

		my $node = {};

		$node->{value} = $value;
		$node->{left} = 0;
		$node->{right} = 0;
		$node->{height} = 1;

		bless $node, $class;

		return $node;
	}
}


sub new {
	my ($class) = @_;

	my $tree = {};
	bless $tree, $class;

	return $tree;
}


# get height of node
sub height() {
	my ($tree, $node) = @_;

	unless ($node) {
		return 0;
	}
	return $node->{height};
}


# helper function max(a, b)
sub max {
	my ($tree, $a, $b) = @_;

	return ($a > $b) ? $a : $b;
}


# get difference between left and right subtree
sub balance {
	my ($tree, $node) = @_;

	unless ($node) {
		return 0;
	}

	return $tree->height($node->{left}) - $tree->height($node->{right});
}


# right rotate AVL tree
sub rightRotate {
	my ($tree, $node) = @_;

	my $x = $node->{left};
	my $t2 = $x->{right};

	# rotation
	$x->{right} = $node;
	$node->{left} = $t2;

	# heights
	$node->{height} = $tree->max($tree->height($node->{left}), $tree->height($node->{right})) + 1;
	$x->{height} = $tree->max($tree->height($x->{left}), $tree->height($x->{right})) + 1;

	return $x;
}


# left rotate AVL tree
sub leftRotate {
	my ($tree, $node) = @_;

	my $y = $node->{right};
	my $t2 = $y->{left};

	# rotation
	$y->{left} = $node;
	$node->{right} = $t2;

	# heights
	$node->{height} = $tree->max($tree->height($node->{left}), $tree->height($node->{right})) + 1;
	$y->{height} = $tree->max($tree->height($y->{left}), $tree->height($y->{right})) + 1;

	return $y;
}


# add node recursively on right place
# make rotations in case of emergency
sub addNode {
	my ($tree, $node, $value) = @_;


	unless ($node) {
		return new Node($value);
	}

	if ($value < $node->{value}) {
		$node->{left} = $tree->addNode($node->{left}, $value);
	} elsif ($value >= $node->{value}) {
		$node->{right} = $tree->addNode($node->{right}, $value);
	}

	# else { # duplicit value
	# 	return $node;
	# }

	# count height of new node
	$node->{height} = $tree->max($tree->height($node->{left}), $tree->height($node->{right})) + 1;

	# balance graph
	my $balance = $tree->balance($node);

	# balance left left
	if ($balance > 1 and $value < $node->{left}->{value}) {
		return $tree->rightRotate($node);
	}

	# balance right right
	if ($balance < -1 and $value > $node->{right}->{value}) {
		return $tree->leftRotate($node);
	}

	# balance left right
	if ($balance > 1 and $value > $node->{left}->{value}) {
		$node->{left} = $tree->leftRotate($node->{left});
		return $tree->rightRotate($node);
	}

	# balance right left
	if ($balance < -1 and $value < $node->{right}->{value}) {
		$node->{right} = $tree->rightRotate($node->{right});
		return $tree->leftRotate($node);
	}

	return $node;
}


sub printLevel {
	my ($tree, $node, $level) = @_;

	unless ($node) {
		print "_,";
		return;
	}

	if ($level == 1) {
		print "$node->{value},";
	} elsif ($level > 1) {
		$tree->printLevel($node->{left}, $level - 1);
		$tree->printLevel($node->{right}, $level - 1);
	}

}


# print BFS-style AVL tree
# uses recursively function printLevel
sub printTree {
	my ($tree, $node) = @_;

	if ($node) {
		foreach my $d (1 .. $node->{height}) {
			$tree->printLevel($node, $d);
			print "\b|";

		}
	}
	print "\b \n";
}

1;
