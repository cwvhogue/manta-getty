manta-getty
===========

Scripts to maintain the Getty Open Image set mirror on Joyent Manta, broken images removed.

4,596 JPEG formatted files ranging from 3 to 327 MB in size.
Total data size is 101.6 GB. 
14 files are larger than 100 MB. 
Most are ~20 MB. 

Filnames are 8 digit numbers which are uids used by Getty Trust.

Metadata for each art image can be obtained with http://www.getty.edu/Search/SearchServlet
by pasting in the numerical portion of the filename.

Broken images are: 00660201.jpg 03901101.jpg 10821901.jpg - on the chance that they 
are repaired in the future. 

Assumes you have installed the node.js manta package, 
and that have created a /$MANTA_USER/public/art subdirectory on Joyent Manta.

The script works fastest from within a minimal Joyent SmartOS instance on the 
same datacenter as you are using for Manta, but can be used remotely.
