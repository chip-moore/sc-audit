# perl code

# clean152.pl

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

# a script for rewriting an el152.lst ES&S event log file to make it
# easier to parse.

use strict;
require utl;
require rgex;

# Use base class Exporter in order to export method "help" so that these
# can be called and passed around in objects including this package without
# need of namespace qualifier.
use base 'Exporter';
our @EXPORT = ( 'help' );

my $args = utl::parseCommandLine( \@ARGV, 4, "-i_-o", \&help );

my $in = $args->{ "-i" };
my $out = $args->{ "-o" };

# open input and output files

open( IN, "< $in" ) || die "\nUnable to open $in\n";
open( OUT, "> $out" ) || die "\nUnable to create $out\n";

# variables
my $vid;
my $peb;
my $eid;
my $time;
my $date;
my $type;
my $desc;

print OUT "Votronic PEB\tType\tDate\t\tTime\t\tEvent\tDescription\n\n";

while ( <IN> )
{
	chomp;
	
	# The date record may have two or four digits in the year field.
	# Both votronic and PEB id in record
	if ( /($rgex::ivo)\s+($rgex::peb)\s+($rgex::pebtype)\s+($rgex::fulldate)\s+($rgex::fulltime)\s+($rgex::eid)\s+(.*)/ )
	{
		$vid = $1;
		$peb = $2;
		$type = $3;
		$date = $4;
		$time = $5;
		$eid = $6;

		$desc = utl::clean( $7 );
	}
	# Only PEB id in record
	elsif ( /($rgex::peb)\s+($rgex::pebtype)\s+($rgex::fulldate)\s+($rgex::fulltime)\s+($rgex::eid)\s+(.*)/ )
	{
		$peb = $1;
		$type = $2;
		$date = $3;
		$time = $4;
		$eid = $5;

		$desc = utl::clean( $6 );
	}
	# Neither votronic or PEB id in record
	elsif ( /\s+($rgex::pebtype)\s+($rgex::fulldate)\s+($rgex::fulltime)\s+($rgex::eid)\s+(.*)/ )
	{
		$type = $1;
		$date = $2;
		$time = $3;
		$eid = $4;

 		$desc = utl::clean( $5 );
	}
	# Only votronic id in record
	elsif ( /($rgex::ivo)\s+($rgex::pebtype)\s+($rgex::fulldate)\s+($rgex::fulltime)\s+($rgex::eid)\s+(.*)/ )
	{
		$vid = $1;
		$type = $2;
		$date = $3;
		$time = $4;
		$eid = $5;

 		$desc = utl::clean( $6 );
	}
	# Skip lines that do not contain a record
	else
	{
		next;
	}

	print OUT "$vid\t$peb\t$type\t$date\t$time\t$eid\t$desc\n";
}


#################################

sub help
{
	print "\nperl clean152.pl -i [input file] -o [output file]\n\n";
	exit();
}

