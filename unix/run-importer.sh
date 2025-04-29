#!/bin/bash
current_dir=$PWD

workdir="$current_dir/work-dirs"
tmpdir=$workdir/tmp

checkcommand="ps -p %s"
launch="sh ./startOne.sh	%s %d"

cd "$current_dir/builds/importer-service-bin/release"

mkdir -p $tmpdir
chmod 777 $workdir
chmod 777 $tmpdir

logFile=$workdir/log4j2.xml
if ! [ -f "$logFile" ]; then
        cp ./log4j2.xml "$logFile"
fi

if ! [ -d "$workdir/i18next" ]; then
        mkdir $workdir/i18next
        cp -r ./i18next $workdir
fi

# Initial memory capacity
MEM=3072
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

startServerOpt="-Dinst.dir=\"$current_dir/builds/importer-service-bin/release\" -Djava.start.command=\"/usr/bin/java\""
javaOpt="-Djava.io.tmpdir=$tmpdir -Dinst.dir=$instdir -Dwork.dir=$workdir -Djava.net.preferIPv4Stack=true -Dfile.encoding=UTF-8 -Dlog4j.configurationFile=$logFile"

java \
    -Xmx"$MEM"M \
    $javaOpt \
    -cp "$workdir/..:./:dependency/*:./dependency" \
    -Dcheck.process.pid.command="$checkcommand" \
    -Dlaunch.server.command="$launch" \
    com.tms.pstms.importer.service.ImporterApplication
