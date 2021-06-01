#!/bin/sh

PRO_DIR=`dirname $0`;
PRO_DIR=`cd $PRO_DIR/;pwd`;
TIME_SUFFIX=`date +%Y%m%d%H`;
PWD_PATH=`pwd | awk -F/ '{print $NF}'`

echo $PRO_DIR

case $1 in
	start)
		pid=`cat ./pid`
		process=`ps -ef | grep "$PWD_PATH/tank-cross-2.0.jar" | grep -v "grep" | wc -l`;
		if [ "$process" -eq 1 ]; then
			echo -e "\033[32;31;1;2m game cross server already started!! \033[m";
		else
			nohup java -XX:MaxPermSize=256m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xms2048m -Xmx4096m  -jar $PRO_DIR/tank-cross-2.0.jar >> /dev/null 2>>error.log &
			echo $! > pid;
			echo -e "\033[32;31;1;2m start game cross server success!! \033[m";
			exit;
		fi
		;;

	restart)
		process=`ps -ef | grep "$PWD_PATH/tank-cross-2.0.jar" | grep -v "grep"`;
		echo $process;
		if [ "$process" == "" ]; then
			./m.sh start;
			exit;
		else
			./m.sh stop;
		fi

		while true
		do
			process=`ps -ef | grep "$PWD_PATH/tank-cross-2.0.jar" | grep -v "grep"`;
			if [ "$process" == "" ]; then
				./m.sh start;
			break;
			else
				sleep 1;
				echo "process exsits"
			fi
		done
		;;

	stop)
		stop_pid=`ps -ef | grep "$PWD_PATH/tank-cross-2.0.jar" | grep -v "grep" |awk '{print $2}'`
		kill $stop_pid;
		echo -e "\033[32;31;1;2m stop game cross server success!! \033[m";
		;;

	check)
		ps -ef | grep "$PWD_PATH/tank-cross-2.0.jar" | grep -v "grep";
		;;
	
	back)
		rm -rf tank_game.jar.bak;
		mv tank-cross-2.0.jar tank-cross-2.0.jar.bak;
		;;

esac
