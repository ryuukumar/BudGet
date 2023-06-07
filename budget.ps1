
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


$VERSION = "1.0.3"
$INCLUDE = "${PSScriptRoot}\scripts"



### ------------------------------
### PREFS
### ------------------------------

$prefs = new-object psobject



### ------------------------------
### GLOBAL VARIABLE DEFS
### ------------------------------

$messages = @()
$expenses = @()



### ------------------------------
### INCLUDES
### ------------------------------

. "${INCLUDE}\fxns.ps1"
. "${INCLUDE}\longstrings.ps1" 
. "${INCLUDE}\cmdparse.ps1" 



### ------------------------------
### ENTRY POINT
### ------------------------------

if (test-path ".\prefs.json") {
	$prefs = get-content .\prefs.json | convertfrom-json
}
else {
	Write-Host "Could not find prefs.json. Creating one with default parameters."
	$prefs | add-member -membertype noteproperty 'lastchecked' -value 0
	$prefs | add-member -membertype noteproperty 'token' -value "none"
	$prefs | add-member -membertype noteproperty 'chat_id' -value 0
	$prefs | add-member -membertype noteproperty 'utchours' -value 0
	$prefs | add-member -membertype noteproperty 'authuname' -value "none"
	$prefs | add-member -membertype noteproperty 'logpath' -value "none"
	$prefs | add-member -membertype noteproperty 'jsonpath' -value "none"
	$prefs | add-member -membertype noteproperty 'silent' -value $false
	$prefs | add-member -membertype noteproperty 'advmonthly' -value 0
	$prefs | convertto-json | out-file prefs.json
	Write-Host "prefs.json created. Please update the token for the program to work properly."
	pause
	exit
}

$url = 'https://api.telegram.org/bot{0}' -f $prefs.token

$lastchecked_date = (get-date 01.01.1970).addseconds($prefs.lastchecked)
$lastchecked_date = $lastchecked_date.addhours($prefs.utchours)

Clear-Host
Write-Host "+---------------------+`n| BUDGET.PS1 v${VERSION}   |`n+---------------------+`n"

Write-Output "Last updated ${lastchecked_date}"

$inmessages = invoke-restmethod -method get -uri ($url + '/getUpdates') -erroraction stop

#$inmessages.result.message | ConvertTo-Json

foreach ($msg in $inmessages.result.message) {
	if ($msg.date -gt $prefs.lastchecked) {
		if ($msg.chat.username -eq $prefs.authuname) {
			$messages += $msg
			if (-not ($prefs | Get-Member "chat_id")) {
				$prefs | add-member -force -membertype noteproperty 'chat_id' -value $msg.chat.id
				write-host "Set chat_id to: $($prefs.chat_id)"
			}
		}
		$prefs.lastchecked = $msg.date
	}
}

# Post-update upgradation:

if (-not ($prefs | Get-Member "currentversion")) {
	$prefs | add-member -membertype noteproperty 'currentversion' -value $VERSION
	Write-Host "Upgraded to version ${VERSION}."
	send-msg -message "<b>BudGet has been upgraded to version ${VERSION}!</b>`nCheck <code>changelog.txt</code> to see what's new in this version." -prefs ([ref]$prefs)
}

if (-not ($prefs | Get-Member "webbg")) {
	$prefs | add-member -membertype noteproperty 'webbg' -value "none"
	Write-Host "Added webbg property."
	send-msg -message "You can now set a wallpaper for the Web UI by placing it in the 'bg' folder and then running the command <code>c pref webbg [filename]</code>." -prefs ([ref]$prefs)
}

if (-not ($prefs | Get-Member "advmonthly")) {
	$prefs | add-member -membertype noteproperty 'advmonthly' -value 0
	send-msg -message "CAUTION: After an update, your monthly spending target is now stored in a different way. It has been set to 0 rupees. Type <code>c pref advmonthly [amount]</code> to set your spending target." -prefs ([ref]$prefs)
}

if (-not ($prefs | Get-Member "silent")) {
	$prefs | add-member -membertype noteproperty 'silent' -value $false
}


if (test-path $prefs.jsonpath) {
	$expenses = get-content $prefs.jsonpath | ConvertFrom-Json
}

if ($args[0] -and $args[0] -contains "shellmode") {
	$inp = Read-Host "Started in shell mode.`nType help to get a list of commands.`n`nshell ~ "
	while ($inp -ne "exit") {
		CmdParse -command "c ${inp}" -prefs ([ref]$prefs) -expenses ([ref]$expenses) -output "stdout"
		$inp = Read-Host "shell ~ "
	}
	$prefs | convertto-json | out-file .\prefs.json
	$expenses | ConvertTo-Json | out-file "$($prefs.jsonpath)"
	$curated = "data = '$($($(Get-Content "$($prefs.jsonpath)") -join '','') -replace '  ','')';`n"
	$curated += "prefs = '$($($(Get-Content "prefs.json") -join '','') -replace '  ','')';"
	Write-Output $curated | Out-File "curated.json"
	exit
} else {
	Write-Host "Running in Telegram mode."
}

[double]$addnamt = 0
foreach ($msg in $messages) {
	$amt = ($msg.text -split ' ')[0]
	if ($amt -eq 'c') {
		if ($msg.reply_to_message) {
			CmdParse -command $msg.text -prefs ([ref]$prefs) -expenses ([ref]$expenses) -reply $msg.reply_to_message
		}
		else {
			CmdParse -command $msg.text -prefs ([ref]$prefs) -expenses ([ref]$expenses)
		}
	}
	else {
		if (-not(isNumber(${amt}))) {
			send-msg -message "${amt}: not a number." -isReply $true -replyID $msg.message_id -prefs ([ref]$prefs)
			continue
		}
		$reason = ($msg.text -split ' ')[1]
		if (($msg.text -split ' ').Length -gt 1) {
			for ($i = 2; $i -lt ($msg.text -split ' ').Length; $i++) {
				$reason += ' '
				$reason += ($msg.text -split ' ')[$i]
			}
		}
		$newexpense = @{
			Amount  = $amt
			Expense = $reason
			Date    = $msg.date
			Metric1 = 0
			Mertic2 = 0
			Metric3 = 0
		}
		$expenses += $newexpense
		$addnamt += $amt
	}
}

$prefs | convertto-json | out-file .\prefs.json

$expenses = $expenses | Sort-Object -Property Date
$expenses | ConvertTo-Json | out-file "$($prefs.jsonpath)"
$curated = "data = '$($($(Get-Content "$($prefs.jsonpath)") -join '','') -replace '  ','')';`n"
$curated += "prefs = '$($($(Get-Content "prefs.json") -join '','') -replace '  ','')';"
Write-Output $curated | Out-File "curated.json"

if ($addnamt -gt 0) {
	if (-not $prefs.silent) {
		send-msg -message "Added ${addnamt} rupees of expenses.`n<i>To shut me up, type: </i><code>c mode silent</code>" -prefs ([ref]$prefs)
		save-log("Added ${addnamt} rupees of expenses.")
	}
}



### ------------------------------
### END
### ------------------------------