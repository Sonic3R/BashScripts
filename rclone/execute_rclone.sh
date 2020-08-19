clear
mntpath="/mnt/gdrive/BDs"
transfersitem=2
remove=1

escapechars() {
   num=$1

   num=${num//.}
   num=${num// }
   num=${num//)}
   num=${num//(}
   num=${num//_}

   echo $num
}

isDifferent() {
  arr=$@

  isdiff=0
  compare=0
  escape=""

  for item in $arr; do
     escape=$(escapechars $item)

     if [[ $compare == 0 ]]; then
      compare=$escape
      continue
     fi

     if [[ $compare != $escape ]]; then
      isdiff=1
      break
     fi
  done
  echo $isdiff
}

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
                diff=$(isDifferent ${arr[@]})

                if [[ $diff == 1 ]]; then
                       num=0000
                else
                       num=${arr[0]}
                fi

                num=$(escapechars $num)
        fi

        echo $num
        echo Will copy from "$item" to "$mntpath/$num/$itemname"/
        rclone copy $item $mntpath/$num/$itemname/ --progress --transfers=$transfersitem

        if [ $? -ne 0 ]; then
          IFS=$SAVEIFS
          continue
        fi


        if [[ $remove == 1 ]]; then
                rm -rf $item
        fi

        IFS=$SAVEIFS
done
