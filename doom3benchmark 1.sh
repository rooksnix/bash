#!/bin/sh 
set -e # exit on first error 
LOG=~/.doom3/benchmark/doom3-"`date +%F_%H:%M:%S`".log 
mkdir -p ~/.doom3/benchmark 
if [ "x$1" = "xcomplete" ]; then 
  doom3 +set in_tty 0 +timeDemoQuit demo1 usecache > "$LOG" 
  grep -h "frames rendered" "$LOG" 
else 
  doom3 +set in_tty 0 +timeDemoQuit demo1 usecache | grep "frames rendered" > "$LOG" 
  cat "$LOG" 
fi
