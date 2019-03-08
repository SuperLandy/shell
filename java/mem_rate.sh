#!/bin/bash
# 入参只有一个，即目标java的pid，如果没有，则默认找cpu最高的java进程 
if [ -z "$1" ]; then 
	### 1.先找到消耗cpu最高的Java进程 ### 
	pid=`ps -eo pid,%cpu,cmd --sort=-%cpu | grep java | grep -v grep | head -1 | awk 'END{print $1}' ` 
	if [ "$pid" = "" ]; then 
		echo "无Java进程，退出。" 
		exit 
	fi 
else 
	pid=$1 
fi 

### 2.生成dump后的文件名 ### 
curTime=$(date +%Y%m%dT%H:%M:%S) 
curDir="$(pwd)/jstack"
mkdir -p $curDir
# jstack后的文件会加上时间，便于对一个进程dump多次 
dumpFilePath="$curDir/pid-$pid-$curTime.txt" 
echo -e "Cpu最高的java进程: "`jps | grep $pid`"\n" > $dumpFilePath 

### 3.取到该进程的所有线程及其memery(只显示cpu大于0.0的线程) ### 
echo -e "进程内线程Mem占比如下（不显示memery占比为0的线程）:\n" >> $dumpFilePath 
ps H -eo pid,tid,%mem --sort=-%mem | grep $pid | awk '$3 > 0.0 {totalMem+=$3; printf("nid=0x%x, memery=%s\n", $2, $3) >> "'$dumpFilePath'"} 
END{printf("memery总占比:%s\n\n", totalMem) >> "'$dumpFilePath'"}' 

### 4.dump该进程 ### 
echo -e "如下是原生jstack后的结果:\n" >> $dumpFilePath 
jstack -l $pid >> $dumpFilePath 

echo "分析记录成功，分析文件生成目录为:" $dumpFilePath
exit
