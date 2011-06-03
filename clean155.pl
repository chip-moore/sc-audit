# perl code

# clean155.pl

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

# Script for fixing naming errors in the ballot image file. For instance,
# some contests have multiple names, such as "HOU0072 Stae House of Rep Dist
# 72" and "HWS0072 State House of Rep Dist 72" and some candidate and precinct
# names contain multiple spaces between tokens that should be separated by a
# single space, such as "Hemphill  P Pride III".

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

# Read and 1) gather data or 2) repair names in vote image file.

while ( <IN> )
{
	# writing the clean file using a translation table
	if ( $trns )
	{
		# replace bad characters with a space character.
		$_ =~ s/$bc/ /g;

		if ( /$rgex::ballot_record/ )
		{
			my $cnd = $5;
			my $cnt = $6;
			
			if ( defined $name2name{ $cnd } )
			{
				$cnd = $name2name{ $cnd };
			}
			
			if ( defined $name2name{ $cnt } )
			{
				$cnt = $name2name{ $cnt };
			}

			utl::printBIrecord( $1, $2, $3, $4, $cnd, $cnt, \*OUT );
		}
		elsif ( /$rgex::precinct_record/ )
		{
			my $prc = $6;
			
			if ( defined $name2name{ $prc } )
			{
				$prc = $name2name{ $prc };
			}

			print OUT "RUN DATE:$1 $2 $3$4$5 - $prc$7\n";
		}
		else
		{
			print OUT $_;
		}
	}
	# reading the file to get a list of candidates, contests and precinct names.
	else
	{		
		if ( /$rgex::ballot_record/ )
		{
			# Grab the candidate name
			if ( !defined( $name2name{ $5 } ) )
			{
				$name2name{ $5 } = 1;
			}

			# Grab the contest name
			if ( !defined( $name2name{ $6 } ) )
			{
				$name2name{ $6 } = 1;
			}
		}
		# Grab the precinct name
		elsif ( /$rgex::precinct_record/ )
		{
			if ( !defined( $name2name{ $6 } ) )
			{
				$name2name{ $6 } = 1;
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

##############################################################

sub help
{
	print "\nperl fixEl155.pl -i [input file] -o [output file]\n";
	print "                 -b [bad characters] -t [translation file]\n\n";
	print "1) Declare -i and -o only to build list of names in vote\n";
	print "   image file from which a translation table is created\n\n";
	print "2) Declare -i, -o and -t to use translation table to\n";
	print "   fix naming problems in vote image file\n\n";
	print "The -b parameter is optional. If the users need to globally remove certain\n";
	print "characters, create a file with all the bad characters as a single string\n";
	print "on a single line at the top of the file. The illegal characters are\n";
	print "replaced by a space character\n\n";
	
	exit();
}
