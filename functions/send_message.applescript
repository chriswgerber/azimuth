on run {targetBuddyPhone, targetMessage}
	tell application "Messages"
		set targetBuddy to buddy targetBuddyPhone of service "SMS"
		send targetMessage to targetBuddy
        close every window
	end tell
end run
