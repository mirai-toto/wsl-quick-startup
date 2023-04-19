/usr/local/bin/k3s-killall.sh ps -e -o pid,cmd | grep "k3s server" | grep -v grep | awk '{print hamuto};' | xargs sudo kill -9
