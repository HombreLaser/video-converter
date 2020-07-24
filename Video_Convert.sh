#!/bin/bash
#Script para convertir vídeos a códec x264 con perfil high 4.1,
#sonido dolby digital e incluir subtítulos al vídeo.

#Veremos si el parámetro introducido es un directorio
#y existe.
IFS=$OLDIFS
IFS=$'\n'

if ! [ -e $1 ] && [ -d $1 ]
then
    echo "El directorio introducido no existe o no es válido"
    echo 'uso: bash Video_Convert.sh "dir" track del audio track del subtítulo # de canales de audio'
    exit
fi

$filename #Usada para guardar el nombre del archivo sin su extensión
dir=$1 #Para poder trabajar más cómodamente, asignaremos el valor del
       #parámetro a una variable con un nombre más digerible.
cd $dir
if ! mkdir Copias 
then
    echo "Ya existe un directorio copias. Respaldelo y borrelo y vuelva a correr el script"
    exit
fi

for current_file in *.mkv; do #Procesaremos los archivos del directorio
    filename=$(basename $current_file .mkv)
    #Extracción
    mkvextract tracks "$current_file" 0:Copias/video.mkv $2:Copias/audio.flac $3:Copias/subs.ssa
    echo "\nCompletada extracción"
    #Conversión de audio
    ffmpeg -i Copias/audio.flac -s:a 48k -ab 640k -acodec ac3 -ac $4 Copias/audio.ac3
    #Conversión de vídeo
    ffmpeg -i Copias/video.mkv -c:v libx264 -profile:v high -level:v 4.1 -vf "format=yuv420p, subtitles=Copias/subs.ssa" -crf 16 -c:a copy Copias/out.mkv
    #Unión
    mkvmerge -q -o Copias/$current_file Copias/out.mkv Copias/audio.ac3
    #Limpieza
    rm Copias/out.mkv Copias/video.mkv Copias/audio.flac Copias/subs.ssa Copias/audio.ac3
done

IFS=$OLDIFS
exit
