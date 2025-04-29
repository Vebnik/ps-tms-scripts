#!/bin/bash
current_dir=$PWD

workdir="$current_dir/work-dirs/ps-tms-server"
tmpdir=$workdir/tmp

cd "$current_dir/builds/ps-tms-server-bin/release"

mkdir -p $tmpdir
chmod 777 $workdir
chmod 777 $tmpdir

if ! [ -f "$workdir/tmp" ]; then
        mkdir -p $workdir/tmp
        chmod 777 $workdir
fi

logFile=$workdir/log4j2.xml
if ! [ -f "$logFile" ]; then
        cp ./log4j2.xml "$logFile"
fi

appcp="$workdir/ps-tms-scheme.jar:./:./*:./dependency/*:./dependency"
filePid="$workdir/application.pid"

proplocationOpt="--spring.config.location=$workdir/application.properties"

javaOpt="-cp $appcp -Djava.io.tmpdir=$workdir/tmp -Dwork.dir=$workdir -DfilePid=$filePid -Dlog4j.configurationFile=$logFile -Dfile.encoding=UTF-8"

java \
    -Xmx1024M \
    $javaOpt \
    com.tms.pstms.launch.Application \
    $proplocationOpt