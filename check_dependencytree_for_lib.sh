#!/bin/bash
libpattern=$1
slash="/"
clear
if [[ -z "$libpattern" ]]; then
  echo "please provide a lib pattern."
  exit 16
fi
find . -name 'pom.xml' -or -name 'build.gradle*' -type f | sed -r 's|/[^/]+$||' | sort | uniq | grep -v '.terraform' | while IFS= read -r d; do
  STEP_BACK_COUNT=$(awk -F"${slash}" '{print NF-1}' <<<"${d}")
  cd $d

  if [ -n "$(ls | grep -i "pom.xml")" ]; then
    echo "Analysing maven project: $d"
    mvn dependency:tree | grep $libpattern
  else
    if [ -z "$(which gradle)" ]; then
      if [ -n "$(ls | grep -i "gradlew")" ]; then
        echo "Analysing gradle project: $d"
        ./gradlew -q dependencies | grep $libpattern
      else
        echo "Found gradle project but there is no local gradle installation and no wrapper for project: $d"
      fi
    else
      echo "Analysing gradle project: $d"
      gradle -q dependencies | grep $libpattern
    fi
  fi

  for ((n = 0; n < $STEP_BACK_COUNT; n++)); do
    cd ..
  done

done
exit 0
