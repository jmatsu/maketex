#!/usr/bin/env bash

## function declaration begin

die() {
  echo "$1" 1>&2
  exit 1
}

# ${MAINFILE_LOCATION}/figures
function get_path_to_figure()
{
  local location="./figures"

  if [[ ! $# -eq 0 ]]; then
    if [[ -d $1 ]]; then
      location="$1"
    fi
  fi

  if [[ ! -d "${location}" ]]; then
    location="."
  fi

  echo $location
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
  find_png_a_pdf "$1" | xargs geneps
}

function move_file()
{
  [[ ! -d $1 ]] && mkdir -p "$1"
    mv -f $2 "$1/"
}

function get_tex_opt()
{
  local encode_type=$(nkf --guess "$1")

  case "${encode_type}" in
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

get_bibfile() {
  local texfile="$1"

  grep -o "bibliography{[^}]*}" "$texfile"|sed -e 's/[^{]*{\([^}]*\)}/\1/' || echo
}

is_main_file() {
	if [[ $(head -1 "$1"|tr -d "\t ") = "%maketex:main" ]]; then
    echo "$1"
  fi
}; export -f is_main_file

expand_path() { # use Ruby
  ruby -e 'puts File.expand_path(ARGV[0])' "$1"
}

filename_only() {
  ruby -e 'puts File.basename(ARGV[0], ".tex")' "$1"
}

main() {
  local -r output_dir="${HOME}/.maketex.d"
  local file_location="$(expand_path $1)"

  local -r logfile="${output_dir}/$(date +%s).log"

  {
  set -x
  # pre-condition : The main tex file is only one in the directory.

  if [[ ! -d "$file_location" ]]; then
    file_location="${file_location%/*}"
  fi

  local filepath=$(find "${file_location}" -name "*.tex" -print0|xargs -0 -I{} bash -c "is_main_file {}"|head -1) || die "main file not found."

  gen_eps "${file_location}/figures"

  local filename_wo_suffix="$(filename_only "$filepath")"

  local platex_options=$(get_tex_opt "$filepath")

  cd "${file_location}"

  # first platex for aux
  platex -output-directory "$output_dir" "${filename_wo_suffix}" $platex_options

  local bibfile_wo_suffix=$(get_bibfile "$filepath")

  cp "${bibfile_wo_suffix}.bib" "${output_dir}/"

  cd "$output_dir"

  # generate bbl
  pbibtex "${filename_wo_suffix}"

  # bbl
  sed -i -e 's/^\\newblock//g' "${filename_wo_suffix}.bbl"
  sed -i -e 's/^: //g' "${filename_wo_suffix}.bbl"
  # sed -i -e 's/^\\par//g' $FILE_NAME_BBL

  cp -f "${filename_wo_suffix}.bbl" "${file_location}/"

  cd "$file_location"

  # refrect bbl to dvi
  platex -output-directory "$output_dir" "${filename_wo_suffix}" $platex_options

  # resolve each-refs
  platex -output-directory "$output_dir" "${filename_wo_suffix}" $platex_options

  # convert dvi to pdf
  dvipdfmx -o "./${filename_wo_suffix}.pdf" "${output_dir}/${filename_wo_suffix}.dvi"

  # open pdf with Preview
  open -a Preview "./${filename_wo_suffix}.pdf"

  set +x
  } > "$logfile"
}

## function declaration end

main "$@"
