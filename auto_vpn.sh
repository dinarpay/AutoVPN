#!/bin/bash
#kal1gh0st (green machine)
#Se vuoi puoi cambiare questi parametri in base alle tue esigenze:

country='' # empty for any or JP, KR, US, TH, etc.
useSavedVPNlist=0 # impostare su 1 se non si desidera scaricare l'elenco VPN ogni volta che si riavvia questo script, altrimenti impostare su 0
useFirstServer=0 # imposta il valore a 0 per scegliere un server VPN casuale, altrimenti imposta a 1 (forse il primo ha un punteggio più alto)
vpnList='/tmp/vpns.tmp'
proxy=0 # sostituire con 1 se si desidera connettersi al server VPN tramite un proxy
proxyIP=''
proxyPort=8080
proxyType='socks' # socks or http
# non cambiare questo:
counter=0
VPNproxyString=''
cURLproxyString=''
if [ $proxy -eq 1 ];then
echo 'We will use a proxy'
if [ -z "$proxyIP" ]; then
echo "Per utilizzare un proxy, è necessario specificare l'indirizzo IP e la porta del proxy (codificati nel codice sorgente)."
exit
else
if [ "$proxyType" == "socks" ];then
VPNproxyString=" --socks-proxy $proxyIP $proxyPort "
cURLproxyString=" --proxy socks5h://$proxyIP:$proxyPort "
elif [ "$proxyType" == "http" ];then
VPNproxyString=" --http-proxy $proxyIP $proxyPort "
cURLproxyString=" --proxy http://$proxyIP:$proxyPort "
else
echo 'Unsupported proxy type.'
exit
fi
fi
fi
if [ $useSavedVPNlist -eq 0 ];then
echo 'Getting the VPN list'
curl -s $cURLproxyString https://www.vpngate.net/api/iphone/ > $vpnList
elif [ ! -s $vpnList ];then
echo 'Getting the VPN list'
curl -s $cURLproxyString https://www.vpngate.net/api/iphone/ > $vpnList
else
echo 'Using existing VPN list'
fi
while read -r line ; do
array[$counter]="$line"
counter=$counter+1
done < <(grep -E ",$country" $vpnList)
CreateVPNConfig () {
if [ -z "${array[0]}" ]; then
echo 'No VPN servers found from the selected country.'
exit
fi
size=${#array[@]}
if [ $useFirstServer -eq 1 ]; then
index=0
echo ${array[$index]} | awk -F "," '{ print $15 }' | base64 -d > /tmp/openvpn3
else
index=$(($RANDOM % $size))
echo ${array[$index]} | awk -F "," '{ print $15 }' | base64 -d > /tmp/openvpn3
fi
echo 'Choosing a VPN server:'
echo "Found VPN servers: $((size+1))"
echo "Selected: $index"
echo "Country: `echo ${array[$index]} | awk -F "," '{ print $6 }'`"
}
while true
do CreateVPNConfig
echo 'Trying to start OpenVPN client'
sudo openvpn --config /tmp/openvpn3 $VPNproxyString
read -p "Try another VPN server? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit
done
