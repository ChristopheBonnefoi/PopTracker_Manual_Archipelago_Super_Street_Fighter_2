-- this is an example/ default implementation for AP autotracking
-- it will use the mappings defined in item_mapping.lua and location_mapping.lua to track items and locations via thier ids
-- it will also load the AP slot data in the global SLOT_DATA, keep track of the current index of on_item messages in CUR_INDEX
-- addition it will keep track of what items are local items and which one are remote using the globals LOCAL_ITEMS and GLOBAL_ITEMS
-- this is useful since remote items will not reset but local items might
ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")

CUR_INDEX = -1
SLOT_DATA = nil
LOCAL_ITEMS = {}
GLOBAL_ITEMS = {}
IS_AP_LOCATION_SYNCING = false
RECEIVED_ITEM_COUNTS = {}
RECEIVED_ITEM_INDEXES = {}
CONSUMABLE_MAX_COUNTS = {
    ["Shadaloo Emblem"] = 100
}

function resetConsumable(obj)
    obj.AcquiredCount = 0
end

function addConsumable(obj, code, index, item_id, item_name, player_number)
    RECEIVED_ITEM_INDEXES[code] = RECEIVED_ITEM_INDEXES[code] or {}
    if RECEIVED_ITEM_INDEXES[code][index] then
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format(
                "duplicate consumable ignored: code=%s index=%s item_id=%s item_name=%s player=%s total=%s",
                tostring(code),
                tostring(index),
                tostring(item_id),
                tostring(item_name),
                tostring(player_number),
                tostring(RECEIVED_ITEM_COUNTS[code] or 0)
            ))
        end
        return
    end
    RECEIVED_ITEM_INDEXES[code][index] = true

    local increment = obj.Increment or 1
    local max_count = CONSUMABLE_MAX_COUNTS[code]
    local current = RECEIVED_ITEM_COUNTS[code] or 0

    RECEIVED_ITEM_COUNTS[code] = current + increment
    if max_count and RECEIVED_ITEM_COUNTS[code] > max_count then
        RECEIVED_ITEM_COUNTS[code] = max_count
    end
    obj.AcquiredCount = RECEIVED_ITEM_COUNTS[code]

    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format(
            "consumable counted: code=%s index=%s item_id=%s item_name=%s player=%s total=%s",
            tostring(code),
            tostring(index),
            tostring(item_id),
            tostring(item_name),
            tostring(player_number),
            tostring(obj.AcquiredCount)
        ))
    end
end

function getItemMapping(item_id, item_name)
    if item_name == "Shadaloo Emblem" then
        return {"Shadaloo Emblem", "consumable"}
    end

    local v = ITEM_MAPPING[item_id]
    if v and v[1] then
        if not item_name or item_name == v[1] then
            return v
        end
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format(
                "item id/name mismatch ignored: item_id=%s mapped_code=%s item_name=%s",
                tostring(item_id),
                tostring(v[1]),
                tostring(item_name)
            ))
        end
        v = nil
    end

    if item_name then
        local obj = Tracker:FindObjectForCode(item_name)
        if obj then
            local item_type = obj.Type or "toggle"
            if item_type == "consumable" then
                return {item_name, "consumable"}
            end
            return {item_name, "toggle"}
        end
    end

    return v
end

function onClear(slot_data)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onClear, slot_data:\n%s", dump_table(slot_data)))
    end
    SLOT_DATA = slot_data
    CUR_INDEX = -1
    -- reset locations
    IS_AP_LOCATION_SYNCING = true
    for _, v in pairs(LOCATION_MAPPING) do
        if v[1] then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing location %s", v[1]))
            end
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[1]:sub(1, 1) == "@" then
                    obj.AvailableChestCount = obj.ChestCount
                else
                    obj.Active = false
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
            end
        end
    end
    IS_AP_LOCATION_SYNCING = false
    -- reset items
    for _, v in pairs(ITEM_MAPPING) do
        if v[1] and v[2] then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing item %s of type %s", v[1], v[2]))
            end
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[2] == "toggle" then
                    obj.Active = false
                elseif v[2] == "progressive" then
                    obj.CurrentStage = 0
                    obj.Active = false
                elseif v[2] == "consumable" then
                    resetConsumable(obj)
                elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print(string.format("onClear: unknown item type %s for code %s", v[2], v[1]))
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
            end
        end
    end
    local ap_connected = Tracker:FindObjectForCode("AP Connected")
    if ap_connected then
        ap_connected.Active = true
    end

    LOCAL_ITEMS = {}
    GLOBAL_ITEMS = {}
    RECEIVED_ITEM_COUNTS = {}
    RECEIVED_ITEM_INDEXES = {}
    -- manually run snes interface functions after onClear in case we are already ingame
    if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
        -- add snes interface functions here
    end
