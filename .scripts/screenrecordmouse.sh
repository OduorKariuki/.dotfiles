#!/bin/bash
LOCKDIR=/Users/foaxylabs/.local/share/screenrecord
LOCKFILE=/Users/foaxylabs/.local/share/screenrecord/record.lock
DIR=/Users/foaxylabs/Movies/Screencast

mkdir -p $LOCKDIR/log

if test -f "$LOCKFILE"; then
  kill -SIGINT $(head -n 1 $LOCKFILE)
  rm $LOCKFILE
  echo "Killed screenrecord"
else
  DATE=$(date "+%FT%H-%M-%S")
  /Users/foaxylabs/.nix-profile/bin/ffmpeg -framerate 60 -f avfoundation -capture_cursor 1 -i "1:none" -vf "format=uyvy422,eq=gamma=1.05" -video_size 3840x2160 -r 60 -c:v h264_videotoolbox -crf 0 -preset ultrafast -color_range 2 "/Users/foaxylabs/Movies/Screencast/$DATE.mkv" >>$LOCKDIR/log/$DATE 2>&1 &
  PID=$!

  echo $PID >$LOCKFILE
  echo $DATE >>$LOCKFILE

  echo "Running screenrecord"
fi
