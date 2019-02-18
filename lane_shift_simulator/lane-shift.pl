#!/usr/bin/perl

use strict;
use warnings;
use POSIX;
use Data::Dumper;
use JSON::Parse 'json_file_to_perl';
use Time::HiRes 'usleep';
use Math::Random 'random_normal';
use IPC::Shareable;
use Child;

# set stdout auto-flush
$| = 1;

print ' _                        _____ _     _  __ _   ' . "\n";
print '| |                      /  ___| |   (_)/ _| |  ' . "\n";
print '| |     __ _ _ __   ___  \ `--.| |__  _| |_| |_ ' . "\n";
print '| |    / _` | `_ \ / _ \  `--. \ `_ \| |  _| __|' . "\n";
print '| |___| (_| | | | |  __/ /\__/ / | | | | | | |_ ' . "\n";
print '\_____/\__,_|_| |_|\___| \____/|_| |_|_|_|  \__|' . "\n";
print '  _____ _                 _       _             ' . "\n";
print ' /  ___(_)               | |     | |            ' . "\n";
print ' \ `--. _ _ __ ___  _   _| | __ _| |_ ___  _ __ ' . "\n";
print '  `--. \ | `_ ` _ \| | | | |/ _` | __/ _ \| `__|' . "\n";
print ' /\__/ / | | | | | | |_| | | (_| | || (_) | |   ' . "\n";
print ' \____/|_|_| |_| |_|\__,_|_|\__,_|\__\___/|_|   ' . "\n";
print "\n";

# get simulation model
my $model = json_file_to_perl("./model.json");


########################
### SHARED VARIABLES ###
########################

# hash of shared services (+ zip tokens)
# defaultly all unlocked (value 1)
# each shift requires one or more services (value 0 = rlocked)
my %sh_services;
tie %sh_services, 'IPC::Shareable', "serv", { create => 1 };
foreach my $service (@{$model->{services}}) {
	$sh_services{$service} = 1;
}

# value in zipper represent latest shifted lane
# default value is 0 for all zippers
my %sh_zippers;
tie %sh_zippers, 'IPC::Shareable', "zip", { create => 1 };
foreach my $zip_token (@{$model->{zip_tokens}}) {
	$sh_services{$zip_token} = 1;
	$sh_zippers{$zip_token} = 0;
}

# hash keys are vehicles and values are places
# fast update of vehicle position after shift
my %sh_positions;
tie %sh_positions, 'IPC::Shareable', "posi", { create => 1 };
%sh_positions = ();

# collisions counter
my $sh_sum_collisions;
tie $sh_sum_collisions, 'IPC::Shareable', "coli", { create => 1 };
$sh_sum_collisions = 0;

# fool shifts counter
my $sh_sum_fool_shifts;
tie $sh_sum_fool_shifts, 'IPC::Shareable', "fool", { create => 1 };
$sh_sum_fool_shifts = 0;


###################
### SUBROUTINES ###
###################

# normal probability distribution defined with middle value and deviation
sub normal {
	my ($value, $deviation) = @_;
	return ceil(random_normal() * $deviation + $value);
}

# sleep time defined in miliseconds
sub msleep {
	my ($miliseconds) = @_;
	usleep($miliseconds * 1000);
}

# checking that all services the process needs are opened
# if opened, reserve them for the process
sub lockServices {
	my ($ref_services) = @_;

	while (1) {
		(tied %sh_services)->shlock;
		my $open = 1;
		foreach my $serv (@{$ref_services}) {
			unless ($sh_services{$serv}) {
				$open = 0;
			}
		}
		if ($open) {
			foreach my $serv (@{$ref_services}) {
				$sh_services{$serv} = 0;
			}
			(tied %sh_services)->shunlock;
			last;
		}
		(tied %sh_services)->shunlock;
	}
}

# unlock all services reserved with the process
sub unlockServices {
	my ($ref_services) = @_;

	(tied %sh_services)->shlock;
	foreach my $serv (@{$ref_services}) {
		$sh_services{$serv} = 1;
	}
	(tied %sh_services)->shunlock;
}

# check if zipping token have different value than process lane
sub canZip {
	my ($zip_token, $lane) = @_;

	if ($sh_zippers{$zip_token} == $lane) {
		msleep(300);
		return 0;
	}
	return 1;
}

# set zipping token value to the process lane number
sub switchZip {
	my ($zip_token, $lane) = @_;

	$sh_zippers{$zip_token} = $lane;
}

# generate random collision & sleep collision time
sub randomColision {
	my ($zip_token) = @_;

	if (rand(100) <= $model->{randoms}->{prob_collision}) {
		$sh_sum_collisions++;
		msleep(normal($model->{randoms}->{time_collision}, 1000));
	}
}

# decide if vehicle is fool in actual step
sub isFool {
	if (rand(100) <= $model->{randoms}->{prob_fool} ) {
		return 1;
	}
	return 0;
}

# update vehicle position after successful step
sub updatePosition {
	my ($vehicle) = @_;

	(tied %sh_positions)->shlock;
	$sh_positions{ $vehicle->{name} } = $vehicle->{place};
	(tied %sh_positions)->shunlock;
}

# conversion boolean value to yes/no string
sub boolToString {
	my ($boolean) = @_;
	return $boolean ? "yes" : "no";
}

