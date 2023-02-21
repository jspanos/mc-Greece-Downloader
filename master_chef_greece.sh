#!/bin/bash

if [ -f "masterchef.txt" ]; then
  touch masterchef.txt
fi

for s in `curl -s https://www.star.gr/tv/psychagogia/masterchef|grep masterchef-|grep link--full`; do 
  if [[ $s =~ "href" ]]; then
    URL=`echo $s|awk -F'"' '{print "https://www.star.gr"$2}'`
    url_name=`echo $URL|awk -F"/" '{print $NF}'`
    [[ "$url_name" =~ ^masterchef-.*  ]] && continue
    episode=`echo $URL|awk -F'-' '{print $NF}'`
    full_name=`curl -s $URL|grep "show__title" -A6|grep h2|awk -F'[><]' '{print $3}'`
    filename="masterchef-$full_name.mp4"
    if grep "$filename" masterchef.txt > /dev/null; then
      continue
    fi
    echo $filename
    manifest=`curl -s "$URL"|grep contentUrl|awk -F'"' '{print $4}'`
    m3u8=`curl -s $manifest|grep "1280x720" -A1|tail -n 1`
    ffmpeg -y -i $m3u8 -c copy "$filename"
    echo $filename >> masterchef.txt
  fi
done
