# Part of [MSGShellUtils](github.com/MattiSG/MSGShellUtils)
# Author: [Matti Schneider-Ghibaudo](mattischneider.fr)

# requires ui.sh

# The goal of this set of functions is to let you describe a setup / cleanup script in a very pretty manner, with different user-specified MSGstages.
# Real-world example:
#
# category 'Emptying cache…'
# 	try rm -rf cache/* log/*
#
# 	try rm -f web/css/turbine/cache/*
# 	
# 	try $php ./symfony cc
# ok
# 
# continue_unless cache # if the script is called with "cache" as an argument, then stop there
# 
# category 'Updating submodules…'
# 	git submodule update --init --recursive
# ok
# 
# category 'Setting permissions…'
# 	try $php ./symfony pr:p
# ok

 # To be refined by calling scripts
MSG_USE_GROWL=1
MSG_LIMIT=40 #how many characters from tried commands should be displayed?
LOG="log.txt" # where to log everything from try_silent?

# Private vars
MSGstage=$1
MSGcurrentCategory=''
MSGglobalErrors=0
MSGcategoryErrors=0

dot() {
	echo -n " $greenf ✓ $reset"
}

bang() {
	echo -n " $redf ✗ $reset"
}

category() {
	echo $blueb$boldon$1'…'$reset
	MSGcurrentCategory=$1
}

ok() {
	if 	[[ $MSGcategoryErrors  != 0 ]]
	then
		echo "$redb$boldon  ✘  $reset"
		if [[ $MSG_USE_GROWL ]]
		then growlnotify "$MSGcurrentCategory failed" -m "$MSGcategoryErrors errors encountered" -p High
		fi
	else
		echo "$greenb$boldon  ✔  $reset"
		if [[ $MSG_USE_GROWL ]]
		then growlnotify "$MSGcurrentCategory succeeded" -m "No errors encountered" -p Moderate
		fi
	fi
	
	prevErrorCount=$MSGcategoryErrors
	MSGcategoryErrors=0

	return $prevErrorCount
}

end() {
	if [[ $MSGglobalErrors = 0 ]]
	then
		echo "$greenb$blackf$boldon	Done!		$reset"
		if [[ $MSG_USE_GROWL ]]
		then
			growlnotify "Process succeeded" -m "No errors encountered"
			echo "[$(date)]	process succeeded" >> $LOG
		fi
		exit 0
	else
		echo "$redb$blackf$boldon	Errors occured!		$reset"
		if [[ $MSG_USE_GROWL ]]
		then
			growlnotify "Process failed" -m "$MSGglobalErrors errors encountered" -p High --sticky
			echo "[$(date)]	**process failed**" >> $LOG
		fi
		exit 1
	fi
}

#Tries the passed in command (may be several arguments)
#Returns the command's return value
try() {
	if $*
	then
		dot
	else
		bang
		
		let MSGcategoryErrors++
		let MSGglobalErrors++
		echo "[$(date)]	** $* failed**" >> $LOG
	fi	

	echo -n $* | cut -c1-$MSG_LIMIT
#	if [[ $(echo -n $* | wc -c) -gt $MSG_LIMIT ]]
#	then echo -n '…' #TODO: unfortunately, cut will always add a newline. Uncomment when a workaround is found.
#	fi
	echo

	return $?
}

#Tries the passed in command like `try`, but redirects all outputs to log and simply outputs a dot.
try_silent() {
	try $* >> $LOG 2>> $LOG
	
	return $?
}

#$1 = message. Optional. Title will always be the current category.
growl() {
	growlnotify -t $MSGcurrentCategory -m $1
}

continue_unless() {
	if [[ $MSGstage ]] && [[ $MSGstage = $1 ]]
	then end
	fi
}

synopsis() {
	egrep 'category|continue_unless|^end' $0 | sed s/category/"$blueb →"/g | sed s/continue_unless/"  $cyanb ⎋"/g | sed s/end/$reset/ | sed s/\'//g
}

if [[ $1 == -msg-scenario ]]
then
	synopsis
	exit 0
fi