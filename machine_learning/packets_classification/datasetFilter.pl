#!/usr/bin/perl

use strict;
use warnings;
$| = 1;

#############################################
#                  USAGE
#############################################
# allow filter type bellow (1 = allowed)
# chmod +x ./datasetFilter.pl
# ./datasetFilter.pl < packets_dataset.arff

# ALLOW FILTER INTO 3 FILES: train (70%), validation (15%) and test data (15%)
my $filter_percent = 0;
my $file_train = "dataset_train.csv";
my $file_valid = "dataset_validation.csv";
my $file_test = "dataset_test.csv";

# ALLOW FILTER RECORDS PER CLASS
my $filter_records = 1;
my $records_per_class = 100;
my $file_records_train = "dataset_" . $records_per_class . "_per_class_train.csv";
my $file_records_test = "dataset_" . $records_per_class . "_per_class_test.csv";


# ENUMS

our %enumPktType = (
	"tcp" => 1,
	"ack" => 2,
	"cbr" => 3,
	"ping" => 4
);

our %enumNodeName = (
	"Switch1" => 1,
	"Router" => 2,
	"server1" => 3,
	"router" => 4,
	"clien-4" => 5,
	"client-2" => 6,
	"Switch2" => 7,
	"client-5" => 8,
	"clien-9" => 9,
	"clien-2" => 10,
	"clien-1" => 11,
	"clien-14" => 12,
	"clien-5" => 13,
	"clien-11" => 14,
	"clien-13" => 15,
	"clien-0" => 16,
	"switch1" => 17,
	"client-4" => 18,
	"clienthttp" => 19,
	"clien-7" => 20,
	"clien-19" => 21,
	"client-14" => 22,
	"clien-12" => 23,
	"clien-8" => 24,
	"clien-15" => 25,
	"webserverlistin" => 26,
	"client-18" => 27,
	"client-1" => 28,
	"switch2" => 29,
	"clien-6" => 30,
	"client-10" => 31,
	"client-7" => 32,
	"webcache" => 33,
	"clien-10" => 34,
	"client-15" => 35,
	"clien-3" => 36,
	"client-17" => 37,
	"client-16" => 38,
	"clien-17" => 39,
	"clien-18" => 40,
	"client-12" => 41,
	"client-8" => 42,
	"client-0" => 43,
	"clien-16" => 44,
	"client-13" => 45,
	"client-11" => 46,
	"client-6" => 47,
	"client-3" => 48,
	"client-9" => 49,
	"http_client" => 50
);

our %enumPktClass = (
	"Normal" => 1,
	"UDP-Flood" => 2,
	"Smurf" => 3,
	"SIDDOS" => 4,
	"HTTP-FLOOD" => 5
);

# format records in line
sub formatLine {
	my ($line) = @_;

	# replace enums
	foreach my $key (keys %enumPktType) {
		$line =~ s/$key/$enumPktType{$key}/g;
	}

	foreach my $key (keys %enumNodeName) {
		$line =~ s/$key/$enumNodeName{$key}/g;
	}

	foreach my $key (keys %enumPktClass) {
		$line =~ s/$key/$enumPktClass{$key}/g;
	}

	# remove flags
	$line =~ s/,-------//gi;
	$line =~ s/,---A---//gi;

	# replace delimiters
	$line =~ s/,/;/g;

	# replace dots
	# $line =~ s/\./,/g;

	return $line;
}


sub formatPrint {
	my ($string) = @_;
	return ("$string" . (" " x (15 - length $string)));
}


#############################################
#               read input
#############################################

my @raw_dataset = ();

while (<STDIN>) {
	chomp;
	next if $_ =~ /^$/;
	next if $_ =~ /^@/;
	push(@raw_dataset, $_);
}

# count all records per class

my %total_per_class = (
	normal => 0,
	udp_flood => 0,
	smurf_ => 0,
	siddos => 0,
	http_flood => 0
);

foreach my $line (@raw_dataset) {
	if ($line =~ /Normal/) {
		$total_per_class{normal}++;
	} elsif ($line =~ /UDP-Flood/) {
		$total_per_class{udp_flood}++;
	} elsif ($line =~ /Smurf/) {
		$total_per_class{smurf_}++;
	} elsif ($line =~ /SIDDOS/) {
		$total_per_class{siddos}++;
	} elsif ($line =~ /HTTP-FLOOD/) {
		$total_per_class{http_flood}++;
	}
}

# print total records count
print("Total records per class:\n");
foreach my $type (keys %total_per_class) {
	print(formatPrint($type) . formatPrint($total_per_class{$type}) . "\n");
}

#############################################
#            records per class
#############################################

