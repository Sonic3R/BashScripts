#clear
mntpath="/mnt/gdrive/BDs"
transfersitem=2

removechars() {
   num=$1

   num=${num//.}
   num=${num// }
   num=${num//)}
   num=${num//(}
   num=${num//_}

   echo $num
}

replacechars() {
   itemname=$1

   itemname=${itemname//\'/}
   itemname=${itemname// /.}
   itemname=${itemname//_/.}
   itemname=${itemname//\[/}
   itemname=${itemname//\]/}

   echo $itemname
}

isTv() {
  val="$1"

  output=$(echo "$val" | grep -o -E '[\s.(_]S[0-9]{1,2}[\s.(_]?D((I|i)SC)?[0-9]{1,2}[\s.(_]')
  if [[ $output == "" ]]; then
    output=$(echo "$val" | grep -o -E '(.+)[\s.(_]S[0-9]{2}[\s.(_]')
  fi
  
  if [[ $output == "" ]]; then
    echo 0
  else
    echo 1
  fi
}

getTv() {
  val="$1"

  output=$(echo "$val" | grep -o -E '(.+)[\s.(_]S[0-9]{2}[\s.(_]?D((I|i)SC)?[0-9]{2}[\s.(_]')

  if [[ $output == "" ]]; then
    output=$(echo "$val" | grep -o -E '(.+)[\s.(_]S[0-9]{2}[\s.(_]')
  fi

  if [[ $output == "" ]]; then
    echo ""
  else
    output=$(echo "$val" | grep -o -E '(.+)[\s.(_]S[0-9]{2}')
  fi

  arr=()

  [[ $output =~ ((.+)[\s.\(_](S[0-9]{2})) ]] && arr+=("${BASH_REMATCH[2]}") && arr+=("${BASH_REMATCH[3]}")

  echo ${arr[@]}
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

	isbusy=$(lsof +D "$item")
	echo $isbusy

	itemname=$(replacechars $itemname)
	newpath="$(dirname $item)/$itemname"

	echo $newpath

	if [[ $newpath != $item ]]; then
		if [[ $isbusy == "" ]]; then
			mv $item $newpath
		else
			cp -rf $item $newpath
		fi
	        item=$newpath
	fi

	totalfiles=$(find $newpath -type f | wc -l)
	echo "Total $totalfiles items found"

	if [[ $totalfiles -gt 300 ]]; then
		transfersitem=8
	else
		transfersitem=4
	fi

	echo "Setting transfers number to $transfersitem"

	istv=$(isTv "$itemname")
	mediafile=""

	if [[ $istv == 1 ]]; then
		arr=($(getTv $itemname))
		len=${#arr[@]}

		if [[ $arr == "" || $len == 0 ]]; then
			echo "Invalid TV format"
			IFS=$SAVEIFS
			continue
		fi

		tvname=$(replacechars ${arr[0]})
		echo Will copy from "$item" to "$mntpath/TV/$tvname/${arr[1]}/$itemname"/
		rclone copy $item $mntpath/TV/$tvname/${arr[1]}/$itemname/ --progress --transfers=$transfersitem

		mediafile=${tvname}.${arr[1]}.bdinfo
		echo "" > $mediafile

		if [[ -f $mediafile ]]; then
			a=1
			#rclone copy $mediafile $mntpath/TV/$tvname/${arr[1]}/ --progress
		fi
	else
		num=$(echo "$itemname" | grep -o -E '[\s.(_][0-9]{4}[\s.)_]')

		if [[ $num == "" ]]; then
			 num=0000
		else
			arr=($num)
			num=${arr[0]}
			num=$(removechars $num)
		fi

		echo $num
		echo Will copy from "$item" to "$mntpath/Movies/$num/$itemname"/

		rclone copy $item $mntpath/Movies/$num/$itemname/ --progress --transfers=$transfersitem

		mediafile=${item}.bdinfo
		echo "" > $mediafile

		if [[ -f $mediafile ]]; then
			a=1
			#rclone copy $mediafile $mntpath/Movies/$num/ --progress
		fi
	fi

	if [ $? -ne 0 ]; then
		IFS=$SAVEIFS
		continue
	fi

	if [[ $isbusy == "" ]]; then
		echo Removing $item
		rm -rf $item
	else
		if [[ $newpath != "" && -d $newpath ]]; then
			echo Removing $newpath
			rm -rf $newpath
		fi
	fi

	if [[ -f $mediafile ]]; then
        	rm $mediafile
        fi

	IFS=$SAVEIFS
done
