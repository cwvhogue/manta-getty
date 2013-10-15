#!/bin/bash
# CWV Hogue, Joyent Inc.

# NOTE: this assumes the Manta directory of originals does not have subdirectories
#       

if [ $# != 2 ]
then
        echo "Usage:"
	echo " "
	echo "`basename $0` [1 for JPEG, 2 for WEBP, 3 for XMP] [1, 2 or 3 iterations / resolution sets]"
	echo " "
	echo "e.g:	`basename $0` 1  1  <- creates JPEG resized image set at small resolution"
	echo "   	`basename $0` 1  2  <- creates JPEG resized image set at small + med resolutions"
	echo "   	`basename $0` 1  3  <- creates JPEG resized image set at all 3 resolutions"
	echo "  	`basename $0` 3  1  <- creates XMP metadata files from image set"
	echo " " 
	echo "To change default resolutions, directories, mjob parameters: edit this script"
	echo " "
        exit 1
fi


# #############################################################################################



MJOB_ARGS="-w -m"

# Above - If you need to change the mjob command line parameters during the call to convert
# e.g. MJOB_ARGS="--memory 2048 --disk 128 -w -m"


USER_PATH="public"
#USER_PATH="public/images/getty-open"

# Above is the base directory after $MANTA_USER for the image originals and the target directories

USER_ORIGINALS="art"
#USER_ORIGINALS="originals"

# Above is the subdirectory following USER_PATH where the originals are located


# The following defines encapsulate the ImageMagick convert arguments.
# The code loops over three different size arguments in SIZE_ARG_ITN_*
# These are set to 0.25 1 and 4 megapixels but can be changed
# e.g. 
# convert foo.jpg -colorspace RGB -resize 250000@ -colorspace sRGB -quality 80 /var/tmp/out.jpg
# is held in parameters:  
# CONV_STR SIZE_ARG_ITN_1 JPEG_ARG


CONV_STR="convert \$MANTA_INPUT_FILE -colorspace RGB -resize"
# Above is the start of the convert command - after this comes the size argument as in SIZE_ARG_ITN_*

# Small
SIZE_ARG_ITN_3="250000@"
SIZE_SUBDIR_3="500x500"

# Medium
SIZE_ARG_ITN_2="1000000@"
SIZE_SUBDIR_2="1000x1000"

# Large
SIZE_ARG_ITN_1="4000000@"
SIZE_SUBDIR_1="2000x2000"
# Above are the three iteration sizes SIZE_ARG_ITN_*  and the target directory names SIZE_SUBDIR_*



JPEG_ARG="-colorspace sRGB -quality 80 /var/tmp/out.jpg"
WEBP_ARG="-colorspace sRGB -quality 50 -define webp:lossless=true /var/tmp/out.webp"
# Above are the arguments for JPG and WebP conversion. 
# Note that without proper library support for WebP the resulting files
# Will simply be JPEG formatted files with a .webp extension!

XMP_CONV_STR="convert \$MANTA_INPUT_FILE"
XMP_ARG=" /var/tmp/out.xmp"
# Above are the beginning and ending arguments for the XMP extracted metadata


# #####################################################################################


if [ $1 -gt 3 ]
then 
	echo argument 1 too large
	exit 1
fi

if [ $2 -gt 2 ]
then
	echo argument 2 too large
	exit 2
fi

if [ $2 -lt 0 ]
then
	$2=0
fi


let NUMCYC=3-$2

if [ $1 == 1 ]
then
	IMG_EXT="jpg"
	IMG_ARG=$JPEG_ARG
fi
if [ $1 == 2 ]
then
	IMG_EXT="webp"
	IMG_ARG=$WEBP_ARG
fi
if [ $1 == 3 ]
then
	CONV_STR=${XMP_CONV_STR}
	IMG_EXT="xmp"
	IMG_ARG=$XMP_ARG
	NUMCYC=2
fi

# The XMP specific block above skips iterations 1 and 2, and sets the convert strings as needed




PDIR_STR="/var/tmp/out."
PDIR_STR=${PDIR_STR}${IMG_EXT}

# Capture the list of original images for xargs use in each call to mjob:
echo Preparing list of *.jpg originals...
mjob create -w -r "mfind /$MANTA_USER/$USER_PATH/$USER_ORIGINALS -n 'jpg$' > /var/tmp/out.txt && \
mput -f /var/tmp/out.txt /$MANTA_USER/$USER_PATH/$USER_ORIGINALS/input_list.txt" < /dev/null



while [ $NUMCYC != 3 ]
do
	let NUMCYC=$NUMCYC+1
	if [[ $NUMCYC == 1 ]]
	then
		MP_SIZE=$SIZE_SUBDIR_1
		SIZE_ARG=$SIZE_ARG_ITN_1
	fi
	if [[ $NUMCYC == 2 ]]
	then
		MP_SIZE=$SIZE_SUBDIR_2
		SIZE_ARG=$SIZE_ARG_ITN_2
	fi
	if [[ $NUMCYC == 3 ]]
	then
		MP_SIZE=$SIZE_SUBDIR_3
		SIZE_ARG=$SIZE_ARG_ITN_3
		if [[ $1 == 3 ]]
		then
			MP_SIZE="metadata"
			SIZE_ARG=
		fi
	fi
	echo
	echo ++++++++++++++++++++++++++++++++++++++++
	echo Converting Images to ${IMG_EXT} format at $MP_SIZE 
	date
	echo
	echo Checking Manta Target Directory Exists ...
	mls /${MANTA_USER}/${USER_PATH}/${MP_SIZE}_${IMG_EXT} > /dev/null
	RETVAL=$?
	if [[ $RETVAL == 0 ]]
	then
		echo Target Manta directory exists. 
		echo Removing previous images...
		mfind /${MANTA_USER}/${USER_PATH}/${MP_SIZE}_${IMG_EXT} -n '${IMG_EXT}$' | \
		mjob create -w -m 'mrm $MANTA_INPUT_OBJECT'
	else
		echo Making Target Manta directory...
		mmkdir /${MANTA_USER}/${USER_PATH}/${MP_SIZE}_${IMG_EXT}
	fi

	echo Image Conversion with ImageMagick convert to ${IMG_EXT}...

# I construct the call to ImageMagick convert in steps 
	CONVERT_JOB="${CONV_STR} ${SIZE_ARG} ${IMG_ARG}"
	echo mjob created is: "${CONVERT_JOB}"
	MPIPE_STR="mpipe /${MANTA_USER}/${USER_PATH}/${MP_SIZE}_${IMG_EXT}/\$(basename \${MANTA_INPUT_OBJECT%.*}).${IMG_EXT}" 
	echo mpipe call is: ${MPIPE_STR}...
# This uses the saved list of originals sitting on Manta as input without round-tripping back to the local machine.
	echo /${MANTA_USER}/${USER_PATH}/${USER_ORIGINALS}/input_list.txt | \
	mjob create ${MJOB_ARGS} "xargs mcat" -m "${CONVERT_JOB} && ${MPIPE_STR} < ${PDIR_STR}"
	date
	echo "Summary: "
	echo `mls /${MANTA_USER}/${USER_PATH}/${MP_SIZE}_${IMG_EXT} | wc -l` out of `mls /${MANTA_USER}/${USER_PATH}/${USER_ORIGINALS} | wc -l` files converted.
done

# Remove the input list:
mrm /${MANTA_USER}/${USER_PATH}/${USER_ORIGINALS}/input_list.txt

date
echo Done.
