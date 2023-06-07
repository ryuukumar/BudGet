
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


$helpmsg = "<b>BudGet v${VERSION}</b>`n`nCommands are used by typing the trigger word 'c', followed by the command (and optionally its parameters) like this:`n`n<code>c [command] ([options])</code>`n`nHere is the list of commands:`n`n<code>help</code> Display this message.`n<code>mode</code> Set verbose or silent mode.`n<code>del</code> Delete the expense this command is sent as a reply to.`n<code>insert</code> Insert an entry in a certain time."
$del_cantfindmsg = "<b>ERROR:</b> Couldn't find the message you intend to delete. Either it has been sent way too long ago, or you have deleted it.`nAs a bodge, you can try adding the negative of the amount as a new expense record. This may fuck up your present expense estimates."
$pref_list = "You can set these preferences:`n`n<code>advmonthly [number]</code> Your monthly spending target`n<code>webbg [file]</code> Background of the web UI."



### ------------------------------
### END
### ------------------------------