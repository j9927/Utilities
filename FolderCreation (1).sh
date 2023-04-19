#!/bin/bash
#T=To retrieve the group of users in the IT 
IT_GROUP="it"
IT_USERS=$(getent group $IT_GROUP | cut -d: -f4 | tr ',' '\n')

#Providing each member of the IT department with access to inbound HTTPS packets 
for USER in $IT_USERS
do
sudo iptables -A OUTPUT -p tcp --dport 443 -m owner --uid-owner $USER -j ACCEPT
done

#Adding an exception for the local HTTP server
sudo iptables -A OUTPUT -p tcp --dport 443 -d 192.168.2.3 -j ACCEPT

#Eliminating all HTTP and HTTP data
sudo iptables -t filter -A OUTPUT -p tcp --dport 80 -j DROP
sudo iptables -t filter -A OUTPUT -p tcp --dport 443 -j DROP

#Displaying a message showing the amount of users granted with a internet access
IT_USER_COUNT=$(echo "$IT_USERS" | wc -l)
echo "Internet access has been granted to $IT_USER_COUNT users in the IT group."
