
###
#
#	BudGet v1.0.3
#	(c) Aditya Kumar, 2023
#	Some rights reserved.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
#	This code is NOT intended to work on any systems apart from mine,
#	so do NOT expect active support from me.
#
#	Do NOT redistribute this program without first consulting with
#	the original developer, i.e. me.
#
###



### ------------------------------
### FUNCTION DEFS
### ------------------------------

function set-alias ([string]$str) {
	$aliases = "[[`
			'advmonthly', 'am'
		], `
		[	`
			'pref', 'p'
		]]" | ConvertFrom-Json

	#send-msg -message $($aliases | Out-String)

	foreach ($alias in $aliases) {
		if ($alias | Where-Object { $_ -match $str }) {
			return $alias[0]
		}
	}

	return $str
}



### ------------------------------
### END
### ------------------------------