end

-- called when an item gets collected
function onItem(index, item_id, item_name, player_number)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onItem: %s, %s, %s, %s, %s", index, item_id, item_name, player_number, CUR_INDEX))
    end
    if not AUTOTRACKER_ENABLE_ITEM_TRACKING then
        return
    end
    if index <= CUR_INDEX then
        return
    end
    local is_local = player_number == Archipelago.PlayerNumber
    CUR_INDEX = index;
    local v = getItemMapping(item_id, item_name)
    if not v then
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: could not find item mapping for id %s", item_id))
        end
        return
    end
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: code: %s, type %s", tostring(v[1]), tostring(v[2])))
    end
    if not v[1] then
        return
    end
    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        if v[2] == "toggle" then
            obj.Active = true
        elseif v[2] == "progressive" then
            if obj.Active then
                obj.CurrentStage = obj.CurrentStage + 1
            else
                obj.Active = true
            end
        elseif v[2] == "consumable" then
            addConsumable(obj, v[1], index, item_id, item_name, player_number)
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: unknown item type %s for code %s", v[2], v[1]))
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: could not find object for code %s", v[1]))
    end
    -- track local items via snes interface
    if is_local then
        if LOCAL_ITEMS[v[1]] then
            LOCAL_ITEMS[v[1]] = LOCAL_ITEMS[v[1]] + 1
        else
            LOCAL_ITEMS[v[1]] = 1
        end
    else
        if GLOBAL_ITEMS[v[1]] then
            GLOBAL_ITEMS[v[1]] = GLOBAL_ITEMS[v[1]] + 1
        else
            GLOBAL_ITEMS[v[1]] = 1
        end
    end
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("local items: %s", dump_table(LOCAL_ITEMS)))
        print(string.format("global items: %s", dump_table(GLOBAL_ITEMS)))
    end
    if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
        -- add snes interface functions here for local item tracking
    end
end

-- called when a location gets cleared
function onLocation(location_id, location_name)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onLocation: %s, %s", location_id, location_name))
    end
    if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
        return
    end
    local v = LOCATION_MAPPING[location_id]
    if not v and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find location mapping for id %s", location_id))
    end
    if not v or not v[1] then
        return
    end
    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        IS_AP_LOCATION_SYNCING = true
        if v[1]:sub(1, 1) == "@" then
            obj.AvailableChestCount = math.max(0, obj.AvailableChestCount - 1)
        else
            obj.Active = true
        end
        IS_AP_LOCATION_SYNCING = false
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find object for code %s", v[1]))
    end
end

-- called when a manual location gets clicked in PopTracker
function onLocationSectionChanged(section)
    if IS_AP_LOCATION_SYNCING or not AUTOTRACKER_ENABLE_LOCATION_CHECKING then
        return
    end
    if not Archipelago or not Archipelago.PlayerNumber then
        return
    end
    if not section or not section.FullID then
        return
    end
    if section.AvailableChestCount and section.AvailableChestCount > 0 then
        return
    end

    local location_id = LOCATION_ID_BY_CODE[section.FullID]
    if not location_id then
        location_id = LOCATION_ID_BY_CODE["@" .. section.FullID]
    end
    if not location_id then
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onLocationSectionChanged: no AP id for %s", section.FullID))
        end
        return
    end

    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("sending manual AP check: %s -> %s", section.FullID, location_id))
    end
    Archipelago:LocationChecks({ location_id })
end

-- called when a locations is scouted
function onScout(location_id, location_name, item_id, item_name, item_player)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onScout: %s, %s, %s, %s, %s", location_id, location_name, item_id, item_name,
            item_player))
    end
    -- not implemented yet :(
end

-- called when a bounce message is received 
function onBounce(json)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onBounce: %s", dump_table(json)))
    end
    -- your code goes here
end

-- add AP callbacks
-- un-/comment as needed
Archipelago:AddClearHandler("clear handler", onClear)
if AUTOTRACKER_ENABLE_ITEM_TRACKING then
    Archipelago:AddItemHandler("item handler", onItem)
end
if AUTOTRACKER_ENABLE_LOCATION_TRACKING then
    Archipelago:AddLocationHandler("location handler", onLocation)
end
if AUTOTRACKER_ENABLE_LOCATION_CHECKING then
    ScriptHost:AddOnLocationSectionChangedHandler("manual location check handler", onLocationSectionChanged)
end
-- Archipelago:AddScoutHandler("scout handler", onScout)
-- Archipelago:AddBouncedHandler("bounce handler", onBounce)
