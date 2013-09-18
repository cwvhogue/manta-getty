#!/usr/bin/env bash

# Variables are sed search and replace arguments
STRIP_XML="s/<[^>]*>//g"
FIX_XMPDASH="s/xmp-/jpg /"

# This is a map-reduce job that extracts one line from the Getty Open XMP XML
# That is extracted by manta_image_convert.sh 
# THe job uses grep -H to put the file name at the front of each line
# the -A4 makes grep emit 4 lines after the location of the <dc:description> tag
# The unneeded lines are removed with head and tail 
# then sed is used to remove the XML tag and change the filename back to the .jpg extension
# so it refers to the original

mfind -t o /$MANTA_USER/public/images/getty-open/metadata_xmp -n 'xmp$' | \
mjob create -w -m "grep -H --label=\`basename \$MANTA_INPUT_OBJECT\` -A4 '<dc:description>' | head -3 | tail -1 | \
sed -e '${STRIP_XML}' -e '${FIX_XMPDASH}' " \
-r "cat > /var/tmp/out.txt && sort -n /var/tmp/out.txt | mput /$MANTA_USER/public/images/getty-open/onelinertest.txt"


# The resulting file has escaped characters which still need to be changed with sed
 
AMPERSAND='s/&amp;/\&/g'
DBLQUOTE='s/&quot;/\"/g' 
QUOTE="s/&#39;/\'/g"

# This part pulls the fille from Manta, fixes the escaped characters in it, and puts it back into place

mget /$MANTA_USER/public/images/getty-open/onelinertest.txt > onelinertest.txt
cat onelinertest.txt | sed -e "${DBLQUOTE}" -e "${QUOTE}" -e "${AMPERSAND}" | \
tee onelinerfix.txt | mput /$MANTA_USER/public/images/getty-open/130812_GettyOpen_descriptions.txt

