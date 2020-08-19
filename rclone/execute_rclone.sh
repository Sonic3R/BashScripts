clear
mntpath="/mnt/gdrive/BDs"
transfersitem=2
remove=1

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
    echo 0
  else
    echo 1
  fi
}

getTv() {
  val="$1"

  output=$(echo "$val" | grep -o -E '(.+)[\s.(_]S[0-9]{2}[\s.(_]?D((I|i)SC)?[0-9]{2}[\s.(_]')

  if [[ $output == "" ]]; then
    echo ""
  else
    output=$(echo "$val" | grep -o -E '(.+)[\s.(_]S[0-9]{2}')
  fi

  arr=()

  [[ $output =~ ((.+)[\s.\(_](S[0-9]{2})) ]] && arr+=("${BASH_REMATCH[2]}") && arr+=("${BASH_REMATCH[3]}")

  echo ${arr[@]}
}

isDifferent() {
  arr=$@

  isdiff=0
  compare=0
  escape=""

  for item in $arr; do
     escape=$(removechars $item)

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
		itemname=$(replacechars $itemname)
		newpath="$(dirname $item)/$itemname"
	echo $newpath

	if [[ $newpath != $item ]]; then
		 mv $item $newpath
		 item=$newpath
	fi

	istv=$(isTv "$itemname")

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
	else
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

			num=$(removechars $num)
		fi

		echo $num
		echo Will copy from "$item" to "$mntpath/Movies/$num/$itemname"/

		rclone copy $item $mntpath/Movies/$num/$itemname/ --progress --transfers=$transfersitem
	fi

	if [ $? -ne 0 ]; then
		IFS=$SAVEIFS
		continue
	fi

	if [[ $remove == 1 ]]; then
		rm -rf $item
	fi

	IFS=$SAVEIFS
done
