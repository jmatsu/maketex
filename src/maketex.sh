#!/usr/bin/env bash

## function declaration begin

# ${MAINFILE_LOCATION}/figures
function get_path_to_figure()
{
  TARGET_LOCATION="./figures"

  if [ ! $# -eq 0 ]; then
    if [ -d $1 ]; then
      TARGET_LOCATION="$1"
    fi
  fi

  if [ ! -d $TARGET_LOCATION ]; then
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

function get_tex_opt()
{
  ENCODE_OF_FILE=$(nkf --guess $1)

  case $ENCODE_OF_FILE in
    /shift.jis*/i) # Shift_JIS, Shift-jis
      echo "-kanji=sjis"
      ;;
    /utf-8*/i) # utf-8
      echo "-kanji=utf8"
      ;;
    /euc-jp*/i | /japanese-iso-8bit*/i) # euc
      echo "-kanji=euc"
      ;;
    /iso-2022-jp*/i) # jis
      echo "-kanji=jis"
      ;;
    *) # no opt
      echo ""
      ;;
  esac
}

function flow_make_tex()
{
  OUTPUT_DIR=$1
  FILE_NAME_NO_EXTENSION=$2
  FILE_LOCATION=$3

  FILE_NAME_MAIN="${FILE_LOCATION}${FILE_NAME_NO_EXTENSION}"
  FILE_NAME_PDF="${FILE_LOCATION}${FILE_NAME_NO_EXTENSION}.pdf"
  FILE_NAME_DVI="${OUTPUT_DIR}${FILE_NAME_NO_EXTENSION}.dvi"
  FILE_NAME_BBL="${OUTPUT_DIR}${FILE_NAME_NO_EXTENSION}.bbl"

  PLATEX_OPT=$(get_tex_opt "${FILE_NAME_MAIN}.tex")

  # first platex for aux
  platex -output-directory $OUTPUT_DIR $FILE_NAME_MAIN $PLATEX_OPT

  # generate bbl
  pbibtex "${OUTPUT_DIR}${FILE_NAME_NO_EXTENSION}"

  # bbl
  sed -i -e 's/^\\newblock//g' $FILE_NAME_BBL
  sed -i -e 's/^: //g' $FILE_NAME_BBL
  # sed -i -e 's/^\\par//g' $FILE_NAME_BBL

  # copy bbl to main tex's location.
  cp -a $FILE_NAME_BBL $FILE_LOCATION

  # refrect bbl to dvi
  platex -output-directory $OUTPUT_DIR $FILE_NAME_MAIN $PLATEX_OPT

  # convert dvi to pdf
  dvipdfmx -o $FILE_NAME_PDF $FILE_NAME_DVI

  # open pdf with Preview
  open -a Preview $FILE_NAME_PDF
}

## function declaration end

## main flow begin

# considering dropbox sync
OUTPUT_DIR="${HOME}/.maketex.d/"

# name of main TeX file.
if [ $# -eq 0 ]; then
    FILE_NAME_TEX="main.tex"
    FILE_LOCATION="$CURRENT_LOCATION"
else
  FILE_NAME_TEX="$1"
    FILE_NAME_TEX2="./${FILE_NAME_TEX}"
    FILE_LOCATION="${FILE_NAME_TEX%/*}/"
    FILE_NAME_TEX="${FILE_NAME_TEX##*/}"
    if [ "${FILE_NAME_TEX}/" = ${FILE_LOCATION} ]; then
      FILE_LOCATION="${FILE_NAME_TEX2%/*}/"
      FILE_NAME_TEX="${FILE_NAME_TEX2##*/}"
  fi
fi

# remove EXTENSION
case $FILE_NAME_TEX in
  *\.tex)
    FILE_NAME_NO_EXTENSION=$(echo "${FILE_NAME_TEX}" | sed -e 's/\.tex//')
    echo $FILE_NAME_NO_EXTENSION
    ;;
  *)
    FILE_NAME_NO_EXTENSION=$FILE_NAME_TEX
    ;;
esac

# make output dir
if [ ! -d $OUTPUT_DIR ]; then
  mkdir -p $OUTPUT_DIR
fi

# png or pdf to eps.
gen_eps "${FILE_LOCATION}figures"

# main flow
flow_make_tex $OUTPUT_DIR $FILE_NAME_NO_EXTENSION $FILE_LOCATION
