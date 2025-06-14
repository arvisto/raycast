#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch Server
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🌐
# @raycast.description Switches current Chrome tab to different servers
# @raycast.author Pablo Arias
# @raycast.authorURL https://github.com/parias_infotech

# Documentation:
# @raycast.packageName Development Tools
# @raycast.argument1 {"type": "text", "placeholder": "Server name", "optional": true}

-- Configuration: Set debug mode here
property debugMode : false

-- No default mappings - config file is required

-- Helper function to show messages
on showMessage(messageText, titleText, isDebug)
    if debugMode then
        display dialog messageText with title titleText buttons {"OK"} default button "OK"
    else
        if not isDebug then
            display notification messageText with title titleText
        end if
    end if
end showMessage

-- Load server mappings from config file
on loadServerMappings()
    try
        -- Get script directory and config path
        set scriptPath to POSIX path of (path to me)
        set scriptDir to do shell script "dirname '" & scriptPath & "'"
        set configPath to scriptDir & "/config.json"

        my showMessage("Loading config from: " & configPath, "Debug", true)

        -- Extract servers using Python JSON parsing (read file directly)
        set serversJSON to do shell script "python3 -c \"import json; data=json.load(open('" & configPath & "')); print('|'.join([k+'='+v for k,v in data['servers'].items()]))\""
        my showMessage("Config file read and parsed successfully", "Debug", true)
        my showMessage("Servers extracted: " & serversJSON, "Debug", true)

        -- Parse the pipe-separated key=value pairs into AppleScript record
        set serverList to {}
        set AppleScript's text item delimiters to "|"
        set serverPairs to text items of serversJSON
        set AppleScript's text item delimiters to "="

        repeat with serverPair in serverPairs
            set keyValue to text items of serverPair
            if (count of keyValue) = 2 then
                set serverKey to item 1 of keyValue
                set serverURL to item 2 of keyValue
                set serverList to serverList & {{serverKey, serverURL}}
            end if
        end repeat

        set AppleScript's text item delimiters to ""
        my showMessage("Loaded " & (count of serverList) & " servers from config", "Debug", true)
        return serverList

    on error errorMsg
        my showMessage("Config loading failed: " & errorMsg & ". Please check config.json exists and is properly formatted.", "Error", false)
        error "Config file required - no fallback available"
    end try
end loadServerMappings

-- Find server URL by key
on getServerURL(serverKey, serverMappings)
    repeat with serverPair in serverMappings
        if item 1 of serverPair is serverKey then
            my showMessage("Found server '" & serverKey & "' -> '" & (item 2 of serverPair) & "'", "Debug", true)
            return item 2 of serverPair
        end if
    end repeat

    -- Server not found, build available list
    set availableKeys to {}
    repeat with serverPair in serverMappings
        set availableKeys to availableKeys & {item 1 of serverPair}
    end repeat
    set AppleScript's text item delimiters to ", "
    set availableList to availableKeys as string
    set AppleScript's text item delimiters to ""

    error "Server '" & serverKey & "' not found. Available: " & availableList
end getServerURL

-- Extract base URL from full URL
on extractBaseURL(fullURL)
    try
        set slashCount to 0
        repeat with i from 1 to length of fullURL
            if character i of fullURL is "/" then
                set slashCount to slashCount + 1
                if slashCount is 3 then
                    return text 1 thru (i - 1) of fullURL
                end if
            end if
        end repeat
        return fullURL
    on error
        return fullURL
    end try
end extractBaseURL

-- Replace text helper
on replaceText(originalText, searchString, replacementString)
    set AppleScript's text item delimiters to searchString
    set textItems to text items of originalText
    set AppleScript's text item delimiters to replacementString
    set newText to textItems as string
    set AppleScript's text item delimiters to ""
    return newText
end replaceText

-- Main script
on run argv
    my showMessage("Script started", "Switch Server", true)

    -- Load server mappings
    set serverMappings to loadServerMappings()

    -- Get server key from argument or use default
    if (count of argv) > 0 and (item 1 of argv) is not "" then
        set serverKey to item 1 of argv
    else
        set serverKey to "prod"
    end if

    my showMessage("Using server key: '" & serverKey & "'", "Debug", true)

    -- Get target URL
    try
        set targetURL to getServerURL(serverKey, serverMappings)
    on error errorMsg
        my showMessage(errorMsg, "Error", false)
        return
    end try

    -- Check Chrome
    tell application "System Events"
        set frontApp to name of first application process whose frontmost is true
    end tell

    if frontApp is not "Google Chrome" then
        my showMessage("Please switch to Chrome first", "Switch Server", false)
        return
    end if

    -- Process Chrome tab
    tell application "Google Chrome"
        if (count of windows) = 0 then
            my showMessage("No Chrome windows open", "Switch Server", false)
            return
        end if

        activate
        delay 0.1
        set currentWindow to front window
        set currentTab to active tab of currentWindow
        set currentURL to URL of currentTab

        my showMessage("Current URL: " & currentURL, "Debug", true)

        -- Extract base URL and replace
        set currentBaseURL to my extractBaseURL(currentURL)
        set newURL to my replaceText(currentURL, currentBaseURL, targetURL)

        my showMessage("Replacing '" & currentBaseURL & "' with '" & targetURL & "'", "Debug", true)
        my showMessage("New URL: " & newURL, "Debug", true)

        -- Navigate
        set URL of currentTab to newURL
        my showMessage("Switched to " & serverKey & " server", "Switch Server", false)
    end tell
end run
