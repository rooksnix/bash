#!/bin/bash
cd /home/mrooks/tmp2
for file in `ls wf*`; do
echo "moving file $file @ 'date'" |tee /tmp/logfile
mv "$file" /home/mrooks/tmp2/tmp3/"$file"
echo "File $file @ 'date' moved" | tee /tmp/logfile
sleep 6
done
