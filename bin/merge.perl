#!/usr/bin/env perl

print "ffmpeg -i video.mp4 -i audio.wav \
-c:v copy -c:a aac -strict experimental \
-map 0:v:0 -map 1:a:0 output.mp4";
