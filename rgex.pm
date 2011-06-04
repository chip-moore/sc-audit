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

# regexp to match date format (00/00) in Unity ERM files.
$rgex::date = "\\d{2}-\\d{2}";

# regexp to match date format (00/00/0000 or 00/00/00) in event log files.
$rgex::fulldate = "\\d{2}\\/\\d{2}\\/\\d{2,4}";

# regexp to match four digit precinct number in Unity ERM files.
$rgex::prc = "\\d{4}";

# regexp to match time string (00:00) in Unity ERM files.
$rgex::time = "\\d{2}:\\d{2}";

# regexp to match time string (00:00:00) in event log files.
$rgex::fulltime = "\\d{2}:\\d{2}:\\d{2}";

# regexp to match "am" or "pm" in Unity ERM files.
$rgex::ampm = "am|AM|pm|PM";

# regexp to match group number, which may be missing from some
# records in Unity ERM files.
$rgex::grp = "\\d{0,1}";

# regexp to match one, two, three, four or five digit number.
$rgex::1to5digits = "\\d{1,5}";

# regexp to match PEB id
$rgex::peb = "\\d{1,6}";

# regexp to match PEB type
$rgex::pebtype = "\\w{3}";

# regexp to match iVo id
$rgex::ivo = "\\d{7}";

# regexp to match event id in event log file
$rgex::eid = "\\d{1,7}";

# regexp to match "vote cast" events in a cleaned el152 event log file.
$rgex::vote_cast_event = "vote_cast_by_voter|vote_cast_by_poll_worker";

# regexp to match record format of vote image file. This returns six values
# in the number variables, iVo id, ballot image id, aserisk indicating ballot
# border, candidate id, candidate name and contest name.
$rgex::ballot_record = "^($rgex::ivo)\\s+(\\d+)\\s+(\\*{0,1})\\s+(\\d+)\\s+($rgex::str)\\s\\s\\s+($rgex::str)\$";

# regexp to match precinct heading in vote image file - the values in the
# number variables are date, time, am or pm, stuff between am/pm value and
# precinct number value, precinct number, precinct name and rest of line.
$rgex::precinct_record = "^RUN\\sDATE:(\\d{2}\\/\\d{2}\\/\\d{2})\\s($rgex::time)\\s($rgex::ampm)(\\s+PRECINCT\\s+)(\\d{1,4})\\s\-\\s($rgex::str)(\\s\\s\\s\\s.*)\$";

# illegal characters that need to be removed
$rgex::bad_chars = " ";

# the package has to return true to load.
1;
