#!/sh

IFACE=$1
IP=$2
GW=$3
MAC=$4

ip link set $IFACE down
ip link set dev $IFACE address $MAC
ip link set $IFACE up
ip addr flush dev $IFACE

ifconfig $IFACE $IP netmask 255.255.255.0 up
route add default gw $GW

echo "New IP: $IP"
echo "New MAC: $MAC"
echo

iwconfig $IFACE
ifconfig $IFACE
