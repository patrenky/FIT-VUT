use Fcntl qw(:flock SEEK_END);
use JSON::Parse 'parse_json';
use JSON 'encode_json';
use Try::Tiny;

our $file_topology = "./topology.json";
our $file_traffic = "./traffic.json";


sub readFile {
	my ($filename) = @_;

	open my $fh_file, '<', $filename
	  or die("Error opening file $filename: $!");

	flock($fh_file, LOCK_EX)
	  or die("Error locking file $filename: $!");

	my @lines = <$fh_file>;

	close $fh_file
	  or die("Error unlocking file $filename: $!");

	chomp @lines;
	return join("\n", @lines);
}


sub writeFile {
	my ($filename, $content) = @_;

	open my $fh_file, '>', $filename
	  or die("Error opening file $filename: $!");

	flock($fh_file, LOCK_EX)
	  or die("Error locking file $filename: $!");

	print $fh_file $content;

	close $fh_file
	  or die("Error unlocking file $filename: $!");
}


sub readJsonFile {
	my ($filename) = @_;

	my $json = readFile($filename);

	try {
		my $perl_hash = parse_json($json);
		return $perl_hash;
	} catch {
		die("Error reading JSON from $filename: $_");
	};
}


sub writeJsonFile {
	my ($filename, $perl_hash) = @_;

	my $json = encode_json($perl_hash);

	writeFile($filename, $json);
}


sub getTopology {
	my $topology = readJsonFile($file_topology);
	return $topology;
}


sub getTrafficJson {
	return readFile($file_traffic);
}


sub updateTraffic {
	my ($traffic_json) = @_;
	writeFile($file_traffic, $traffic_json);
}


sub updateTopology {
	my ($topology) = @_;
	writeJsonFile($file_topology, $topology);
}


1;
