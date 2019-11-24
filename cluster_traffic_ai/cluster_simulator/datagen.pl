#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my ($x, $y);
my $time = 0;
my $step = 50;
my $range = 2200;

for (my $i = 0; $i <= $range; $i += $step) {
    $x .= " " . $time;
    $y .= " " . $i;
    $time++;
}

print "x=[$x ]\n";
print "y=[$y ]\n";

foreach my $n (split(" ", $y)) {
    print $n . "\n";
}