# print final status of the simulation
sub printStatus {
	my $lane_1 = 0;
	my $lane_2 = 0;
	my $lane_3 = 0;
	my $finished = 0;

	foreach my $vehicle (values %sh_positions) {
		$lane_1++ if $vehicle =~ /P1./;
		$lane_2++ if $vehicle =~ /P2./;
		$lane_3++ if $vehicle =~ /P3./;
		$finished++ if $vehicle =~ /finish/;
	}

	print "\n";
	print "### SIMULATION SUMMARY ###\n";
	print "Simulation duration: " . $model->{duration} . " seconds\n";
	print "Zipping allowed: " . boolToString($model->{zipping}) . "\n";
	print "Fool shift allowed: " . boolToString($model->{fool_shift}) . "\n";
	print "\n";
	print "Lane 1: $lane_1 vehicles\n";
	print "Lane 2: $lane_2 vehicles\n";
	print "Lane 3: $lane_3 vehicles\n";
	print "Finished: $finished vehicles\n";
	print "Collisions: " . $sh_sum_collisions . "\n";
	print "Fool shifts: " . $sh_sum_fool_shifts . "\n";
}


#########################
### VEHICLE LIFECYCLE ###
#########################

for (1 .. 3) {
	my $lane_num = $_;
	for (1 .. normal($model->{randoms}->{num_init_vehicles}, 3)) {
		my $vehicle_num = $_;

		# for generated number of vehicles x number of lanes create vehicle process
		# as fork manager is used simple Child module

		my $vehicle = Child->new(
			sub {
				# basic information about process / vehicle
				my %vehicle = (
					name => "L" . $lane_num . "-V" . $vehicle_num,
					place => "P" . $lane_num . "1"
				);

				updatePosition(\%vehicle);

				print "$vehicle{name} started on lane $lane_num\n";

				# process is alive until does not reach finish state
				while ($vehicle{place} ne "finish") {

					# get actual lane number (useful if zipping)
					my $lane = $model->{places}->{$vehicle{place}}->{lane};

					# check what services are needed for standard shift from actual state
					my @services_needed = @{ $model->{places}->{$vehicle{place}}->{services} };

					# push zip token into needed services
					my $zip_token = $model->{places}->{$vehicle{place}}->{zip_token};
					push(@services_needed, $zip_token) if $zip_token;

					# if zipping from actual state, find out if actual lane have priority
					if ($model->{zipping} and $zip_token) {
						next unless canZip($zip_token, $lane);
					}

					# if there is option for fool shift from current state, check what services are needed
					my $has_fool_option = $model->{places}->{$vehicle{place}}->{fool_services};
					my @services_if_fool = @{$has_fool_option} if $has_fool_option;

					# find out if vehicle will be fool in this shift
					my $i_am_fool = isFool();

					if ($model->{fool_shift} and $i_am_fool and $has_fool_option ) {

						# if allowed fool shift from this state and vehicle is fool -> make fool shift
						# lock services and sleep defined time (this simulate shifting through places)

						lockServices(\@services_if_fool);

						my $sleep_time = normal($model->{randoms}->{time_fool_shift}, 1000);

						print "$vehicle{name} shifting into neighbor lane like fool for " . $sleep_time . " miliseconds\n";
						msleep($sleep_time);

						unlockServices(\@services_if_fool);

						# actualize vehicle state after shift
						$vehicle{place} = $model->{places}->{$vehicle{place}}->{fool_hop};

						# increment fool shifts counter
						$sh_sum_fool_shifts++;
					} else {

						# otherwise make standard shift

						lockServices(\@services_needed);

						my $sleep_time =  normal($model->{randoms}->{$model->{places}->{$vehicle{place}}->{duration}}, 500);

						print "$vehicle{name} shifting standardly for " . $sleep_time . " miliseconds\n";
						msleep($sleep_time);

						# if zipping not included, shift can cause collision of vehicles in two lines
						# and keep services locked longer time
						if (not $model->{zipping} and $zip_token) {
							randomColision($zip_token);
						}

						unlockServices(\@services_needed);

						# if this shift was zipping shift, update latest shifted line
						if ($model->{zipping} and $zip_token) {
							switchZip($zip_token, $lane);
						}

						$vehicle{place} = $model->{places}->{$vehicle{place}}->{next_hop};
					}

					# update shared position of vehocle
					updatePosition(\%vehicle);
					print "$vehicle{name} is now on $vehicle{place}\n";
				}

				print "$vehicle{name} finished simulation!\n";
				exit 0;
			}
		)->start;
	}
}


######################
### PARENT PROCESS ###
######################

# simulation time flow
my $sim_time = 0;

while ($sim_time < $model->{duration}) {
	sleep 1;
	$sim_time++;
	print "--- Time: $sim_time seconds ---\n";
}

# kill all processes after time ends
foreach my $vehicle (Child->all_procs()) {
	$vehicle->is_complete || $vehicle->kill(9);
}

# print final status of the simulation
printStatus();

# free shared memory
(tied %sh_services)->remove;
(tied %sh_zippers)->remove;
(tied %sh_positions)->remove;
(tied $sh_sum_collisions)->remove;
(tied $sh_sum_fool_shifts)->remove;

exit 0;
