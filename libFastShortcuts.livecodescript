script "libFastShortcuts"

local sShortcutsArray,  sKeysMapping,  sKeysDownName, sValidateShortcut
# This command is used to establish an action when we have a combination of keys pressed.
# The parameters are:
# 1: the combination of keys pressed.
# 2: The message that will be sent when these keys are pressed.
# 3: The parameters it will send. (Optional)
# 4: The object to which this message will be sent. (Optional) -> if it doesn't come it will fire as messages for all objects in the message flow)

command newShortcut pKeysDown, pMessageSend, pParams ,pTarget
    if _validateKeymap(pKeysDown)  then
        answer error "Invalid key combination."
        exit newShortcut
    end if

    if pKeysDown is among the keys of sShortcutsArray then
        answer question "This combination is already in use. Do you want to replace it?" with "No" or "Yes"
        if it is not "Yes" then
            exit newShortcut
        end if
    end if

    if pMessageSend is empty then
        answer error "You must spacify the callback message."
        exit newShortcut
    end if

    replace space with empty in pKeysDown
    put pMessageSend into sShortcutsArray[ pKeysDown ]["messageSend"]
    if pParams is not empty then put pParams into sShortcutsArray[ pKeysDown ]["params"]
    if pTarget is not empty then put pTarget into sShortcutsArray[ pKeysDown ]["target"]
end newShortcut


command removeShortcut pKeysDown
    delete variable sShortcutsArray[ pKeysDown ]
end removeShortcut

command updateShortcut pNewKeymap, pOldKeymap
    if pNewKeymap is empty then
        answer error "You must especify the new shortcut."
        exit updateShortcut
    end if

    if sShortcutsArray[ pOldKeymap ] is not an array then
        answer error "The shortcut you are attempting to update does not exists."
        exit updateShortcut
    end if

    put sShortcutsArray[ pOldKeymap ] into sShortcutsArray[ pNewKeymap ]
end updateShortcut


# This function is to get the current Shortcuts configuration
# to save it in the configuration or somewhere to use this later.
function getShortcuts pFormat
    return sShortcutsArray
end getShortcuts


# What this command does is load the configuration that we saved with the previous function.
command loadShortcuts pShortcutsArray
    if pShortcutsArray is an array then
        delete variable sShortcutsArray
        put pShortcutsArray into sShortcutsArray
    end if
end loadShortcuts


on rawKeyDown
    local tKeysDown

    put the keysDown into tKeysDown
    put _keysDownNames( tKeysDown ) into sKeysDownName

    send "sendMessageShortcuts tKeysDown" to me in 0 sec
    pass rawKeyDown
end rawKeyDown

function keysDownNames
    return sKeysDownName
end keysDownNames

private function _keysDownNames pKeysDown
    local tMapping, tKey

    _keysMapping

    repeat for each item i in pKeysDown
        if i < 127 and i <> 0 then
            put toUpper( numToNativeChar( i )) & "," after tMapping
        else
            if sKeysMapping[ i ] is empty then
                exit to top
            end if
            put toUpper(char 1 of sKeysMapping[ i ] ) & char 2 to - 1 of sKeysMapping[ i ] & "," after tMapping
        end if
    end repeat

    replace "+" with "plus" in tMapping
    replace "," with "+" in tMapping

    delete last char of word 1 to -1 of tMapping
    return tMapping
end _keysDownNames


on sendMessageShortcuts pKeysDown
    if sShortcutsArray[pKeysDown]["messageSend"] is empty then exit sendMessageShortcuts

    if sShortcutsArray[pKeysDown]["target"] is not empty  then
        if there is a sShortcutsArray[pKeysDown]["target"] then
            dispatch (sShortcutsArray[pKeysDown]["messageSend"]) to sShortcutsArray[pKeysDown]["target"] with sShortcutsArray[pKeysDown]["params"]
        end if
    else
        dispatch (sShortcutsArray[pKeysDown]["messageSend"]) with sShortcutsArray[pKeysDown]["params"]
    end if
end sendMessageShortcuts


private command _keysMapping
    if sKeysMapping is not an array or sValidateShortcut is not an array then
        put "esc" into sKeysMapping[ 65307 ]
        put "tab" into sKeysMapping[ 65289 ]
        put "caps lock" into sKeysMapping[ 65509 ]
        put "ctrl" into sKeysMapping[ 65507 ]
        put "shift"  into sKeysMapping[ 65505 ]
        put "f1"  into sKeysMapping[ 65470 ]
        put "f2"  into sKeysMapping[ 65471 ]
        put "f3"  into sKeysMapping[ 65472 ]
        put "f4"  into sKeysMapping[ 65473 ]
        put "f5"  into sKeysMapping[ 65474 ]
        put "f6"  into sKeysMapping[ 65475 ]
        put "f7"  into sKeysMapping[ 65476 ]
        put "f8"  into sKeysMapping[ 65477 ]
        put "f9"  into sKeysMapping[ 65478 ]
        put "f10"  into sKeysMapping[ 65479 ]
        put "f11"  into sKeysMapping[ 65480 ]
        put "f11"  into sKeysMapping[ 65481 ]
        put "backspace" into sKeysMapping[ 65288 ]
        put "delete" into sKeysMapping[ 65535 ]
        put "return" into sKeysMapping[ 65293 ]
        put "enter" into sKeysMapping[ 65421 ]
        put "prt sc" into sKeysMapping[ 65377 ]
        put "page up" into sKeysMapping[ 65365 ]
        put "page down" into sKeysMapping[ 65366 ]
        put "insert" into sKeysMapping[ 65379 ]
        put "arrow up" into sKeysMapping[ 65362 ]
        put "arrow down" into sKeysMapping[ 65364 ]
        put "arrow left" into sKeysMapping[ 65361 ]
        put "arrow right" into sKeysMapping[ 65363 ]
        put "num dot" into sKeysMapping[ 65454 ]
        put "num delete" into sKeysMapping[ 65439 ]
        if platform() is "MacOS" then
            put "Option" into sKeysMapping[ 65513 ]
        else
            put "alt" into sKeysMapping[ 65513 ]
        end if

        repeat for each key k in sKeysMapping
            put k into sValidateShortcut[ sKeysMapping[k] ]
        end repeat
    end if
end _keysMapping


private function _validateKeymap pValue
    replace "+" with comma in pValue
    replace "?" with "\?" in pValue

    _keysMapping

    repeat for each item i in pValue
        put word 1 to - 1 of  i into i
        if i is not among keys of sValidateShortcut and i is not "\?" then
            try
                if NativeChartoNum(i) is not an integer then
                    return false
                end if
            catch e
                return false
            end try
        end if
    end repeat
    return true
end _validateKeymap

