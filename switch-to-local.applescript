#!/usr/bin/osascript

-- DEBUG MODE: Set to true to show detailed dialog boxes, false for notifications only
property debugMode : false

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch to Local Development
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🔄
# @raycast.description Switches current Chrome tab from infotech.com to 127.0.0.1:9001
# @raycast.author Pablo Arias
# @raycast.authorURL https://github.com/parias_infotech

# Documentation:
# @raycast.packageName Development Tools

tell application "System Events"
    set frontApp to name of first application process whose frontmost is true
end tell

if frontApp is not "Google Chrome" then
    my showMessage("Please switch to Chrome first", "Switch to Local Development")
    return
end if

tell application "Google Chrome"
    if (count of windows) = 0 then
        my showMessage("No Chrome windows open", "Switch to Local Development")
        return
    end if

    -- Get the frontmost window and its active tab
    activate
    delay 0.1 -- Small delay to ensure Chrome is activated
    set currentWindow to front window
    set currentTab to active tab of currentWindow
    set currentURL to URL of currentTab

    -- Show debug info about window and tab
    if debugMode then
        set windowCount to count of windows
        set tabCount to count of tabs of currentWindow
        my showMessage("Windows: " & windowCount & ", Tabs in current window: " & tabCount & return & return & "Current URL: " & currentURL, "Debug Info")
    end if

    -- Check if the URL contains infotech.com
    if currentURL does not contain "infotech.com" then
        my showMessage("Current page is not on infotech.com", "Switch to Local Development")
        return
    end if

    -- Replace infotech.com with 127.0.0.1:9001 (handle both http and https)
    try
        set newURL to my replaceText(currentURL, "https://www.infotech.com", "http://127.0.0.1:9001")

        if debugMode then
            my showMessage("About to navigate to: " & newURL, "Debug Info")
        end if

        -- Navigate to the new URL
        set URL of currentTab to newURL

        if debugMode then
            my showMessage("Switched to local development server: " & newURL, "Switch to Local Development")
        else
            my showMessage("Switched to local development server", "Switch to Local Development")
        end if

    on error errorMessage number errorNumber
        my showMessage("Error occurred: " & errorMessage & " (Error " & errorNumber & ")", "Script Error")
    end try
end tell

-- Helper function to show message based on debug mode
on showMessage(messageText, titleText)
    if debugMode then
        display dialog messageText with title titleText buttons {"OK"} default button "OK"
    else
        display notification messageText with title titleText
    end if
end showMessage

-- Helper function to replace text
on replaceText(originalText, searchString, replacementString)
    set AppleScript's text item delimiters to searchString
    set textItems to text items of originalText
    set AppleScript's text item delimiters to replacementString
    set newText to textItems as string
    set AppleScript's text item delimiters to ""
    return newText
end replaceText
