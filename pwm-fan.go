package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"time"
)

var tempMin = uint64(50000)
var maxDutyCycle = uint64(10000000)
var minDutyCycle = uint64(7000000)
var tempMax = tempMin + 10000     // 60
var tempShutDown = tempMin - 5000 // 45

func main() {
	log.SetFlags(log.LstdFlags | log.Lshortfile)

	if _, err := os.Stat("/sys/class/pwm/pwmchip0/pwm0"); os.IsNotExist(err) {
		fmt.Println("sudo sh -c \"echo 0 > /sys/class/pwm/pwmchip0/export\"")
		_, err := exec.Command("sudo", "sh", "-c", "echo 0 > /sys/class/pwm/pwmchip0/export").Output()
		if err != nil {
			log.Println(err)
		}
	}

	fmt.Println("sudo sh -c \"echo " + strconv.FormatUint(maxDutyCycle, 10) + " > /sys/class/pwm/pwmchip0/pwm0/period\"")
	_, err := exec.Command("sudo", "sh", "-c", "echo "+strconv.FormatUint(maxDutyCycle, 10)+" > /sys/class/pwm/pwmchip0/pwm0/period").Output()
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("sudo sh -c \"echo 0 > /sys/class/pwm/pwmchip0/pwm0/duty_cycle\"")
	_, err = exec.Command("sudo", "sh", "-c", "echo 0 > /sys/class/pwm/pwmchip0/pwm0/duty_cycle").Output()
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("sudo sh -c \"echo 0 > /sys/class/pwm/pwmchip0/pwm0/enable\"")
	_, err = exec.Command("sudo", "sh", "-c", "echo 0 > /sys/class/pwm/pwmchip0/pwm0/enable").Output()
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("sudo sh -c \"echo 1 > /sys/class/pwm/pwmchip0/pwm0/enable\"")
	_, err = exec.Command("sudo", "sh", "-c", "echo 1 > /sys/class/pwm/pwmchip0/pwm0/enable").Output()
	if err != nil {
		log.Fatal(err)
	}

	for {
		// read temperature
		temperature, err := exec.Command("cat", "/sys/class/thermal/thermal_zone0/temp").Output()
		if err != nil {
			log.Fatal(err)
		}
		fmt.Printf("The temperature is %s", temperature)
		// read dutyCycle
		dutyCycle, err := exec.Command("cat", "/sys/class/pwm/pwmchip0/pwm0/duty_cycle").Output()
		if err != nil {
			log.Fatal(err)
		}
		fmt.Printf("The dutyCycle is %s", dutyCycle)

		temp, _ := strconv.ParseUint(strings.Replace(string(temperature), "\n", "", -1), 10, 64)

		tempDutyCycle, _ := strconv.ParseUint(strings.Replace(string(dutyCycle), "\n", "", -1), 10, 64)

		if tempMin < temp && temp < tempMax {
			tempDutyCycle = maxDutyCycle - (tempMax-temp)*(maxDutyCycle-minDutyCycle)/(tempMax-tempMin)
		}
		if tempShutDown < temp && temp < tempMin {
			if tempDutyCycle != 0 {
				tempDutyCycle = minDutyCycle
			}
		}
		if temp < tempShutDown {
			tempDutyCycle = 0
		}
		if temp > tempMax {
			tempDutyCycle = maxDutyCycle
		}
		fmt.Printf("temp=%d, tempMin=%d,tempMax=%d, tempShutDown=%d, tempDutyCycle=%s\n", temp, tempMin, tempMax, tempShutDown, strconv.FormatUint(tempDutyCycle, 10))

		_, err = exec.Command("sudo", "sh", "-c", "echo "+strconv.FormatUint(tempDutyCycle, 10)+" > /sys/class/pwm/pwmchip0/pwm0/duty_cycle").Output()
		if err != nil {
			log.Println(err)
		}

		time.Sleep(5 * time.Second)
	}
}
