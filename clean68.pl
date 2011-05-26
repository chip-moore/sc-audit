# perl code

# clean68.pl

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

# a script for rewriting an el68.lst ES&S audit file to make it easier to
# parse. The el68.lst file contains the details of manual adjustments to
# the vote tally.

# TODO: fix problems caused by odd chars in file, such as

# Morgan Bruce Reeves   (0x0a)
# 63MANUAL (0x0d 0x0c)

use strict;
require utl;
require rgex;

# Use base class Exporter in order to export methods "myHelp" and "help"
# so that these can be called and passed around in objects including this
# package without need of namespace qualifier.

use base 'Exporter';
our @EXPORT = ( 'help' );

my $args = utl::parseCommandLine( \@ARGV, 4, "-d_-i_-o", \&help );

my $in = $args->{ "-i" };
my $out = $args->{ "-o" };
my $date = $args->{ "-d" };

# If no -d option is defined in the ARGV array, use this string to match all
# dates. The date string is always two digits separated by a dash.

if ( !( defined $date ) )
{
	$date = $rgex::date;
}

# open input and output files

open( IN, "< $in" ) || die "Unable to open $in\n";
open( OUT, "> $out" ) || die "Unable to create $out\n";

my $precinctNumber;
my $precinctName;
my $candidate;

while ( <IN> )
{
	# Remove commas from numbers as they screw parsing
	$_ =~ s/,//g;
	
	# Get precinct name and number and candidate name
	if ( /^($rgex::prc)\s($rgex::str)\s\s\s+?($rgex::str)\s\s\s+.*/ )
	{
		$precinctNumber = $1;
		$precinctName = $2;
		$candidate = $3;
	}

	# Get the candidate name
	if ( /^\s\s\s+?($rgex::str)\s\s\s+\d{2}-\d{2}\s$rgex::time.*/ )
	{
		$candidate = $1;
	}


	if ( /^($rgex::prc)\s($rgex::str)\s\s\s+?($rgex::str)\s\s\s+($date)\s($rgex::time)\s($rgex::ampm)\s\s($rgex::grp)\s\s\s+($rgex::1to5digits)\s\s\s+($rgex::1to5digits).*/ )
	{
		print OUT "$precinctNumber\t";
		printf OUT "%20s\t%20s\t%5s\t%5s %2s\t%4d\t%4d\t%4d\n", $precinctName,
			$candidate, $4, $5, $6, $7, $8, $9;
	}
	elsif ( /^\s\s\s+?($rgex::str)\s\s\s+($date)\s($rgex::time)\s($rgex::ampm)\s\s($rgex::grp)\s\s\s+($rgex::1to5digits)\s\s\s+($rgex::1to5digits).*/ )
	{
		print OUT "$precinctNumber\t";
		printf OUT "%20s\t%20s\t%5s\t%5s %2s\t%4d\t%4d\t%4d\n", $precinctName,
			$candidate, $2, $3, $4, $5, $6, $7;
	}
	elsif ( /^\s\s\s\s\s\s+?($date)\s($rgex::time)\s($rgex::ampm)\s\s($rgex::grp)\s\s\s+($rgex::1to5digits)\s\s\s+($rgex::1to5digits).*/ )
	{
		print OUT "$precinctNumber\t";
		printf OUT "%20s\t%20s\t%5s\t%5s %2s\t%4d\t%4d\t%4d\n", $precinctName,
			$candidate, $1, $2, $3, $4, $5, $6;
	}
}


#################################


sub help
{
	print "\nperl clean68ab.pl -i [input file] -o [output file] -d [date]\n\n";
	print "The -d parameter is optional. If the parameter is missing, all manual\n";
	print "adjustment records are cleaned. Otherwise, only records on the specified\n";
	print "date, such as '11-03', are cleaned and written to the output file.\n\n";
	exit();
}

