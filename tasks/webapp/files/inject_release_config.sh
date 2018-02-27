#!/bin/bash

if [[ "$#" -lt 2 ]]; then
  echo "Usage: inject_release_config.sh build.env path/to/build/"
  exit 0
fi

release_dir=$2
build_env=$1

find_cmd="find $release_dir -type f ( -name *.html -o -name *.js )"
files=`$find_cmd`

replace_cmd="sed -i" # note: this invocation of `sed -i` will NOT work on Mac OS, which requires an explicit zero-length parameter for -i (sed -i '')
while read -r line
do
  var=`echo $line | cut -d '=' -f 1 | xargs`
  value=`echo $line | cut -d '=' -f 2 | xargs`

  occurences=`echo $files | xargs cat | grep -o "%$var%" | wc -l | xargs`
  echo "Substituting: [%$var%] -> [$value] ($occurences occurences in build)"
  replace_cmd="$replace_cmd -e s|%$var%|$value|g"
done < $build_env

echo "Executing: $find_cmd -exec $replace_cmd {} ;"

$find_cmd -exec $replace_cmd {} \;
