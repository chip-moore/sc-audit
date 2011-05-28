# perl code

# utl.pm

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

# utility functions

# parseCommandLine( \@ARGV, $n, $opt, \&help )
#
# first parameter is the ARGV array, the second parameter is the minimum number
# of paramaters being parsed, the third parameter is string containing
# valid options for script and fourth parameter is a pointer to a help function.
#
# returns hash table of arg switches and arg values

# validFileName( $filename )
#
# Perl requires that slashes between directory names be doubled, i.e.
# "directory\\filename", not "directory\filename".
#
# returns $filename

# printList( $fh, $header, \@list )
#
# print all the items in a list, one per line.
#
# returns null

# printHash( $fh, $header, \%hash )
#
# print all the items in a hash table, one per line
#
# returns null

# printHashRecords( $fh, $header, $c, \%hash )
#
# print all the records, one per line, in a hash table of records, each
# record separated in the hashed item by $c character.
#
# returns null

# zeroPad( $number, $length )
#
# So that "2" sorts before "10", pad the front of  numbers with zeros, so
# that "2" becomes "0002" and "10" becomes "0010". The first parameter is
# the initial number and the second parameter is the length of the final
# number.
#
# return $paddedNumber

# appendHash( $r, $c, \%h )
#
# Append to the end of every value in hash table $h the value in $r
# using $c to separate records.
#
# returns null

# clean( $s )
#
# In string $s, lowercase everything, trim leading spaces, trim trailing
# spaces, remove any character that isn't a letter, digit or underscore
# and replace spaces with underscore characters.
#
# returns $s ( modified string )


use strict;
package utl;


############################################################
#
# command line functions
#
############################################################

sub parseCommandLine
{
	my ( $argv, $n, $o, $help ) = @_;

	# Is the user just asking for the help screen? Are they
	# providing the minimum number of parameters?
	if ( ( $argv->[0] =~ /\?/ ) ||
		 ( @$argv == 0 ) ||
		 ( @$argv < $n ) )
	{
		$help->();
	}

	my %args = ();
	my @opts = split( "_", $o );
	$o =~ s/_/\|/g;

	for ( my $j = 0; $j < @opts; $j++ )
	{
		for ( my $i = 0; $i < @$argv; $i++ )
		{
			if ( $argv->[$i] eq "$opts[$j]" )
			{
				if ( ( ( $i + 1 ) < @$argv ) &&
					 ( $argv->[$i + 1] !~ /(\-\|\?)/ ) )
				{
					my $t = validFileName( $argv->[++$i] );

					# some options, such as date may have multiple
					# values, so if this parameter already has a value,
					# prepend new value to front of present value.
					if ( defined $args{ $opts[$j] } )
					{
						$t = $t . "_" . $args{ $opts[$j] };
					}
					
					$args{ $opts[$j] } = $t;
				}
				else
				{
					print "\ninvalid parameter value ($argv->[$i + 1]) for parameter option $opts[$j].\n";
					$help->();
				}
			}
		}
	}

	return \%args;
}

############################################################

sub validFileName
{
	my ( $f ) = @_;

	# Perl requires that slashes between directory names be doubled, i.e.
	# "directory\\filename", not "directory\filename".
	if ( $f !~ /\/\// )
	{
		$f =~ s/\//\/\//g;
	}

	return $f;
}

############################################################
#
# print functions
#
############################################################

# print all the items in a list, one per line.

sub printList
{
	my ( $fh, $header, $list ) = @_;

	print $fh "$header";
	
	for ( my $i = 0; $i < @$list; $i++ )
	{
		print $fh "$list->[$i]\n";
	}
}


#########################################################

# print all the items in a hash table, one per line

sub printHash
{
	my ( $fh, $header, $hash ) = @_;

	print $fh "$header";

	foreach my $key ( sort keys %$hash )
	{
		print "$hash->{ $key }\n";
	}
}

#########################################################

# print all the records, one per line, in a hash table of records, each
# record separated in the hashed item by $c character.

sub printHashRecords
{
	my ( $fh, $header, $c, $hash ) = @_;

	print $fh "$header";

	foreach my $key ( sort keys %$hash )
	{
		my $r = $hash->{ $key };
		my @f = split( $c, $r );

		for ( my $i = 0; $i < @f; $i++ )
		{
			print $fh "$f[$i]\n";
		}
	}
}


############################################################
#
# misc functions
#
############################################################

# So that "2" sorts before "10", pad the front of precinct numbers with
# zeros, so that "2" becomes "0002" and "10" becomes "0010". The first
# parameter is the initial number and the second parameter is the length of
# the final number.
sub zeroPad
{
	my ( $n, $p ) = @_;

	my $t;
	
	SWITCH: {
		if ( $p == 1 ) { $t = 1; last SWITCH; }
		if ( $p == 2 ) { $t = 10; last SWITCH; }
		if ( $p == 3 ) { $t = 100; last SWITCH; }
		if ( $p == 4 ) { $t = 1000; last SWITCH; }
		if ( $p == 5 ) { $t = 10000; last SWITCH; }
		if ( $p == 6 ) { $t = 100000; last SWITCH; }
		if ( $p == 7 ) { $t = 1000000; last SWITCH; }
		if ( $p == 8 ) { $t = 10000000; last SWITCH; }
		if ( $p == 9 ) { $t = 100000000; last SWITCH; }
	}

	$t += $n;

	# Convert the leading '1' to a '0'.
	$t =~ s/1/0/;

	return $t;
}

#########################################################

# Return true if first string parameter matches second
# string parameter.

# TODO: fix current method.

sub match
{
	my ( $x, $m ) = @_;

	my @l = split( "_", $m );

	for ( my $i = 0; $i < @l; $i++ )
	{
		if ( $l[$i] eq $x )
		{
			return 1;
		}
	}

	return 0;
}

#########################################################

# Append to the end of every value in hash table $h the value in $r
# using $c to separate records.


sub appendHash
{
	my ( $r, $c, $h ) = @_;

	foreach my $k ( keys %$h )
	{
		my $t = $h->{ $k };
		$t .= $c . $r;
		$h->{ $k } = $t;
	}	
}

#########################################################

# Lowercase everything, trim leading spaces, trim trailing spaces,
# remove any character that isn't a letter, digit or underscore and
# replace spaces with underscore characters.
sub clean
{
	my $s = $_[0];

	# lowercase everything
	$s =~ tr/A-Z/a-z/;

	# trim leading spaces
	$s =~ s/^(\s+)(\w.*)/$2/g;

	# trim trailing spaces
	$s =~ s/(.*\w+)(\s+)$/$1/g;

	# convert spaces to underscores
	$s =~ s/\s/_/g;

	# convert dashes to underscores
	$s =~ s/-/_/g;

	# remove all characters accept A-Z, a-z, and 0-9
	$s =~ s/\W//g;

	# collapse multiple underscores to single underscore
	$s =~ s/_+/_/g;

	return $s;
}


# the package has to return true to load.
1;
