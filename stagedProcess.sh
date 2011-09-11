# Part of [MSGShellUtils](github.com/MattiSG/MSGShellUtils)
# Author: [Matti Schneider-Ghibaudo](mattischneider.fr)

# requires ui.sh
initializeANSI

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


MSGstage=$1
MSGcurrentCategory=''
MSGglobalErrors=0
MSGcategoryErrors=0
MSG_USE_GROWL=1


dot() {
	echo -n " $greenf.$reset"
}

bang() {
	echo -n " $redf!$reset"
}

category() {
	echo -n $1'…'
	MSGcurrentCategory=$1
}

ok() {
	if 	[[ $MSGcategoryErrors  != 0 ]]
	then
		echo "$redf$boldon > error!$reset"
		if [[ $MSG_USE_GROWL ]]
		then growlnotify "$MSGcurrentCategory failed" -m "$MSGcategoryErrors errors encountered" -p High
		fi
	else
		echo "$greenf$boldon ok$reset"
		if [[ $MSG_USE_GROWL ]]
		then growlnotify "$MSGcurrentCategory succeeded" -m "No errors encountered"
		fi
	fi
	
	prevErrorCount=$MSGcategoryErrors
	MSGcategoryErrors=0

	return $prevErrorCount
}

end() {
	if [[ $MSGglobalErrors = 0 ]]
	then
		echo "$greenb$blackf$boldon     Done!     $reset"
		if [[ $MSG_USE_GROWL ]]
		then growlnotify "$MSGcurrentCategory succeeded" -m "No errors encountered"
		fi
		exit 0
	else
		echo "$redb$blackf$boldon     Errors occured!     $reset"
		if [[ $MSG_USE_GROWL ]]
		then growlnotify "$MSGcurrentCategory failed" -m "$MSGglobalErrors errors encountered"
		fi
		exit 1
	fi
}

#Tries the passed in command (may be several arguments)
#Returns the command's return value
try() {
	if ! $*
	then
		let MSGcategoryErrors++
		let MSGglobalErrors++
	fi

	return $?
}

#Tries the passed in command like `try`, but redirects all outputs to log and simply outputs a dot.
try_silent() {
	if try $* > $LOG 2> $LOG
	then dot
	else bang
	fi
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
