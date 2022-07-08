#!/bin/bash
IFS=$'\n'
logo=$(echo `pwd`/logo.png)
if [ $# -ne 0 ];then
	if [ -d $1 ];then
		pushd $1
	else
		echo "Arguement must be directory"
		exit 0
	fi
fi

if [ ! -f $logo ];then
	echo "Default logo not found";
	exit 0
fi

vids=$(echo `pwd`/vids)

if [ ! -d $vids ];then
	mkdir -p $vids
fi

function doStuff(){
	echo "---------: vids is $1";
	mkdir -p $1
	for i in `ls`; do
		if [ "$i" == "vids" ];then continue;fi
		if [ -d $i ]; then
			#vids=$vids/$i
			echo "transerving into $i";
			pushd $i;
				echo "before pop we have $1/$i"
				#sleep 3s;
				doStuff $1/$i  # If its a directory, we have to transverse it
			popd
		fi
		# at this point, we are in the directory and need to convert
		if ! ls | grep .jpg; then	
			#cp $logo .
			echo "";
		fi
		#start converting to mp4
		
		img=`ls | grep .jpg`
		img=`echo $img | awk -F " " '{ print $1 }'`
		img=$logo
		if echo $i | grep -e .mp3 -e .wma ; then
			# lets first check if its beeng converted before
			mp4=`echo $i | awk -F ".mp3" '{ print $1 }'`.mp4
			if ls $i | grep $mp4; then continue;fi
			if echo $i | grep .wma;then
				mp3=`echo $i | awk -F ".wma" '{print $1}'`.mp3
				ffmpeg -i $i  -acodec libmp3lame -ab 192k $mp3
				$i=$mp3
			fi
			ffmpeg -y -loop 1 -framerate 1 -i $img -i "$i" -c:v libx264 -preset veryslow -crf 0 -c:a copy -shortest $1/"$mp4"
			echo -e "\n-----------------------------------NEXT-------------------------------------------\n"
		fi
	done
	#echo "---------: vids is back $1";
}

doStuff $vids
