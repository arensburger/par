# July 2022. This script displays only the lastest backups

use strict;
use Getopt::Long;
use Time::Piece;
use Time::Seconds;

my $filename; #name of input file

##### read and check the inputs
GetOptions(
	'in:s'   => \$filename,
);
unless ($filename) {
	die "usage perl latest_backups.pl <-in file name REQUIRED>\n";
}
open (INPUT, $filename) or die "cannot open input file $filename\n";

### parse the input file into individual backups
my %backups; #date as key and text of backup as value
my $current_date; # date of the backup currently examined
my $current_text; # text of the backup currently examined
while (my $line = <INPUT>) {
	if ($line =~ /----.+(\d\d\/\d\d\/20\d\d)\sStarting/) {
		$current_date = convertdate($1);
	}
	$backups{$current_date} .= $line;
}
close INPUT;

### create new file with only the report satifying condidtions
## HTML HEADER
print "<!DOCTYPE html>\n";
print "<html lang=\"en\">";
print "<table style=\"width:100%\">\n";

## reporting only the backups from the previous 7 days
my $today = Time::Piece->strptime(localtime->strftime('%Y-%m-%d'), "%Y-%m-%d");  #
my $week_ago = $today - (7 * ONE_DAY);
foreach my $date ( sort {$b cmp $a} keys %backups) {
	if ($date gt $week_ago->date) {
		my @text = split "\n", $backups{$date};
		for (my $i=0; $i<scalar @text; $i++) {
			print "<tr>\n";
			if ($i==0) {
				print "\t<td><b>$text[$i]</b></td>\n";
			}
			else {
				print "\t<td>$text[$i]</td>\n";
			}
			print "</tr>\n";
		}
	}
}

print "</table>\n";
print "</html>";


# convert standard american date to ISO standard
sub convertdate {
	my ($text) = @_;
	if ($text =~ /(\d\d)\/(\d\d)\/(\d\d\d\d)/) {
		return ($3 . "-" . $1 . "-" . $2);
	}
	else {
		warn "WARNING: could not convert date $text to ISO\n";
		return ($text);
	}
}

# convert perl time ISO standard
sub convertdate2 {
	my ($text) = @_;
	print "text is $text\n"; exit;
}
