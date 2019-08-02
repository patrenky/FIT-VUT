#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use modules::AVL;

my @nodes;

while (<STDIN>) {
	chomp;
	push @nodes, $_;
}

my $tree = new AVL();

my $node;

foreach my $value (@nodes) {
	$node = $tree->addNode($node, $value);
	$tree->printTree($node);
}
