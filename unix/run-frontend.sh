#!/bin/bash
current_dir=$PWD

echo $current_dir

instdir="$current_dir/work-dirs"
workdir="$current_dir/work-dirs"
serverworkdir="$current_dir/work-dirs"
license="$current_dir/license.lic"
tmpdir=$workdir/tmp

cp "$license" "$current_dir/builds/ps-front-end-server-bin/license.lic"

cd "$current_dir/builds/ps-front-end-server-bin/release"

mkdir -p $tmpdir
chmod 777 $workdir
chmod 777 $tmpdir

ldif=$workdir/test-server.ldif
if ! [ -f "$ldif" ]; then
        cp ./test-server.ldif "$ldif"
fi

logFile=$workdir/log4j2.xml
if ! [ -f "$logFile" ]; then
        cp ./log4j2.xml "$logFile"
fi

if ! [ -d "$serverworkdir" ]; then
		mkdir $serverworkdir
		cp ../license.lic $serverworkdir/license.lic
fi

if ! [ -d "$workdir/i18next" ]; then
        mkdir $workdir/i18next
        cp -r ./i18next $workdir
fi

# Initial memory capacity
MEM=512
# Maximum memory count
MAX=5120

# Reading file memory.limit
CFG=$(cat "$workdir/memory.limit")

# Regexp to match integer
re='^[0-9]+$'
# Check Regexp
if [[ $CFG =~ $re ]] ; then
    # Check max bound
    if [[ $CFG -le $MAX ]] ; then
        MEM=$CFG
    fi
fi

javaOpt="-Djava.io.tmpdir=$tmpdir -Dinst.dir=$instdir -Dwork.dir=$workdir -Djava.net.preferIPv4Stack=true -Dfile.encoding=UTF-8 -Dlog4j.configurationFile=$logFile"
java -Xmx"$MEM"M -cp ".:dependency/*:./dependency" $javaOpt com.tms.pstms.frontend.launch.Application
