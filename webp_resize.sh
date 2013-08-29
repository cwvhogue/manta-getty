#!/usr/bin/env bash
mmkdir /$MANTA_USER/public/getty-open/500x500_webp
mmkdir /$MANTA_USER/public/getty-open/1000x1000_webp
mmkdir /$MANTA_USER/public/getty-open/2000x2000_webp

mfind /$MANTA_USER/public/getty-open/originals | mjob create -w -m 'mln $MANTA_INPUT_OBJECT ${MANTA_INPUT_OBJECT/originals/500x500_webp/}'
mfind /$MANTA_USER/public/getty-open/500x500_webp -n 'jpg$' | \
 mjob create -w -m 'convert $MANTA_INPUT_FILE -colorspace RGB -resize 250000@ \
 -colorspace sRGB -quality 80 -define webp:lossless=true /var/tmp/out.webp && \
 mpipe ${MANTA_INPUT_OBJECT%.*}.webp < /var/tmp/out.webp'
mfind /$MANTA_USER/public/getty-open/500x500_webp -n 'jpg$' | mjob create -w -m 'mrm $MANTA_INPUT_OBJECT'

mfind /$MANTA_USER/public/getty-open/originals | mjob create -w -m 'mln $MANTA_INPUT_OBJECT ${MANTA_INPUT_OBJECT/originals/1000x1000_webp/}'
mfind /$MANTA_USER/public/getty-open/1000x1000_webp -n 'jpg$' | \
 mjob create -w -m 'convert $MANTA_INPUT_FILE -colorspace RGB -resize 1000000@ \
 -colorspace sRGB -quality 80 -define webp:lossless=true /var/tmp/out.webp && \
  mpipe ${MANTA_INPUT_OBJECT%.*}.webp < /var/tmp/out.webp'
mfind /$MANTA_USER/public/getty-open/1000x1000_webp -n 'jpg$' | mjob create -w -m 'mrm $MANTA_INPUT_OBJECT'

mfind /$MANTA_USER/public/getty-open/originals | mjob create -w -m 'mln $MANTA_INPUT_OBJECT ${MANTA_INPUT_OBJECT/originals/2000x2000_webp/}'
mfind /$MANTA_USER/public/getty-open/2000x2000_webp -n 'jpg$' | \
 mjob create -w -m 'convert $MANTA_INPUT_FILE -colorspace RGB -resize 4000000@ \ 
 -colorspace sRGB -quality 80 -define webp:lossless=true /var/tmp/out.webp && \
  mpipe ${MANTA_INPUT_OBJECT%.*}.webp < /var/tmp/out.webp'
mfind /$MANTA_USER/public/getty-open/2000x2000_webp -n 'jpg$' | mjob create -w -m 'mrm $MANTA_INPUT_OBJECT'
