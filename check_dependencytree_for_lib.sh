#!/bin/bash
libpattern=$1
rootdir=$2
slash="/"
clear
if [[ -z "$libpattern" ]];
then
    echo "please provide a lib pattern."
    exit 16
fi
if [[ -z "$rootdir" ]];
then
    rootdir="./"
fi
cd $rootdir
find . -type f -name 'pom.xml' | sed -r 's|/[^/]+$||' |sort |uniq | grep -v '.terraform' | while IFS= read -r d; do
	echo "mvn dependency:tree for $d"
	STEP_BACK_COUNT=$(awk -F"${slash}" '{print NF-1}' <<< "${d}")
	cd $d
	mvn dependency:tree | grep $libpattern
	for ((n=0;n<$STEP_BACK_COUNT;n++))
	do
		cd ..
	done
done
exit 0