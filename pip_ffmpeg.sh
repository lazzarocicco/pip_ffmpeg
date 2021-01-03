#this script takes two arguments: first) video to overlay. Second) the base video.
#Both must be in the current directory and must be in mp4 format. 
#For more info read the reedme file
#eg.  pip_ffmpeg.sh overlay_video.mp4 base_video.mp4

if [ "$#" != "2" ]
then
	echo "You have these videos in your folder."
	echo "Choose the two you want to use"
	echo "by writing the first (that will be overlaid)"
	echo "and the second (that will be below the first)"
	echo " "
	rm list.txt
	rm ordered.txt
	echo "alphabetical order:"
	for file in *mp4
		do
		File_basename=$(basename -s .mp4 $file)
		ffprobe -show_streams -select_streams v $file 2> /dev/null >"PARAMS_"$File_basename".txt"
		echo $file $(cat "PARAMS_"$File_basename".txt" | grep -w nb_frames | cut -d'=' -f2) $(cat "PARAMS_"$File_basename".txt" | grep -w duration | cut -d'=' -f2)
		echo $( cat "PARAMS_"$File_basename".txt" | grep -w nb_frames | cut -d'=' -f2 ) $( cat "PARAMS_"$File_basename".txt" | grep -w duration | cut -d'=' -f2 ) $file >> list.txt
	done
	echo ""
	echo "sorted by length (frames):"
	cat list.txt | sort -g > ordered.txt
	cat ordered.txt
	echo "--"
	echo "maybe you want to use these .."
	echo $(sed '1!d' < ordered.txt | awk '{print $3}') $(sed '2!d' < ordered.txt | awk '{print $3}')
  	exit 1
else

	echo "provided: " $1 $2
	echo $1 "is the overlay video"
	echo $2 "is the base (background) video"
	echo "correct?: yes/no?"
	read -s files_provided
	if [ $files_provided == "yes" ]
		then
			##string for filter_complex
			STRING_0_TOP="[0]null[TOP]"
			STRING_1_BASE="[1]null[BASE]"
			STRING_BASE_TOP_overlay="[BASE][TOP]overlay=0:0"
			STRING_SOUND="amix=inputs=2:duration=longest:dropout_transition=1"
			over_video=$1
			base_video=$2
			over_nb_frame=$(ffprobe -show_streams -select_streams v $over_video 2> /dev/null | grep -w nb_frames | cut -d'=' -f2)
			over_duration=$(ffprobe -show_streams -select_streams v $over_video 2> /dev/null | grep -w duration | cut -d'=' -f2)
			base_nb_frame=$(ffprobe -show_streams -select_streams v $base_video 2> /dev/null | grep -w nb_frames | cut -d'=' -f2)
			base_duration=$(ffprobe -show_streams -select_streams v $base_video 2> /dev/null | grep -w duration | cut -d'=' -f2)
			rest_sec_base_over=$(echo $base_duration - $over_duration | bc)
			echo "Your over_video is" $over_video", your base_video (background) is" $base_video
			echo ""
			echo "the overlay video will be positioned vertically in the center of the base video."
			echo "do you prefer its horizontal position to be in the left, center or right?"
			echo "left (1)/center(2)/right(3)?"
			read -s over_h_geometry
			case $over_h_geometry in
				left | 1)
					echo ""
					echo "in the timeline where do you want to put the video overlay? at the beginning or at the end of the basic video?"
					echo "begin(1)/end(2)"
					echo ""
				STRING_BASE_TOP_overlay="[BASE][TOP]overlay=0:H/2-h/2"
					read time_line
						case $time_line in
							begin | 1)
							itsoffset=0
							STRING_0_TOP="[0]fade=out:$(expr $over_nb_frame - 3):1:alpha=1[TOP]"

						;;
							end | 2)
							itsoffset=$rest_sec_base_over
						;;
						esac
			;;
				center | 2)
					echo ""
					echo "in the timeline where do you want to put the video overlay? at the beginning or at the end of the basic video?"
					echo "begin(1)/end(2)"
					echo ""
				STRING_BASE_TOP_overlay="[BASE][TOP]overlay=W/2-w/2:H/2-h/2"
					read time_line
						case $time_line in
							begin | 1)
							itsoffset=0
							STRING_0_TOP="[0]fade=out:$(expr $over_nb_frame - 3):1:alpha=1[TOP]"
						;;
							end | 2)
							itsoffset=$rest_sec_base_over
						;;
						esac
			;;
				right | 3)
					echo ""
					echo "in the timeline where do you want to put the video overlay? at the beginning or at the end of the basic video?"
					echo "begin(1)/end(2)"
					echo ""
				STRING_BASE_TOP_overlay="[BASE][TOP]overlay=W-w:H/2-h/2"
					read time_line
						case $time_line in
							begin | 1)
							itsoffset=0
							STRING_0_TOP="[0]fade=out:$(expr $over_nb_frame - 3):1:alpha=1[TOP]"
						;;
							end | 2)
							itsoffset=$rest_sec_base_over
						;;
						esac
			;;
			esac
			#filter complex
			filter_complex=$STRING_0_TOP";"$STRING_1_BASE";"$STRING_BASE_TOP_overlay";"$STRING_SOUND
			##ffnpeg command
			ffmpeg -itsoffset $itsoffset -i $over_video -i $base_video -filter_complex $filter_complex -vcodec h264 -acodec aac output.mp4
		else
			echo "goodbye!"
			exit 1
	fi
fi
