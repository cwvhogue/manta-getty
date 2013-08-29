#!/usr/bin/env bash

mmkdir /$MANTA_USER/public/getty-open/500x500_jpg
mmkdir /$MANTA_USER/public/getty-open/1000x1000_jpg
mmkdir /$MANTA_USER/public/getty-open/2000x2000_jpg

# strategy is to populate SnapLinks to originals into the target directory and use them as job inputs:

mfind /$MANTA_USER/public/getty-open/originals | mjob create -w -m 'mln $MANTA_INPUT_OBJECT ${MANTA_INPUT_OBJECT/originals/500x500_jpg/}'
mfind /$MANTA_USER/public/getty-open/500x500_jpg -n 'jpg$' | \
 mjob create -w -m 'convert $MANTA_INPUT_FILE -colorspace RGB -resize 250000@ \
 -colorspace sRGB -quality 80 /var/tmp/out.jpg && \
 mpipe ${MANTA_INPUT_OBJECT%.*}.jpg < /var/tmp/out.jpg'
# and here the SnapLinks are overwritten 

mfind /$MANTA_USER/public/getty-open/originals | mjob create -w -m 'mln $MANTA_INPUT_OBJECT ${MANTA_INPUT_OBJECT/originals/1000x1000_jpg/}'
mfind /$MANTA_USER/public/getty-open/1000x1000_jpg -n 'jpg$' | \
 mjob create -w -m 'convert $MANTA_INPUT_FILE -colorspace RGB -resize 1000000@ \
 -colorspace sRGB -quality 80 /var/tmp/out.jpg && \
 mpipe ${MANTA_INPUT_OBJECT%.*}.jpg < /var/tmp/out.jpg'

mfind /$MANTA_USER/public/getty-open/originals | mjob create -w -m 'mln $MANTA_INPUT_OBJECT ${MANTA_INPUT_OBJECT/originals/2000x2000_jpg/}'
mfind /$MANTA_USER/public/getty-open/2000x2000_jpg -n 'jpg$' | \
 mjob create -w -m 'convert $MANTA_INPUT_FILE -colorspace RGB -resize 4000000@ \
 -colorspace sRGB -quality 80 /var/tmp/out.jpg && \
  mpipe ${MANTA_INPUT_OBJECT%.*}.jpg < /var/tmp/out.jpg'

