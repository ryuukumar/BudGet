
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
### INCLUDES
### ------------------------------

. "${INCLUDE}\setalias.ps1"



### ------------------------------
### FUNCTION DEFS
### ------------------------------

function CmdParse {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)][string]$command,
		[Parameter(Mandatory = $true)][ref]$expenses,
		[Parameter(Mandatory = $true)][ref]$prefs,
		[Parameter(Mandatory = $false)][pscustomobject]$reply,
		[Parameter(Mandatory = $false)][string]$output = "telegram"
	)
	BEGIN {
		function Send-Output {
			param (
				[Parameter(Mandatory = $true)][string]$message,
				[Parameter(Mandatory = $false)][bool]$sendCmdPrefix = $true
			)

			if ($output -eq "telegram") {
				if ($sendCmdPrefix) {send-msg -message "<code>${command}</code>: ${message}" -prefs $prefs}
				else {send-msg -message "${message}" -prefs $prefs}
			}
			if ($output -eq "stdout") {
				write-host $message
			}
		}

		function Parse-Date {
			param (
				[Parameter(Mandatory=$true)][string]$sdate,
				[Parameter(Mandatory=$true)][string]$stime
			)
			[string]$date
			switch($sdate) {
				"-" {
					$date = Get-Date -format "MM-dd-yyyy" | Out-String
					break
				}
				"yesterday" {
					$today = Get-Date
					$date = $today.AddDays(-1).ToString("MM-dd-yyyy")
					break
				}
				Default {
					# leave the validity of the date to the user
					$date = Get-Date($sdate) -format "MM-dd-yyyy" | Out-String
				}
			}

			$time
			switch ($stime) {
				"-" {
					$time = Get-Date("${date} 12:00:00")
					break
				}
				Default {
					$time = Get-Date("${date} ${stime}")
					
				}
			}
			$time = $time.AddMinutes(-330)
			$dts = $time.ToString("MM-dd-yyyy HH:mm:ss")
			return $dts
		}
	}
	PROCESS {
		if (($command -split ' ').Length -lt 2) {
			Send-Output -message "Expected command, got nothing. Type <code>c help</code> to get a list of commands."
			return
		}
		$clause = set-alias(($command -split ' ')[1])
		if ($output -ne "stdout") {Write-Host "Executing command: ${command}"}
		switch ($clause) {
			"mode" {
				if (($command -split ' ').Length -lt 3) {
					$msg = "current mode is <code>"
					if ($prefs.value.silent) { $msg += "silent" }
					else { $msg += "verbose" }
					$msg += "</code>."
					send-output -message $msg
					break
				}
				if (($command -split ' ')[2] -eq "silent") {
					$prefs.value.silent = $true
					send-output -message "set silent response mode."
				}
				else {
					if (($command -split ' ')[2] -eq "verbose") {
						$prefs.value.silent = $false
						send-output -message "set verbose response mode."
					}
					else {
						send-output -message "unrecognised mode."
					}
				}
				break
			}
			"del" {
				if ($reply.date -eq 0) {
					send-output -message "don't know what to delete. Send this command as a reply to the message you want deleted."
					break
				}
				$removedmsg = $false
				$compdate = $reply.date

				if(($reply.text -split ' ')[0] -eq "c") {
					$tmpdate = Parse-Date -sdate ($reply.text -split ' ')[2] -stime ($reply.text -split ' ')[3]
					$compdate = Get-Date "$tmpdate" -UFormat %s
					#$compdate += 330*60
				}

				foreach ($exp in $expenses.value) {
					if ($exp.Date -eq $compdate) {
						send-output -message "removed $($exp.Amount) rupees of expense."
						$expenses.value = $expenses.value | Where-Object { $_.Date -notmatch $exp.Date }
						$removedmsg = $true
						break
					}
				}
				if (-not $removedmsg) {
					send-output -message $del_cantfindmsg
				}
				break
			}
			"pref" {
				if (($command -split ' ').Length -lt 3) {
					send-output -message "no preference mentioned. Type <code>c pref list</code> to see a list of preferences you can check/change."
					break
				}
				$pref = ($command -split ' ')[2]
				$pref = set-alias ($pref)
				switch($pref) {
					"advmonthly" {
						if (($command -split ' ').Length -lt 4) {
							send-output -message "Your current monthly spending target is <code>$($prefs.value.advmonthly)</code> rupees."
							break
						}
						$newtgt = ($command -split ' ')[3]
						if ($newtgt -notmatch "^\d+$") {
							send-output -message "<code>${newtgt}</code>: not a number."
							break
						}
						$prefs.value.advmonthly = $newtgt
						send-output -message "Set monthly spending target to $($prefs.value.advmonthly)."
						break
					}
					"webbg" {
						if (($command -split ' ').Length -lt 4) {
							send-output -message "Your current background is set to <code>$($prefs.value.webbg)</code>."
							break
						}
						$newbg = ($command -split ' ')[3]
						if (-not(Test-Path("${PSScriptRoot}\..\bg\${newbg}")) -and $newbg -ne "none") {
							Send-Output -message "${newbg} was not found in the bg folder. Place it there first and then run this command."
						}
						$prefs.value.webbg = $newbg
						Send-Output -message "Successfully set background to $($prefs.value.webbg)."
						break
					}
					"list" {
						send-output -message $pref_list
					}
					Default { send-output -message "unrecognised preference." }
				}
				break
			}
			"insert" {
				# c insert [date] [time] [amount] [reason]
				if (($command -split ' ').Length -lt 6) {
					send-output -message "insert statement incomplete. Use the following syntax:`n<code>c insert [date] [time] [amount] [reason]</code>"
					break
				}
				[string]$dts = Parse-Date -sdate ($command -split ' ')[2] -stime ($command -split ' ')[3]
				#$dts

				#amount
				$amt = ($command -split ' ')[4]
				if (-not(isNumber(${amt}))) {
					send-output -message "${amt}: not a number."
					break
				}

				#reason
				$reason = ($command -split ' ')[5]
				if (($command -split ' ').Length -gt 6) {
					for ($i = 6; $i -lt ($command -split ' ').Length; $i++) {
						$reason += ' '
						$reason += ($command -split ' ')[$i]
					}
				}

				#add expense
				$newexpense = @{
					Amount  = $amt
					Expense = $reason
					Date    = $(Get-Date $dts -UFormat %s)
					Metric1 = 0
					Mertic2 = 0
					Metric3 = 0
				}
				#send-msg -message $($newexpense | ConvertTo-Json)
				#send-msg -message $(get-date ($dts) | Out-String)

				send-output -message "Inserted ${amt} of expenses for $((get-date ($dts)).AddMinutes(330).tostring("dddd, MMMM dd, yyyy, HH:mm:ss")) (UTC)."
				$expenses.value += $newexpense
				break
			}
			"help" {
				send-output $helpmsg
				break
			}
			Default { send-output -message "unrecognised command." }
		}
	}
}



### ------------------------------
### END
### ------------------------------