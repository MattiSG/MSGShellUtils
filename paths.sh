# Part of [MSGShellUtils](github.com/MattiSG/MSGShellUtils)
# Author: [Matti Schneider-Ghibaudo](mattischneider.fr)

# Returns $1, without trailing slash.
# Idempotent function.
# Example:
#	removeTrailingSlash woudzi/gouga/  ->  woudzi/gouga
#	removeTrailingSlash woudzi/gouga  ->  woudzi/gouga

removeTrailingSlash() {
	for i in $*
	do echo $i | sed s:'/$'::
 	done
}


# Returns the absolute path of $1

getAbsolutePath() {
	for i in $*
	do
		if [[ -L "$(removeTrailingSlash $i)" ]]
		then echo $(readlink "$i")
		elif echo $i | egrep -q '^/'
		then echo $i
		else
			oldDir=$(pwd)
			cd "$i"
			pwd
			cd $oldDir
		fi
	done
}


# Returns the relative path from $2 to $1.
# Always adds a trailing slash
# Examples:
#	getRelativePath woudzi/gouga woudzi/gouga/bougou	->	../
#	getRelativePath woudzi/gouga/bougou woudzi/gouga	->	bougou/

getRelativePath() {
	set $(getAbsolutePath "$1") $(getAbsolutePath "$2")
	i=2
	part1=$(echo $1 | cut -d "/" -f $i)
	part2=$(echo $2 | cut -d "/" -f $i)
	while [ -n "$part1" -o -n "$part2" ]
	do if [[ $part1 != $part2 ]]
		then
			if [[ -z $part2 ]]
			then result=$result$part1/
			elif [[ -z $part1 ]]
			then result=../$result
			else result="../$result/"$part1
			fi
		fi
		let i++
		part1=$(echo $1 | cut -d "/" -f $i)
		part2=$(echo $2 | cut -d "/" -f $i)
	done
	echo $result | tr -s "/"
}


# Disables space as a separator.
# Especially useful when iterating over files in a directory that contain spaces in their filenames.
# Example:
#	for file in *
#	do #whatever
#	done
#	# if one of "file" contains a space, it will be split. This function prevents such behaviour.

disableSpaceAsSeparator() {
	OLDIFS=$IFS
	IFS=$(echo -en "\n\b")
}


# Call after a call to disableSpaceAsSeparator to restore standard separators.

restoreSeparators() {
	IFS=$OLDIFS
}
