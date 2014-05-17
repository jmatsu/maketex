# ${MAINFILE_LOCATION}/figures
function get_path_to_figure()
{
	TARGET_LOCATION="./figures"

	if [ -d $1 ]; then
		TARGET_LOCATION="$1"
	elif [ ! -d $TARGET_LOCATION ]; then
		TARGET_LOCATION="."
	fi

	echo $TARGET_LOCATION
}

function find_png_a_pdf()
{
	find $1 \( -name '*.png' -or -name '*.pdf' \) -maxdepth 1
}

function e_x_bound_box()
{
	find_png_a_pdf $1 | xargs extractbb
}

function e_bound_box()
{
	find_png_a_pdf $1 | xargs ebb
}

function gen_eps()
{
	find_png_a_pdf $1 | xargs geneps
}

function move_file()
{
	[ ! -d $1 ] && mkdir -p $1
  	mv -f $2 $1"/"
}

function flow_make_tex()
{
	OUTPUT_DIR=$1
	FILE_NAME_NO_EXTENTION=$2

	FILE_NAME_MAIN="${FILE_NAME_NO_EXTENTION}"
	FILE_NAME_PDF="${FILE_NAME_NO_EXTENTION}.pdf"
	FILE_NAME_DVI="${OUTPUT_DIR}${FILE_NAME_NO_EXTENTION}.dvi"
	FILE_NAME_BBL="${OUTPUT_DIR}${FILE_NAME_NO_EXTENTION}.bbl"

	# first platex for aux
	platex -output-directory $OUTPUT_DIR $FILE_NAME_MAIN

	# generate bbl
	pbibtex "${OUTPUT_DIR}${FILE_NAME_NO_EXTENTION}"

	# bbl
	sed -i -e 's/^\\newblock//g' $FILE_NAME_BBL
	# sed -i -e 's/^\\par//g' $FILE_NAME_BBL

	# refrect bbl to dvi
	platex -output-directory $OUTPUT_DIR $FILE_NAME_MAIN

	# convert dvi to pdf
	dvipdfmx -o $FILE_NAME_PDF $FILE_NAME_DVI

	echo $FILE_NAME_MAIN
	echo $FILE_NAME_PDF
	echo $FILE_NAME_DVI
	echo $FILE_NAME_BBL

	# open pdf with Preview
	open -a Preview $FILE_NAME_PDF
}