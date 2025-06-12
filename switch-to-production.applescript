#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch to Production
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🌐
# @raycast.description Switches current Chrome tab from 127.0.0.1:9001 to infotech.com
# @raycast.author Pablo Arias
# @raycast.authorURL https://github.com/parias_infotech

# Documentation:
# @raycast.packageName Development Tools

tell application "System Events"
    set frontApp to name of first application process whose frontmost is true
end tell

if frontApp is not "Google Chrome" then
    display notification "Please switch to Chrome first" with title "Switch to Production"
    return
end if

tell application "Google Chrome"
    if (count of windows) = 0 then
        display notification "No Chrome windows open" with title "Switch to Production"
        return
    end if
    
    set currentTab to active tab of first window
    set currentURL to URL of currentTab
    
    # Check if the URL contains 127.0.0.1:9001
    if currentURL does not contain "127.0.0.1:9001" then
        display notification "Current page is not on local development server" with title "Switch to Production"
        return
    end if
    
    # Replace 127.0.0.1:9001 with infotech.com
    set newURL to my replaceText(currentURL, "127.0.0.1:9001", "infotech.com")
    
    # Navigate to the new URL
    set URL of currentTab to newURL
    
    display notification "Switched to production server" with title "Switch to Production"
end tell

# Helper function to replace text
on replaceText(originalText, searchString, replacementString)
    set AppleScript's text item delimiters to searchString
    set textItems to text items of originalText
    set AppleScript's text item delimiters to replacementString
    set newText to textItems as string
    set AppleScript's text item delimiters to ""
    return newText
end replaceText
