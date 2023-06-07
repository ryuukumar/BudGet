
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

function save-log([string]$message) {
    $logpath = $prefs.logpath
    if (-not(test-path "$logpath")) {
        new-item "$logpath"
    }

    [string]$date = (get-date)
    $date = "[ " + $date + " ]: "
    $message = $date + $message
    add-content -path "$logpath" -value "$message"
}
function send-msg {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$message,
        [Parameter(Mandatory = $false)][ref]$prefs,
        [Parameter(Mandatory = $false)][bool]$isReply = $false,
        [Parameter(Mandatory = $false)][int]$replyID
    )
    BEGIN {}

    PROCESS {
        $replymsg = new-object psobject
        $replymsg | add-member -membertype noteproperty 'chat_id' -value "$($prefs.value.chat_id)"
        $replymsg | add-member -membertype noteproperty 'text' -value "${message}"
        $replymsg | add-member -membertype noteproperty 'parse_mode' -value "HTML"
        if ($isReply) { $replymsg | Add-Member -MemberType NoteProperty 'reply_to_message_id' -value $replyID }
        $response = Invoke-RestMethod -Method Post -Uri ($URL + '/sendMessage') -Body ([System.Text.Encoding]::UTF8.GetBytes($($replymsg | ConvertTo-Json))) -ContentType "application/json"
    }

    END {}
}

function isNumber([string]$num) {
    [double]$ret = 0
    if ([double]::TryParse($num, [ref]$ret)) { return $true }
    return $false
}



### ------------------------------
### END
### ------------------------------