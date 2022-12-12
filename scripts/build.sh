#!/usr/bin/env bash

set -e

mkdir -p output
rm -rf output/*

BASE_DIR=$(pwd)
CONTENT_DIR="$BASE_DIR/content"
OUTPUT_DIR="$BASE_DIR/output"

BASE_TEMPLATE=$(cat $BASE_DIR/templates/main.html)

echo "Generating posts index …"
INDEX=""
# compile list of posts and make an index
for FILE in $(find $CONTENT_DIR/posts/*.html -type f | sort -r); do
	# reset the variables to blank
	# so we don't accidentally leak env variables
	TITLE=""
	DESCRIPTION=""
  source "html.env" # main env file with site-wide variables, refresh for every file
	PREVIEW_IMAGE=$SITE_PREVIEW_IMAGE

  FILE=${FILE/${CONTENT_DIR}/""}
	ENV_FILE="$CONTENT_DIR$FILE.env"
	if [ -f "$ENV_FILE" ]; then
		# load the .env file for this page if it exists
		source $ENV_FILE
	fi

	INDEX="$INDEX<article><a href="$FILE"><h3>$TITLE</h3><p><img src="$PREVIEW_IMAGE" /></p><p>$DESCRIPTION</p></a></article>"
	echo $FILE
echo $PREVIEW_IMAGE
done

echo ""
echo "Generating output files …"
# process each file in CONTENT_DIR and produce files in OUTPUT_DIR
for FILE in $(find $CONTENT_DIR -type f); do
	# reset the variables to blank
	# so we don't accidentally leak env variables
	TITLE=""
	PREVIEW=""
	DESCRIPTION=""
	source "html.env" # main env file with site-wide variables, refresh for every file
	PREVIEW_IMAGE=$SITE_PREVIEW_IMAGE

	FILE=${FILE/${CONTENT_DIR}/""}
	FILE_DIR=$(dirname $FILE)
	mkdir -p $OUTPUT_DIR$FILE_DIR

	if [[ $FILE == *.html ]]; then
		# html file, apply templates
		ENV_FILE="$CONTENT_DIR$FILE.env"
		if [ -f "$ENV_FILE" ]; then
			# load the .env file for this page if it exists
		  source $ENV_FILE
		fi

		CONTENT=$(cat $CONTENT_DIR$FILE)
		CONTENT=${BASE_TEMPLATE/"@MAIN@"/${CONTENT}}
		CONTENT=${CONTENT/"@POSTS_INDEX@"/${INDEX}}

		REPLACEMENTS=("SITE_NAME" "SITE_URL" "TITLE" "PREVIEW_IMAGE" "DESCRIPTION")
		for R in "${REPLACEMENTS[@]}"
		do
			FIND="@$R@"
			REPLACE=${!R} # read the variable named by the content of $R
			# echo "$FIND -> $REPLACE"
			CONTENT=${CONTENT//"${FIND}"/"${REPLACE}"}
		done

		echo "$CONTENT" > $OUTPUT_DIR$FILE
	else
		if [[ $FILE == *.html.env || $FILE == *.DS_Store ]]; then
			# skip any htmlenv files
			# echo "skip"
			continue
		fi
		# other file type: just copy
		cp $CONTENT_DIR$FILE $OUTPUT_DIR$FILE
	fi
	echo $FILE
done

DATE=$(date)

echo DATE > "$OUTPUT_DIR/last-build.txt"

echo "Done. $DATE"