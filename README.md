These programs clean up various Unity ERM data files so processing with other scripts is 
easier.

See the "South Carolina Voting Information" web site for background
 http://www.scvotinginfo.com/

Test data, based on data from that site, is in the testdata folder.

File formats
============

 el152.lst	log file of all events on all voting terminals used in a voting jurisdiction, such as a county or town

 el68.lst	contains all manual adjustments made by the election staff during an election

Examples
========

    perl clean152.pl -i testdata/colleton_co_02_01_11_el152.lst  -o testdata/colleton_co_02_01_11_el152.clean
    perl clean68.pl -i testdata/colleton_co_02_01_11_el68_ab.txt  -o testdata/colleton_co_02_01_11_el68_ab.clean

License
=======
This is open source software, using the "MIT" (aka "X11") license.
