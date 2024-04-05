#!/bin/bash

echo root:Liulu19950908! sudo chpasswd root
sudo sed -i 's/^?permitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd config;
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g’ /etc/ssh/sshd config;
sudo service sshd restart
