sudo sh -c "echo 0 > /sys/class/pwm/pwmchip0/export"

sudo sh -c "echo 10000000 > /sys/class/pwm/pwmchip0/pwm0/period"
sudo sh -c "echo 0 > /sys/class/pwm/pwmchip0/pwm0/duty_cycle"

sudo sh -c "echo 1 > /sys/class/pwm/pwmchip0/pwm0/enable"

sudo cp -f pwm-fan.sh /usr/bin/pwm-fan
sudo chmod 755 /usr/bin/pwm-fan
sudo cp -f ./init.d/pwm-fan /etc/init.d/pwm-fan
sudo chmod 755 /etc/init.d/pwm-fan
sudo cp -f ./logrotate.d/pwm-fan /etc/logrotate.d/pwm-fan
sudo chmod 644 /etc/logrotate.d/pwm-fan
if [ ! -d "/var/log/pwm-fan" ];then
sudo mkdir /var/log/pwm-fan
fi
sudo chown root:root /var/log/pwm-fan
sudo chmod 777 /var/log/pwm-fan
sudo touch /var/log/pwm-fan/pwm-fan.log
sudo chown root:root /var/log/pwm-fan/pwm-fan.log
sudo chmod 666 /var/log/pwm-fan/pwm-fan.log
sudo mkdir /etc/pwm-fan
sudo cp -n pwm-fan.conf /etc/pwm-fan
sudo systemctl daemon-reload
sudo update-rc.d pwm-fan defaults
sudo service pwm-fan start