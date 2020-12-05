package main

import (
	"bytes"
	"fmt"
	"os/exec"
	"testing"
)

func TestCommand(t *testing.T) {
	var errInfo bytes.Buffer

	// 启动pwm0
	cmd := exec.Command("sh", "-c", "echo 0 > /sys/class/pwm/pwmchip0/export")

	fmt.Println(cmd.String())

	cmd.Stderr = &errInfo

	if _, err := cmd.Output(); err != nil {
		fmt.Println(errInfo.String())
	}
	// 频率

	// 占空比

}
