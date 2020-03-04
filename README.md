support raspberrypi 4 vie ubuntu or raspbian
support raspberrypi 3b+ vie ubuntu or raspbian

# Connect the fan according to the schematic
![](diagram.png)

![](GPIO.png)

# config raspberrypi
add to config.txt
```
dtoverlay=pwm

dtoverlay=pwm-2chan
```
then

```
reboot
```

after reboot, export pwm0

```
sudo sh -c "echo 0 > /sys/class/pwm/pwmchip0/export"
```

# install

```
sh install.sh
```

```
sudo systemctl status pwm-fan
```

# uninstall
```
sh uninstall.sh
```