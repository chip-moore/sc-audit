These programs clean up various Unity ERM data files so processing with other scripts is 
easier.

See the "South Carolina Voting Information" web site for background
 http://www.scvotinginfo.com/

Scripts
=======

    perl clean152.pl -i [input file] -o [output file]

This script fills in the missing fields in each record in the Unity ERM el152 event log file, separates fields 
by tab for easy loading into spreadsheet and lowercases error messages for easy sorting.

    perl clean68.pl -i [input file] -o [output file] -d [date in MM-DD format]
                    Define one or more dates so output file contains only data from those dates. The -d option
                    is optional. The default is to write out data from all dates.

This script fills in the missing fields in each record in the Unity ERM el68 manual adjustment log file and 
separates fields by tab for easy loading into spreadsheet.

    perl el68aPrcOrder.pl -i [input file] -o [output file] -d [date in MM-DD format]
                    Define one or more dates so output file contains only data from those dates. The -d option
                    is optional. The default is to write out data from all dates.

This script rewrites the el68s Unity ERM system log file in precinct order, which facilitates finding some patterns 
of events and errors.

Packages
========

    utl.pm

Contains several functions used by multiple scripts.

    rgex.pm

Contains several regular expressions used by multiple scripts    

Notes
=====

See HELP for any script by running script with no parameters defined, or with '?' as first parameter.

Test data, based on data from the www.scvotinginfo.com site, is in the testdata folder.

File formats
============

    el152.lst

log file of all events, such as "vote cast by voter" or "select election services menu", on all iVotronic voting terminals used in a voting jurisdiction, such as a county or town

    el68.lst	

file of all manual adjustments made by the election staff during an election

    el68a.lst      

Unity ERM system log file

Examples
========

    perl clean152.pl -i testdata/colleton_co_02_01_11_el152.lst  -o testdata/colleton_co_02_01_11_el152.clean
    perl clean68.pl -i testdata/colleton_co_02_01_11_el68_ab.txt  -o testdata/colleton_co_02_01_11_el68_ab.clean
                    -d 11-02 -d 11-03
    perl el68aPrcOrder.pl -i testdata/colleton_co_02_01_11_el68a.lst -o testdata/colleton_co_02_01_11_el68a.Prc.Order

License
=======
This is open source software, using the "MIT" (aka "X11") license.
