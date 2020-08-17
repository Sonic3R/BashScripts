clear
mntpath="/mnt/gdrive/BDs"
transfersitem=2

for f in "$@"; do
        SAVEIFS=$IFS
        IFS=$(echo -en "\n\b")

        item=$f

        if [[ $item == "" ]]; then
                 echo No item defined
                 IFS=$SAVEIFS
                 exit 1
        fi

        itemname=$(basename "$item")

        if [[ $itemname == "" ]]; then
                 echo Invalid name
                 IFS=$SAVEIFS
                 exit 1
        fi

        itemname=${itemname//\'/}
        itemname=${itemname// /.}
        itemname=${itemname//_/.}
        itemname=${itemname//\[/}
        itemname=${itemname//\]/}

        newpath="$(dirname $item)/$itemname"
        echo $newpath

        if [[ $newpath != $item ]]; then
                 mv $item $newpath
                 item=$newpath
        fi
        
        num=$(echo "$itemname" | grep -o -E '[\s.(_][0-9]{4}[\s.)_]')

        if [[ $num == "" ]]; then
                 num=0000
        else
                arr=($num)
                num=${arr[0]}
                num=${num//.}
                num=${num// }
                num=${num//)}
                num=${num//(}
                num=${num//_}
        fi

        echo $num
        echo Will copy from "$item" to "$mntpath/$num/$itemname"/

        rclone copy $item $mntpath/$num/$itemname/ --progress --transfers=$transfersitem
        IFS=$SAVEIFS
done
