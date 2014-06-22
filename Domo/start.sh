#!/bin/sh
nohup plackup -E production -s Starman --workers=10 -p 5001 -a bin/app.pl &
