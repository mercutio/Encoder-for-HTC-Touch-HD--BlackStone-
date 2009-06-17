#!/bin/bash

AUDIO_BITRATE="128"
INPUT_FILE=${1}
OUTPUT_FILE=${2}
TEMP_DIR="/tmp/"
TEMP_FILE2=${TEMP_DIR}${OUTPUT_FILE}"_temp"
TEMP_FILE=${TEMP_FILE2}".avi"
LOG_FILE=${TEMP_DIR}$$".log"
THREADS="1"
NB_PASS=2

# MPLAYER_RETURN=(`mplayer -identify -vo null -ao null -frames 0 ${INPUT_FILE} | grep "(FPS|WIDTH|HEIGHT)"`)
MPLAYER_RETURN=(`mplayer -identify -vo null -ao null -frames 0 ${INPUT_FILE} | grep "ID_VIDEO"`)
#echo $?
#echo ${MPLAYER_RETURN[*]}
for i in ${MPLAYER_RETURN[*]}; do
	declare $i
done

#echo ${ID_VIDEO_FPS}
#echo ${ID_VIDEO_HEIGHT}
#echo ${ID_VIDEO_WIDTH}
#echo ${ID_VIDEO_ASPECT}

if [ ${ID_VIDEO_WIDTH} -lt 800 ]
    then #echo $(( ${ID_VIDEO_WIDTH} / ${ID_VIDEO_HEIGHT} ))
    VIDEO_ASPECT=$(echo "${ID_VIDEO_WIDTH}/${ID_VIDEO_HEIGHT}" | bc -l)
    #echo ${VIDEO_ASPECT}

    VIDEO_BITRATE=${ID_VIDEO_WIDTH}
    SCALE=""
    ASPECT=""
else
    VIDEO_ASPECT=$(echo "${ID_VIDEO_WIDTH}/${ID_VIDEO_HEIGHT}" | bc -l)
    VIDEO_HEIGHT=$(echo "800/${VIDEO_ASPECT}" | bc)


    VIDEO_BITRATE="800"
    SCALE=",scale=800:"${VIDEO_HEIGHT}
    ASPECT="-aspect 800:"${VIDEO_HEIGHT}
fi

#echo ${SCALE}
#echo ${ASPECT}

#pass 1
mencoder ${INPUT_FILE} -passlogfile ${LOG_FILE} -of avi -ofps ${ID_VIDEO_FPS} -srate 44100 -ovc x264 -x264encopts level=30:pass=1:bitrate=${VIDEO_BITRATE}:vbv-maxrate=1000:vbv-bufsize=2000:subme=0:analyse=0:partitions=none:ref=1:turbo=2:me=dia:bframes=0:threads=${THREADS}:no-cabac -vf pullup,softskip,harddup -oac faac -channels 2 -faacopts mpeg=4:object=2:br=${AUDIO_BITRATE} -af volnorm -o ${TEMP_FILE} #-ss 0 -endpos 70

# echo $?
if [ $? -eq 0 ]; then
    

#     if [ ${NB_PASS} -gt 2 ]; then
# 	NB_PASS=$(echo "${NB_PASS}-1" | bc)
# 	for i in ${NB_PASS}; do
# 	    if [ $i -eq ${NB_PASS} ]; then
# 		
# 	    fi
# 	done
#     fi

    #pass 2
    mencoder ${INPUT_FILE} -passlogfile ${LOG_FILE} -of avi -ofps ${ID_VIDEO_FPS} -srate 44100 -ovc x264 -x264encopts level=30:pass=2:bitrate=${VIDEO_BITRATE}:vbv-maxrate=1000:vbv-bufsize=2000:subme=6:analyse=0:partitions=none:ref=1:bframes=0:threads=${THREADS}:no-cabac -vf pullup,softskip${SCALE},harddup -oac faac -channels 2 -faacopts mpeg=4:object=2:br=${AUDIO_BITRATE} -af volnorm -o ${TEMP_FILE} ${ASPECT} #-ss 0 -endpos 70

    # echo $?
    if [ $? -eq 0 ]; then 
    MP4Box -fps ${ID_VIDEO_FPS} -aviraw video ${TEMP_FILE}
    # echo $?
    
    MP4Box -fps ${ID_VIDEO_FPS} -aviraw audio ${TEMP_FILE}
    # echo $?
    
    mv ${TEMP_FILE2}_audio.raw ${TEMP_FILE2}_audio.aac
    # echo $?
    
    MP4Box -fps ${ID_VIDEO_FPS} -add ${TEMP_FILE2}_video.h264 -add ${TEMP_FILE2}_audio.aac ${OUTPUT_FILE}
    # echo $?
    fi
fi 
rm ${TEMP_FILE2}_audio.aac ${TEMP_FILE2}_video.h264 ${TEMP_FILE} ${LOG_FILE}
# echo $?
