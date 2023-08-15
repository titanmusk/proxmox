#!/bin/bash

IP=""
CREDENTIAL=""
LXC_ID=""
NODE_NAME=""

request_api_chek () {
   curl --silent --insecure --data "$CREDENTIAL" https://$IP:8006/api2/json/access/ticket| jq --raw-output '.data.ticket' | sed 's/^/PVEAuthCookie=/' > cookie
   curl --silent --insecure --data "$CREDENTIAL" https://$IP:8006/api2/json/access/ticket|  jq --raw-output '.data.CSRFPreventionToken' | sed 's/^/CSRFPreventionToken:/' > token
   curl --silent --insecure  --cookie "$(<cookie)" --header "$(<token)" https://$IP:8006/api2/json/nodes/$NODE_NAME/lxc/$LXC_ID/snapshot | jq
}

for i in `cat list_v`
do 
 check_v=$(echo "$i" | cut -f 3 -d '.')
 check_v16=$(echo "$i" | cut -f 1 -d '-')

 if [[ $check_v = "8-ce" ]] #15.9.8-ce.0 regrex used 8-ce
 then
   replayce=$(echo "v_$i" | sed 's/\./_/g'| sed 's/\-/_/g')
   #verification present snapshot veresuin if not present make upgrade and snapshort 
    if request_api_chek | grep $replayce; then
      echo "env is defined"
    else
     apt-get --only-upgrade install gitlab-ce=$i
     sleep 50s
     curl --silent --insecure  --cookie "$(<cookie)" --header "$(<token)" -X POST -d "snapname=$replayce" https://$IP:8006/api2/json/nodes/$NODE_NAME/lxc/$LXC_ID/snapshot | jq
     rm cookie token
     echo "$replayce isnt defined use script"
     sleep 10s
    fi
# same for v16
 elif [[ $check_v16 = "16.1.4"  ]] #make snapshot
 then
   replayce=$(echo "$i" | sed 's/\./_/g')
    if request_api_chek | grep $replayce; then
      echo "env is defined"
    else
     apt-get --only-upgrade install gitlab-ce=$i
     sleep 50s
     curl --silent --insecure  --cookie "$(<cookie)" --header "$(<token)" -X POST -d "snapname=$replayce" https://$IP:8006/api2/json/nodes/$NODE_NAME/lxc/$LXC_ID/snapshot | jq
     rm cookie token
     echo "$replayce isnt defined use script"
     sleep 10s
    fi
   else
    apt-get --only-upgrade install gitlab-ce=$i
 fi
done


