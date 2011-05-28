# perl code

# el68aPrcOrder.pl

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

# parse a el68a system log file and rewrite in precinct order as opposed to
# the default temporal order.

use strict;
require utl;
require rgex;

# Use base class Exporter in order to export methods "myHelp" and "help"
# so that these can be called and passed around in objects including this
# package without need of namespace qualifier.
use base 'Exporter';
our @EXPORT = ( 'help' );

my $args = utl::parseCommandLine( \@ARGV, 4, "-d_-i_-o", \&help );

# Okay, this is not obvious but the date string in the ARGV array may
# contain multiple dates with underscore characters between the dates, for
# instance, "11-02_11-03_11-04". Here we replace the "_" with a "|"
# character and assign it to the $date variable.

( my $date = $args->{ "-d" } ) =~ s/_/|/g;

my $in = $args->{ "-i" };
my $out = $args->{ "-o" };

# open input and output files

open( my $IN, "< $in" ) || die "Unable to open $in\n";
open( my $OUT, "> $out" ) || die "Unable to create $out\n";

# If modifying all the entries, use this string to match all dates,
# otherwise use the string in ARGV array. The date string always has two
# digit numbers separated by a dash.
if ( !$date )
{
	$date = $rgex::date;
}

# all voting records sorted by precinct
my %records = ();

# the current mode, group and prc for downloading voting results.
my $md;
my $grp;
my $prc;

while ( <$IN> )
{
	chomp;

	# Consider all lines in the file if no date parameters are defined.
	# Otherwise, only lines with the appropriate date or dates are looked
	# at. 
	if ( /$date/ )
	{
		if ( /PRC\s(\d{4})/ )
		{
			$prc = $1;
			
			# if downloading votes, add group and mode info
			if ( /\(BALS=\d{1,4}\sTOT=\d{1,4}\)/ )
			{
				$_ .= " (MODE=$md GRP=$grp)";			
			}
			
			if ( defined( $records{ $prc } ) )
			{
				my $t = $records{ $prc };
				$t .= "_" . $_;
				$records{ $prc } = $t;
			}
			else
			{
				$records{ $prc } = $_;
			}
		}
		elsif ( /DATABASE\sRESET/ )
		{
			utl::appendHash( $_, "_", \%records );
		}
		elsif ( /START\s650\sDOWNLOAD\s\((Replace|Add-to).*?\)\s\(GRP\s(\d{1,2})\)/ )
		{
			$md = $1;
			$grp = $2;		
		}
	}
}

utl::printHashRecords( $OUT, "", "_", \%records );

#######################################################
#
# help functions
#
#######################################################


sub help
{
	print "\nperl el68aPrcOrder.pl -i [input file] \n";
	print "           -o [output file] -d [date]\n\n";
	print "Rewrite precinct records in el68a system log file\n";
	print "in precinct order instead of temporal order\n";
	exit();
}