sub fillRecordsFile {
	my ($filename, $dataset) = @_;

	my %records = (
		normal => 0,
		udp_flood => 0,
		smurf_ => 0,
		siddos => 0,
		http_flood => 0
	);

	open(my $output, '>', $filename);

	my $counter = 0;

	foreach my $line (@$dataset) {
		$counter++;
		print "." if ($counter % 10000 == 0);

		if ($line =~ /Normal/ and $records{normal} < $records_per_class) {
			$line = formatLine($line);
			print $output "$line\n";
			$records{normal}++;
		} elsif ($line =~ /UDP-Flood/ and $records{udp_flood} < $records_per_class) {
			$line = formatLine($line);
			print $output "$line\n";
			$records{udp_flood}++;
		} elsif ($line =~ /Smurf/ and $records{smurf_} < $records_per_class) {
			$line = formatLine($line);
			print $output "$line\n";
			$records{smurf_}++;
		} elsif ($line =~ /SIDDOS/ and $records{siddos} < $records_per_class) {
			$line = formatLine($line);
			print $output "$line\n";
			$records{siddos}++;
		} elsif ($line =~ /HTTP-FLOOD/ and $records{http_flood} < $records_per_class) {
			$line = formatLine($line);
			print $output "$line\n";
			$records{http_flood}++;
		}
	}

	close $output;
	print "\n";
}

if ($filter_records) {
	fillRecordsFile($file_records_train, \@raw_dataset);
	fillRecordsFile($file_records_test, reverse \@raw_dataset);
}


#############################################
#           records per percent
#############################################

if ($filter_percent) {

	my %train = (
		normal => int($total_per_class{normal} * 0.7),
		udp_flood => int($total_per_class{udp_flood} * 0.7),
		smurf_ => int($total_per_class{smurf_} * 0.7),
		siddos => int($total_per_class{siddos} * 0.7),
		http_flood => int($total_per_class{http_flood} * 0.7)
	);

	my %validation = (
		normal => int($total_per_class{normal} * 0.15),
		udp_flood => int($total_per_class{udp_flood} * 0.15),
		smurf_ => int($total_per_class{smurf_} * 0.15),
		siddos => int($total_per_class{siddos} * 0.15),
		http_flood => int($total_per_class{http_flood} * 0.15)
	);

	my %test = (
		normal => int($total_per_class{normal} * 0.15),
		udp_flood => int($total_per_class{udp_flood} * 0.15),
		smurf_ => int($total_per_class{smurf_} * 0.15),
		siddos => int($total_per_class{siddos} * 0.15),
		http_flood => int($total_per_class{http_flood} * 0.15)
	);

	# print records per class
	print("\nRecords per class:\n");
	print(formatPrint("") . formatPrint("train") . formatPrint("validation") . formatPrint("test") . "\n");
	foreach my $type (keys %total_per_class) {
		print(formatPrint($type) . formatPrint($train{$type}) . formatPrint($validation{$type}) . formatPrint($test{$type}) . "\n");
	}

	open(my $output_train, '>', $file_train);
	open(my $output_valid, '>', $file_valid);
	open(my $output_test, '>', $file_test);

	my $counter = 0;

	foreach my $line (@raw_dataset) {
		$counter++;
		print "." if ($counter % 10000 == 0);

		if ($line =~ /Normal/) {
			$line = formatLine($line);
			if ($train{normal}) {
				print $output_train "$line\n";
				$train{normal}--;
			} elsif ($validation{normal}) {
				print $output_valid "$line\n";
				$validation{normal}--;
			} elsif ($test{normal}) {
				print $output_test "$line\n";
				$test{normal}--;
			}
		} elsif ($line =~ /UDP-Flood/) {
			$line = formatLine($line);
			if ($train{udp_flood}) {
				print $output_train "$line\n";
				$train{udp_flood}--;
			} elsif ($validation{udp_flood}) {
				print $output_valid "$line\n";
				$validation{udp_flood}--;
			} elsif ($test{udp_flood}) {
				print $output_test "$line\n";
				$test{udp_flood}--;
			}
		} elsif ($line =~ /Smurf/) {
			$line = formatLine($line);
			if ($train{smurf_}) {
				print $output_train "$line\n";
				$train{smurf_}--;
			} elsif ($validation{smurf_}) {
				print $output_valid "$line\n";
				$validation{smurf_}--;
			} elsif ($test{smurf_}) {
				print $output_test "$line\n";
				$test{smurf_}--;
			}
		} elsif ($line =~ /SIDDOS/) {
			$line = formatLine($line);
			if ($train{siddos}) {
				print $output_train "$line\n";
				$train{siddos}--;
			} elsif ($validation{siddos}) {
				print $output_valid "$line\n";
				$validation{siddos}--;
			} elsif ($test{siddos}) {
				print $output_test "$line\n";
				$test{siddos}--;
			}
		} elsif ($line =~ /HTTP-FLOOD/) {
			$line = formatLine($line);
			if ($train{http_flood}) {
				print $output_train "$line\n";
				$train{http_flood}--;
			} elsif ($validation{http_flood}) {
				print $output_valid "$line\n";
				$validation{http_flood}--;
			} elsif ($test{http_flood}) {
				print $output_test "$line\n";
				$test{http_flood}--;
			}
		}
	}

	close $output_train;
	close $output_valid;
	close $output_test;
	print "\n";
}
