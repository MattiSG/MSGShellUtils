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
MSGglobalError=0
MSGcategoryError=0

dot() {
	echo -n "$greenf.$reset"
}

category() {
	echo -n $1
}

ok() {
	if 	[[ $MSGcategoryError  != 0 ]]
	then echo "$redf$boldon > error!$reset"
	else echo "$greenf$boldon ok$reset"
	fi
	
	MSGcategoryError=0
}

end() {
	if [[ $MSGglobalError = 0 ]]
	then
		echo "$greenb$blackf$boldon     Done!     $reset"
		exit 0
	else
		echo "$redb$blackf$boldon     Errors occured!     $reset"
		exit 1
	fi
}

try() {
	if [[ $MSGstage ]] && [[ $MSGstage = 'verbose' ]]
	then 
		if ! $*
		then
			MSGcategoryError=1
			MSGglobalError=1
		fi
	else
		if ! $* > /dev/null
		then
			MSGcategoryError=1
			MSGglobalError=1
		fi
	fi
}

continue_unless() {
	if [[ $MSGstage ]] && [[ $MSGstage = $1 ]]
	then end
	fi
}
