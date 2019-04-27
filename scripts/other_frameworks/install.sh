#!/sh
sudo apt-get install aircrack-ng httrack ettercap iodine wireshark
mkdir other_frameworks  && cd other_frameworks
git clone https://github.com/wifiphisher/wifiphisher && cd wifiphisher && sudo python setup.py install && cd ..
git clone https://github.com/DanMcInerney/wifijammer && cd wifijammer && sudo python setup.py install && cd ..
git clone https://github.com/Tylous/SniffAir && cd SniffAir && sudo ./setup.sh && cd ..
git clone https://github.com/P0cL4bs/WiFi-Pumpkin && cd WiFi-Pumpkin && sudo ./installer.sh --install && cd ..
git clone https://github.com/s0lst1c3/eaphammer && cd eaphammer && sudo ./kali-setup && cd ..
cd ..
