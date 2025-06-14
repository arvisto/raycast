#!/usr/bin/osascript

-- Load configuration from config.json file
on loadConfig()
    try
        -- Get script directory and config path
        set scriptPath to POSIX path of (path to me)
        set scriptDir to do shell script "dirname '" & scriptPath & "'"
        set configPath to scriptDir & "/config.json"

        -- Extract values using Python JSON parsing
        set defaultLocal to do shell script "python3 -c \"import json; data=json.load(open('" & configPath & "')); print(data['defaultLocal'])\""
        set defaultRemote to do shell script "python3 -c \"import json; data=json.load(open('" & configPath & "')); print(data['defaultRemote'])\""
        set localURL to do shell script "python3 -c \"import json; data=json.load(open('" & configPath & "')); print(data['servers'][data['defaultLocal']])\""
        set remoteURL to do shell script "python3 -c \"import json; data=json.load(open('" & configPath & "')); print(data['servers'][data['defaultRemote']])\""
        set debugModeStr to do shell script "python3 -c \"import json; data=json.load(open('" & configPath & "')); print(str(data['debugMode']).lower())\""

        set debugMode to (debugModeStr is "true")

        return {localURL:localURL, remoteURL:remoteURL, debugMode:debugMode, defaultLocal:defaultLocal, defaultRemote:defaultRemote}
    on error errorMsg
        error "Config file required - please check config.json exists and is properly formatted. Error: " & errorMsg
    end try
end loadConfig

-- Load configuration
set config to loadConfig()
set localURL to localURL of config
set remoteURL to remoteURL of config
set debugMode to debugMode of config
set defaultLocal to defaultLocal of config
set defaultRemote to defaultRemote of config

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Local Development
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔄
# @raycast.description Toggles current Chrome tab between local development server and default server
# @raycast.author Pablo Arias
# @raycast.authorURL https://github.com/parias_infotech

# Documentation:
# @raycast.packageName Development Tools

tell application "System Events"
    set frontApp to name of first application process whose frontmost is true
end tell

if frontApp is not "Google Chrome" then
    my showMessage("Please switch to Chrome first", "Toggle Local Development", debugMode)
    return
end if

tell application "Google Chrome"
    if (count of windows) = 0 then
        my showMessage("No Chrome windows open", "Toggle Local Development", debugMode)
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
        my showMessage("Windows: " & windowCount & ", Tabs in current window: " & tabCount & return & return & "Current URL: " & currentURL, "Debug Info", debugMode)
    end if

    -- Toggle between local and default server
    try
        -- Extract the base URL (protocol + domain) from current URL
        set currentBaseURL to my extractBaseURL(currentURL)

        -- Determine if current URL is local and toggle accordingly
        if my isLocalURL(currentBaseURL, localURL) then
            -- Currently on local, switch to remote server
            set newURL to my replaceText(currentURL, currentBaseURL, remoteURL)
            set toggleDirection to "remote server (" & defaultRemote & ")"
        else
            -- Currently on remote, switch to local
            set newURL to my replaceText(currentURL, currentBaseURL, localURL)
            set toggleDirection to "local server (" & defaultLocal & ")"
        end if

        -- Navigate to the new URL
        set URL of currentTab to newURL

        if debugMode then
            my showMessage("Toggled to " & toggleDirection & ": " & newURL, "Toggle Local Development", debugMode)
        else
            my showMessage("Toggled to " & toggleDirection, "Toggle Local Development", debugMode)
        end if

    on error errorMessage number errorNumber
        my showMessage("Error occurred: " & errorMessage & " (Error " & errorNumber & ")", "Script Error", debugMode)
    end try
end tell

-- Helper function to show message based on debug mode
on showMessage(messageText, titleText, isDebugMode)
    if isDebugMode then
        display dialog messageText with title titleText buttons {"OK"} default button "OK"
    else
        display notification messageText with title titleText
    end if
end showMessage

-- Helper function to extract base URL (protocol + domain) from a full URL
on extractBaseURL(fullURL)
    try
        -- Find the third slash (after protocol://)
        set slashCount to 0
        set urlLength to length of fullURL
        repeat with i from 1 to urlLength
            if character i of fullURL is "/" then
                set slashCount to slashCount + 1
                if slashCount is 3 then
                    return text 1 thru (i - 1) of fullURL
                end if
            end if
        end repeat
        -- If no third slash found, return the whole URL (might be just domain)
        return fullURL
    on error
        return fullURL
    end try
end extractBaseURL

-- Helper function to replace text
on replaceText(originalText, searchString, replacementString)
    set AppleScript's text item delimiters to searchString
    set textItems to text items of originalText
    set AppleScript's text item delimiters to replacementString
    set newText to textItems as string
    set AppleScript's text item delimiters to ""
    return newText
end replaceText

-- Helper function to determine if current URL is local
on isLocalURL(currentBaseURL, localURL)
    try
        set localBaseURL to my extractBaseURL(localURL)
        return (currentBaseURL is equal to localBaseURL)
    on error
        return false
    end try
end isLocalURL
