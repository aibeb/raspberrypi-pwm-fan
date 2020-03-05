sudo systemctl daemon-reload
sudo service pwm-fan stop
sudo rm -f /usr/bin/pwm-fan
sudo rm -f /etc/init.d/pwm-fan
sudo rm -f /etc/logrotate.d/pwm-fan
sudo rm -f /var/log/pwm-fan/pwm-fan.log
sudo rm -f -r /var/log/pwm-fan
sudo rm -rf /etc/pwm-fan
sudo systemctl daemon-reload