# perl code

# rgex.pm

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

# functions and expressions using regexp in useful ways.

# Chip Moore ( 2010 - 2011 )

#####################################################

use strict;
package rgex;

# regexp to match string that may include spaces or numbers.
$rgex::str = "\\w.*?\\w";

# regexp to match date format in Unity ERM files.
$rgex::date = "\\d{2}-\\d{2}";

# regexp to match four digit precinct number in Unity ERM files.
$rgex::prc = "\\d{4}";

# regexp to match time string (00:00) in Unity ERM files.
$rgex::time = "\\d{2}:\\d{2}";

# regexp to match "am" or "pm" in Unity ERM files.
$rgex::ampm = "am|pm";

# regexp to match group number, which may be missing from some
# records in Unity ERM files.
$rgex::grp = "\\d{0,1}";

# regexp to match one, two, three, four or five digit number.
$rgex::1to5digits = "\\d{1,5}";


# the package has to return true to load.
1;
