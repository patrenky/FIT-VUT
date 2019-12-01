#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

if (qx(pwd) !~ /cluster_simulator/) {
	chdir "./cluster_simulator";
}

require './modules/file_actions.pl';

my $file_dataset = "./data/" . $ARGV[0];

unless (-f $file_dataset) {
	die("Dataset file $file_dataset does not exists");
}


my $dataset = readFile($file_dataset);
my $time = 0;

my $EXP_BOOST = 1.2;
my $NODE_WEIGHT = 0.8;


sub countRT {
	my ($current_qps, $nodes) = @_;
	return exp(($current_qps / 1000 - 1) * $EXP_BOOST) / ($nodes * $NODE_WEIGHT);
}

foreach my $current_qps (split("\n", $dataset)) {
	my $topology = getTopology();
	my $nodes = $topology->{nodes};
	my $read_time = countRT($current_qps, $nodes);

	print sprintf("T: %-3d | QPS: %-5d | N: %-2d | RT: %.5f\n", $time, $current_qps, $nodes, $read_time);

	my $traffic_json = "{ \"QPS\": $current_qps, \"RT\": $read_time }";
	updateTraffic($traffic_json);

	$time++;
	sleep 1;
}

