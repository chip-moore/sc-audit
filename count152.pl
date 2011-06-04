# perl code

# count152.pl

# Copyright (c) 2011 Chip Moore

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to the
# following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software. THE SOFTWARE IS
# PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# a script to count events in a modified version of the ES&S el152.lst event
# log file, created by the clean152.pl script.

use strict;
require utl;
require rgex;

# Use base class Exporter in order to export method "help" so that these
# can be called and passed around in objects including this package without
# need of namespace qualifier.
use base 'Exporter';
our @EXPORT = ( 'help' );

my $args = utl::parseCommandLine( \@ARGV, 4, "-d_-e_-i_-o", \&help );

my $in = $args->{ "-i" };
my $out = $args->{ "-o" };
my $date = $args->{ "-d" };
my $event = $args->{ "-e" };

# open input and output files

open( IN, "< $in" ) || die "\nUnable to open $in\n";
open( OUT, "> $out" ) || die "\nUnable to create $out\n";

# If no date is specified with the '-d' arg, use this string to match all
# dates. The date string, by the way, may have 2 or 4 digits in the year field.
if ( !$date )
{
	$date = $rgex::fulldate;
}
# convert something like 11//02//2010, which is returned by the command line
# argument -d 11/02/2010, to 11/02/2010 for use as a regexp.
#
# TODO: why don't I have to escape the '/' character in the date string? I
# don't understand that, but the output says escaping '/' characters is not
# necessary.
else
{
	$date =~ s/\/\//\//g;
}

# If no events are defined, use this string to match vote events.
if ( !$event )
{
	$event = $rgex::vote_cast_event;
}
# don't know why a user would use a '/' character in a regexp to match
# events, but if so, remove the extra '/'.
else
{
	$event =~ s/\/\//\//g;
}

# the number of events

my $v;

# the number of vote events in the file by category. I cannot find any event
# associated with event id 1512, which I suspect should be some kind of
# vote canceled event, after searching all my log files.

#my $vv;	# vote cast by voter (1510)
#my $vpw;	# vote cast by poll worker (1511)

#$vcwb;		# vote cancelled wrong ballot (1513)
#$vcvlab;	# vote cancelled voter left after ballot (1514)
#$vcvlbb;	# vote canceled voter left before ballot (1515)
#$vcvr;		# vote cancelled voter request (1516)
#$vcpp;		# vote cancelled printer problem (1517)
#$vctp;		# vote cancelled terminal problem (1518)
#$vcop;		# vote cancelled other problem (1519)

# the number of events per iVotronic voting terminal

my %iv;

# the number of events per PEB

my %pv;

# the number of events per iVotronic voting terminal per PEB

my %ipv;

# Terminals with no events

my %nv;

while ( <IN> )
{
	# Count the events. Sometimes, the id for a PEB is "0".
	if ( ( /($rgex::ivo)\s+($rgex::peb)\s+($rgex::pebtype)\s+($date)\s+($rgex::fulltime)\s+($rgex::eid)\s+($event)/ ) )
	{
		$v++;
		
		my $vid = $1;
		my $pid = $2;
		
		utl::incrementHashValue( \%iv, $vid );
		utl::incrementHashValue( \%pv, $pid );
		utl::incrementHoHValue( \%ipv, $vid, $pid );
	}
	# Make a list of all the iVo terminals
	elsif ( /($rgex::ivo)\s+$rgex::peb.*/ )
	{
		my $vid = $1;

		$nv{ $vid } = 1;
	}
}

# Remove terminals with no events from the list of all terminals.
utl::cleanHash( \%nv, \%iv );

# Pretty the $date string for printing. If it does not contain an actual
# date, make it null; if it does, remove leftover regexp escape characters and
# separate dates by comma.
$date = cleanDate( $date );

# pretty event string for printing
$event = cleanEvent( $event );

# Print output file

my $z;

print "\n$date total number of events ($event):  $v\n";
print OUT "$date total number of events ($event):  $v\n";

utl::printHash( \*OUT, "\n$date total events by iVotronic voting terminal\n\n", \%iv );
$z = utl::sumHashValues( \%iv );
print OUT "\n$date total events by iVotronic voting terminal: $z\n";
print "$date total events by iVotronic voting terminal: $z\n";

utl::printHash( \*OUT, "\n$date total events by PEB\n\n", \%pv );
$z = utl::sumHashValues( \%pv );
print OUT "\n$date total events by PEB: $z\n";
print "$date total events by PEB: $z\n";

utl::printHoH( \*OUT, "\n$date total events by iVotronic voting terminal and PEB\n\n", \%ipv );
$z = utl::sumHoHValues( \%ipv );
print OUT "\n$date total events by iVotronic voting terminal and PEB: $z\n";
print "$date total events by iVotronic voting terminal and PEB: $z\n";

my $z = utl::printHashKeys( \*OUT, "\n$date iVotronic terminals with no events\n\n", \%nv );
print OUT "\n$date iVotronic terminals with no events: $z\n";
print "$date iVotronic terminals with no events: $z\n";

print "\n";

######################## functions ########################

sub help
{
	print "\nperl count152.pl -i [input file] -o [output file] -d [date]\n";
	print "                 -e [event]\n\n";
	print "The -d parameter is optional. If the parameter is missing, all specified\n";
	print "events in the log file are counted. Otherwise, only specified events on\n";
	print "the specified date, such as '11/02/2010', are counted. The format is\n";
	print "\"MM/DD/YYYY\"\n\n";
	print "The -e parameter is also optional. If the argument is not provided, all\n";
	print "and only vote_cast events are counted. Multiple events may be listed\n\n";
	print "Regular expressions may be used with the -d and -e options.\n\n";
	exit();
}


# If the date variable has a regexp string, set the date variable to the
# empty string. Otherwise, remove any regexp characters, separate dates by
# comma and append a dash to the string for prettier printing.
sub cleanDate
{
	my ( $date ) = @_;

	if ( $date !~ /\d{2}\/\d{2}\/\d{2,4}/ )
	{
		$date = ""; 
	}
	else
	{
		$date =~ s/\|/, /g;
		$date .= " -"; 
	}

	return $date;
}

# pretty event string for printing by replacing '|' (for
# regexp format) with a comma followed by a space.

sub cleanEvent
{
	my ( $e ) = @_;

	$e =~ s/\|/, /g;

	return $e;
}
