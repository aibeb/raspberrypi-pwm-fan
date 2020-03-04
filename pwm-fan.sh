#!/bin/sh

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

if [ -n "$1" ] ;then
CONF=$1
else
CONF=/home/pi/.pwm-fan.conf
fi
if [  -n "$2" ] ;then
LOG=$2
else
LOG=/var/log/pwm-fan/pwm-fan.log
fi

sudo sh -c "echo 10000000 > /sys/class/pwm/pwmchip0/pwm0/duty_cycle"

fan=0

while true
  do
  tmp=`cat /sys/class/thermal/thermal_zone0/temp`
  load=`cat /proc/loadavg | awk '{print $1}'`

  while read line; do
	name=`echo $line | awk -F '=' '{print $1}'`
	value=`echo $line | awk -F '=' '{print $2}'`
	case $name in
	"MODE")
	MODE=$value
	;;
	"set_temp_min")
	set_temp_min=$value
	;;
	"shutdown_temp")
	shutdown_temp=$value
	;;
	"set_temp_max")
	set_temp_max=$value
	;;
	*)
	;;
	esac
  done < $CONF
  
  pwm=$(10000000-($set_temp_max-$tmp)*($set_temp_max-$set_temp_min)/(10000000-5000000))
 
if [ $fan -eq 0 ] ;then
  pwm=0
  fi
  if [ $tmp -le $shutdown_temp ] && [ $MODE -eq 2 ] ;then
  pwm=0
  fan=0
  sudo sh -c "echo 0 > /sys/class/pwm/pwmchip0/pwm0/duty_cycle"
  sleep 5
  echo "`date` temp=$tmp pwm=$pwm MODE=$MODE CPU load=$load 小于设置温度关闭风扇 " >> $LOG
else

  if [ $MODE -eq 0 ] ;then
  pwm=0
  fan=0
  else
  
  if [ $MODE -eq 1 ] ;then
  pwm=10000000
  fan=1
  fi
  fi

  sudo sh -c "echo $pwm > /sys/class/pwm/pwmchip0/pwm0/duty_cycle"
    
if [ $pwm -eq 0 ] ;then
  echo "`date` temp=$tmp pwm=$pwm MODE=$MODE CPU load=$load 小于设置温度关闭风扇 " >> $LOG
else
  echo "`date` temp=$tmp pwm=$pwm MODE=$MODE CPU load=$load 大于设置温度持续开启风扇" >> $LOG
fi

loadavg=`cat /proc/loadavg`
awk=`cat /proc/loadavg | awk '{print $0}'`
  echo "`date` $loadavg $awk load=$load "
  sleep 5

fi
done