#!/usr/bin/env bash
mmkdir /$MANTA_USER/public/getty-open/originals
mfind /$MANTA_USER/public/art | mjob create -w -m 'cp $MANTA_INPUT_FILE /var/tmp/out.jpg && mpipe ${MANTA_INPUT_OBJECT/art/getty-open\/originals/} < /var/tmp/out.jpg'
