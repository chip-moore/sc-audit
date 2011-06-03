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

# BEWARE: problems are created by odd chars in file, such as

# Morgan Bruce Reeves   (0x0a)
# 63MANUAL (0x0d 0x0c)

use strict;
require utl;
require rgex;

# Use base class Exporter in order to export method "help" so that these can
# be called and passed around in objects including this package without need
# of namespace qualifier.
use base 'Exporter';
our @EXPORT = ( 'help' );

my $args = utl::parseCommandLine( \@ARGV, 4, "-b_-i_-o_-t", \&help );

my $in = $args->{ "-i" };
my $out = $args->{ "-o" };
my $bad = $args->{ "-b" };
my $trns = $args->{ "-t" };

# open input and output files

open( IN, "< $in" ) || die "Unable to open $in\n";
open( OUT, "> $out" ) || die "Unable to create $out\n";

# translation table

my %name2name;

# Build translation table if fixing bad names in file.

if ( $trns )
{
	open( TRNS, "< $trns" ) || die "Unable to open $trns\n";

	utl::getTranslations( \%name2name, \*TRNS );
}

# string of bad characters to remove

my $bc;

if ( $bad )
{
	open( BAD, "< $bad" ) || die "Unable to open $bad\n";

	$bc = <BAD>;
	chomp $bc;
	$bc = "[" . $bc . "]";
}
else
{
	$bc = ' ';
}

my $precinctNumber;
my $precinctName;
my $candidate;

while ( <IN> )
{
	if ( $trns )
	{
		# remove commas from numbers because they screw-up parsing
		$_ =~ s/,//g;

		# replace bad characters with a space character.
		$_ =~ s/$bc/ /g;
		
		# precinct name and candidate name
		if ( /^($rgex::prc)\s($rgex::str)\s\s\s+?($rgex::str)\s\s\s+($rgex::date)\s($rgex::time)\s($rgex::ampm)\s\s(\d{0,1})\s\s+(\d{1,5})\s+(\d{1,5})/ )
		{
			$precinctNumber = $1;
			$precinctName = ( defined( $name2name{ $2 } ) ? $name2name{ $2 } : $2 );
			$candidate = ( defined( $name2name{ $3 } ) ? $name2name{ $3 } : $3 );

			printf OUT "%4s %-35s%-45s%5s %5s %2s  %2s  %6d  %8d\n", $precinctNumber,
					$precinctName, $candidate, $4, $5, $6, $7, $8, $9;
		}
		# precinct name
		elsif ( /^($rgex::prc)\s($rgex::str)\s\s\s+?($rgex::date)\s($rgex::time)\s($rgex::ampm)\s\s(\d{0,1})\s\s+(\d{1,5})\s+(\d{1,5})/ )
		{
			$precinctNumber = $1;
			$precinctName = ( defined( $name2name{ $2 } ) ? $name2name{ $2 } : $2 );

			printf OUT "%4s %-35s%-45s%5s %5s %2s  %2s  %6d  %8d\n", $precinctNumber,
				$precinctName, $candidate, $3, $4, $5, $6, $7, $8;
		}
		# candidate name
		elsif ( /^\s\s\s+?($rgex::str)\s\s\s+($rgex::date)\s($rgex::time)\s($rgex::ampm)\s\s(\d{0,1})\s\s+(\d{1,5})\s+(\d{1,5})/ )
		{
			$candidate = ( defined( $name2name{ $1 } ) ? $name2name{ $1 } : $1 );

			printf OUT "%4s %-35s%-45s%5s %5s %2s  %2s  %6d  %8d\n", $precinctNumber,
				$precinctName, $candidate, $2, $3, $4, $5, $6, $7;
		}
		# neither candidate name nor precinct name
		elsif ( /\s+($rgex::date)\s($rgex::time)\s($rgex::ampm)\s\s(\d{0,1})\s\s+(\d{1,5})\s+(\d{1,5})/ )
		{
			printf OUT "%4s %-35s%-45s%5s %5s %2s  %2s  %6d  %8d\n", $precinctNumber,
				$precinctName, $candidate, $1, $2, $3, $4, $5, $6;
		}
		# reinsert comma in header date that is stripped out at top of
		# loop.
		elsif ( /^(\s+)(\w{3,9})\s(\d{1,2})\s(\d{4})/ )
		{
			print OUT "$1$2 $3, $4\n";;
		}
		else
		{
			print OUT $_;
		}
	}
	# reading the file for a list of candidate and precinct names.
	else
	{
		if ( /^($rgex::prc)\s($rgex::str)\s\s\s+?($rgex::str)\s\s\s+($rgex::date)\s($rgex::time)\s($rgex::ampm).*/ )
		{
			# precinct name
			if ( !defined( $name2name{ $2 } ) )
			{
				$name2name{ $2 } = 1;
			}

			# candidate name
			if ( !defined( $name2name{ $3 } ) )
			{
				$name2name{ $3 } = 1;
			}
		}
		elsif ( /^($rgex::prc)\s($rgex::str)\s\s\s+?($rgex::date)\s($rgex::time)\s($rgex::ampm).*/ )
		{
			# precinct name
			if ( !defined( $name2name{ $2 } ) )
			{
				$name2name{ $2 } = 1;
			}
		}
		elsif ( /^\s\s\s+?($rgex::str)\s\s\s+($rgex::date)\s($rgex::time)\s($rgex::ampm).*/ )
		{
			# candidate name
			if ( !defined( $name2name{ $1 } ) )
			{
				$name2name{ $1 } = 1;
			}
		}
	}
}

# print the list of names in the manual adjustment file if building a
# translation table.

if ( !$trns )
{
	utl::printHashKeys( \*OUT, "names", \%name2name );
}

#################################


sub help
{
	print "\nperl clean68ab.pl -i [input file] -o [output file]\n";
	print "                   -b [bad characters] -t [translation table]\n\n";    
	print "1) Declare -i and -o only to build list of names in manual\n";
	print "   adjustment file from which a translation table is created\n\n";
	print "2) Declare -i, -o and -t to use translation table to\n";
	print "   fix naming problems in manual adjustment file\n\n";
	print "The -b parameter is optional. If the users need to globally remove certain\n";
	print "characters, create a file with all the bad characters as a single string\n";
	print "on a single line at the top of the file. The illegal characters are\n";
	print "replaced by a space character\n\n";
	exit();
}

