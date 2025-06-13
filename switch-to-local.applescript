#!/usr/bin/osascript

-- Load configuration from config.json file
on loadConfig()
    try
        -- Get the directory where this script is located
        set scriptPath to path to me as string
        tell application "System Events"
            set scriptFolder to container of file scriptPath
            set configPath to POSIX path of (scriptFolder as string) & "config.json"
        end tell

        -- Read config values using simple text parsing
        set configContent to do shell script "cat '" & configPath & "'"

        -- Extract full URLs
        set productionURL to do shell script "echo '" & configContent & "' | grep '\"productionURL\"' | cut -d'\"' -f4"
        set localURL to do shell script "echo '" & configContent & "' | grep '\"localURL\"' | cut -d'\"' -f4"
        set debugModeStr to do shell script "echo '" & configContent & "' | grep '\"debugMode\"' | cut -d':' -f2 | tr -d ' ,}'"

        set debugMode to (debugModeStr is "true")

        return {productionURL:productionURL, localURL:localURL, debugMode:debugMode}
    on error
        -- Fallback to default values if config file doesn't exist or can't be read
        return {productionURL:"https://www.infotech.com", localURL:"http://127.0.0.1:9001", debugMode:false}
    end try
end loadConfig

-- Load configuration
set config to loadConfig()
set productionURL to productionURL of config
set localURL to localURL of config
set debugMode to debugMode of config

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch to Local Development
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔄
# @raycast.description Switches current Chrome tab from production to local development server
# @raycast.author Pablo Arias
# @raycast.authorURL https://github.com/parias_infotech

# Documentation:
# @raycast.packageName Development Tools

tell application "System Events"
    set frontApp to name of first application process whose frontmost is true
end tell

if frontApp is not "Google Chrome" then
    my showMessage("Please switch to Chrome first", "Switch to Local Development", debugMode)
    return
end if

tell application "Google Chrome"
    if (count of windows) = 0 then
        my showMessage("No Chrome windows open", "Switch to Local Development", debugMode)
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

    -- Check if the URL contains the production URL
    if currentURL does not contain productionURL then
        my showMessage("Current page is not on " & productionURL, "Switch to Local Development", debugMode)
        return
    end if

    -- Simple find and replace: production URL → local URL
    try
        set newURL to my replaceText(currentURL, productionURL, localURL)



        -- Navigate to the new URL
        set URL of currentTab to newURL

        if debugMode then
            my showMessage("Switched to local development server: " & newURL, "Switch to Local Development", debugMode)
        else
            my showMessage("Switched to local development server", "Switch to Local Development", debugMode)
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

-- Helper function to replace text
on replaceText(originalText, searchString, replacementString)
    set AppleScript's text item delimiters to searchString
    set textItems to text items of originalText
    set AppleScript's text item delimiters to replacementString
    set newText to textItems as string
    set AppleScript's text item delimiters to ""
    return newText
end replaceText
