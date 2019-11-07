#!/usr/bin/env bash

__snip__remove_snip_lines() {
  local source_file
  source_file="${1:?Missing source file as param}"
  sed "/snip(/d" "$source_file"
}


__snip__get_setting() {
  local repo=https://github.com/whoan/snip
  local setting_key
  setting_key=${1:?You need to specify a setting}

  local config_file=~/.config/snip/settings.ini
  if [ ! -f "$config_file" ]; then
    mkdir -p "${config_file%/*}" && touch "$config_file"
  fi

  local setting_value
  setting_value=$(grep -Po "(?<=^$setting_key=).+" "$config_file")
  if [ -z "$setting_value" ]; then
    echo "You need to set '$setting_key' in $config_file . More info: $repo" >&2
    return 1
  fi

  echo "$setting_value"
}


__snip__get_snippet_fq_name() {
  local snippet
  snippet="${1:?Missing snippet as param}"

  # snippet is already fully qualified, nothing else to do
  if [[ $snippet =~ ^http ]]; then
    echo fully >&2
    echo "$snippet"
    return 0
  fi

  local base_url
  base_url=$(__snip__get_setting base_url) || return 1
  echo "${base_url%/}/$snippet"
}


__snip__replace_snips() {
  local source_file
  local force
  source_file="${1:?Missing source file as param}"
  force=$2

  mapfile -t snippets < <(grep -Po '(^|(?<=[^[:alnum:]]))(?<=snip\(")[^"]+' "$source_file")
  if (( ${#snippets[@]} == 0 )); then
    echo $source_file
    return
  fi

  local filename=${source_file##*/}
  local root_filename="${filename%.*}"
  local extension="${filename#"$root_filename"}"
  local prefix_tmp
  prefix_tmp=$(command -p mktemp) || return 1
  local i=0

  local cache_dir=~/.cache/snip
  mkdir -p "$cache_dir"/

  local fq_snippet
  for snippet in "${snippets[@]}"; do
    fq_snippet=$(__snip__get_snippet_fq_name "$snippet") || return 1
    sniphash=$(echo -ne $snippet|md5sum|cut -d' ' -f1)
    new_file=$prefix_tmp-$((++i))-$filename

    if [[ $force == 1 || ! -f "$cache_dir"/${sniphash} ]]; then
      echo "Downloading snippet: $fq_snippet" >&2
      curl --silent "$fq_snippet" -o "$cache_dir"/${sniphash}
      if [[ $(cut -f1 -d: "$cache_dir/${sniphash}") == 404 ]]; then
        echo "Error downloading snippet: $fq_snippet" >&2
        return 1
      fi
    fi

    sed -r "\@$snippet@r"<( cat "$cache_dir"/${sniphash} ) "$source_file" > "$new_file" || return 1
    source_file="$new_file"
  done

  local output_file=${prefix_tmp}${extension}
  rm "$prefix_tmp"
  __snip__remove_snip_lines "$source_file" > "$output_file"
  rm "$prefix_tmp"-*

  echo "$output_file"
}

__snip__is_regular_file() {
  local filename
  filename=${1:?Missing filename by param}
  [ -f "$filename" ]
}


__snip__is_text_file() {
  local filename
  filename=${1:?Missing filename by param}
  __snip__is_regular_file "$filename" && [[ $(file -i -- "$filename" 2> /dev/null) =~ text/ ]]
}


__snip__can_run() {

  if (( ${#@} == 0 )) || [[ $1 == '-h' ]] || [[ $1 == '--help' ]]; then
    cat >&2 <<EOF
Usage: snip [options] <arguments...>
Options:
  -h, --help    This help
  -f, --force   Force to download content from url bypassing (and updating) cache

Example:
  snip gcc source_file_with_snips.c  # more examples: https://github.com/whoan/snip/blob/master/readme.md
EOF
    return 1
  fi

  if ! which curl > /dev/null 2>&1; then
    echo "You need 'curl' to run this script" >&2
    return 1
  fi
}


snip() {
  __snip__can_run "$@" || return 1

  local force
  if [[ $1 == '-f' || $1 == '--force' ]]; then
    force=1
    shift
  fi

  declare -a params=( "$@" )
  local i

  for (( i=0; i < ${#params[@]}; ++i )); do
    # only valid files are processed
    param="${params[$i]}"
    if __snip__is_text_file "$param"; then
      params[$i]=$(__snip__replace_snips "$param" $force) || return 1
    fi
  done

  echo "Running: ${params[*]}" >&2
  "${params[@]}"
}
