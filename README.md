# pip_ffmpeg
utility script that simplifies the configuration of parameters to get a "picture in picture" with ffmpeg.

[ffmpeg](https://ffmpeg.org/) is open source software.

This script works with a small video to overlay and a larger video. It is also assumed that the larger video also has a longer duration than the overlay video. The overlay video may start immediately or its end may match the end of the longer video.
It can be placed on the left, in the center or on the right.

NB Only videos in mp4 format can be used.

The scirpt is interactive: open a terminal in the folder containing the videos and type:
pip_ffmpeg.sh followed by the two videos you want to use eg.

>pip_ffmpeg.sh small_video.mp4 large_video.mp4

Answer the questions and the script creates the ffmpeg command line for you.
The script itself will launch the ffmpeg command.
At the end of the process in the folder you will find the output.mp4 file.

The process can take a long time, it depends on the length of the videos and the power of your computer

If you just type (without arguments)

>pip_ffmpeg.sh

you get some useful information about the mp4 videos in the working directory ( those info also are saved in the following text files: list.txt ordered.txt PARAMS_name_single_file.txt )

p.s. remember to make the script executable
