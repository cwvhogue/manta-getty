#!/usr/bin/env bash

mmkdir /$MANTA_USER/public/getty-open/500x500_png
mmkdir /$MANTA_USER/public/getty-open/1000x1000_png
mmkdir /$MANTA_USER/public/getty-open/2000x2000_png

mfind /$MANTA_USER/public/getty-open/originals | mjob create -w -m 'mln $MANTA_INPUT_OBJECT ${MANTA_INPUT_OBJECT/originals/500x500_png/}'
mfind /$MANTA_USER/public/getty-open/500x500_png -n 'jpg$' | \
 mjob create -w -m 'convert $MANTA_INPUT_FILE -colorspace RGB -resize 250000@ \
 -colorspace sRGB -quality 80 /var/tmp/out.png && \
 mpipe ${MANTA_INPUT_OBJECT%.*}.png < /var/tmp/out.png'
# remove snaplinks
mfind /$MANTA_USER/public/getty-open/500x500_png -n 'jpg$' | mjob create -w -m 'mrm $MANTA_INPUT_OBJECT'

mfind /$MANTA_USER/public/getty-open/originals | mjob create -w -m 'mln $MANTA_INPUT_OBJECT ${MANTA_INPUT_OBJECT/originals/1000x1000_png/}'
mfind /$MANTA_USER/public/getty-open/1000x1000_png -n 'jpg$' | \
 mjob create -w -m 'convert $MANTA_INPUT_FILE -colorspace RGB -resize 1000000@ \
 -colorspace sRGB -quality 80 /var/tmp/out.png && \
 mpipe ${MANTA_INPUT_OBJECT%.*}.png < /var/tmp/out.png'
mfind /$MANTA_USER/public/getty-open/1000x1000_png -n 'jpg$' | mjob create -w -m 'mrm $MANTA_INPUT_OBJECT'

mfind /$MANTA_USER/public/getty-open/originals | mjob create -w -m 'mln $MANTA_INPUT_OBJECT ${MANTA_INPUT_OBJECT/originals/2000x2000_png/}'
mfind /$MANTA_USER/public/getty-open/2000x2000_png -n 'jpg$' | \
 mjob create -w -m 'convert $MANTA_INPUT_FILE -colorspace RGB -resize 4000000@ \
 -colorspace sRGB  -quality 80 /var/tmp/out.png && \
 mpipe ${MANTA_INPUT_OBJECT%.*}.png < /var/tmp/out.png'
mfind /$MANTA_USER/public/getty-open/2000x2000_png -n 'jpg$' | mjob create -w -m 'mrm $MANTA_INPUT_OBJECT'

