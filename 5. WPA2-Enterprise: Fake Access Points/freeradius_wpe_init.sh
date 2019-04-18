#!/sh

sudo killall hostapd radiusd
sudo radiusd -X &
sudo airmon-ng check kill

if [ ! -z "$2" ]; then
	sed 's/SSID_name/'$1'/g' files/ap.conf > files/aux.conf	
	sed '0,/wlan0/s/wlan0/'$2'/' files/aux.conf > files/temp.conf
	#rm files/aux.conf
else
	sed 's/SSID_name/'$1'/g' files/ap.conf > files/temp.conf
fi

sudo hostapd files/temp.conf

