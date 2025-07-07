--[[ Lua code. See documentation: https://api.tabletopsimulator.com/ --]]

-- Having all these GUIDs centrally managed helps to ensure that any changes to
-- them only need to be made in one place, and hard-to-find stuff isn't inadvertently
-- broken.
--
-- If you're looking at this and thinking "surely this should be a table" - why,
-- yes it should. Unfortunately, I saw the documentation for Object.getVar said
-- "Cannot return a table", and missed that Object.getTable existed, and now I'm
-- too lazy to change it all again.
centerCircle_GUID = "51ee2f"
quarterCircle_GUID = "51ee3f"
templateObjective_GUID = "573333"
startMenu_GUID = "738804"
redDiceMat_GUID = "c57d70"
blueDiceMat_GUID = "a84ed2"
redDiceRoller_GUID = "beae28"
blueDiceRoller_GUID = "4e0e0b"
redMissionManager_GUID = "cff35b"
blueMissionManager_GUID = "471de1"
redVPCounter_GUID = "8b0541"
blueVPCounter_GUID = "a77a54"
redCPCounter_GUID = "e446f7"
blueCPCounter_GUID = "deb9f2"
redTurnCounter_GUID = "055302"
blueTurnCounter_GUID = "7e4111"
gameTurnCounter_GUID = "ee92cf"
scoresheet_GUID = "06d627"
blankObjCard_GUID = "d618cb"
activation_GUID = "229946"
wounds_GUID = "ad63ba"

table_GUID = "948ce5"
felt_GUID = "28865a"
mat_GUID = "4ee1f2"
matURLDisplay_GUID = "c5e288"
flexControl_GUID = "bd69bd"
tableLeg1_GUID = "afc863"
tableLeg2_GUID = "c8edca"
tableLeg3_GUID = "393bf7"
tableLeg4_GUID = "12c65e"
tableSideBottom_GUID = "f938a2"
tableSideTop_GUID = "35b95f"
tableSideLeft_GUID = "9f95fd"
tableSideRight_GUID = "5af8f2"
extractTerrain_GUID = "70b9f6"

redHandZone_GUID = "f7d85a"
blueHandZone_GUID = "731345"
redHiddenZone_GUID = "28419e"
blueHiddenZone_GUID = "e1e91a"
deploymentCardZone_GUID = "dcf95b"
missionCardZone_GUID = "cdecf2"
primaryCardZone_GUID = "740abc"
secondary11CardZone_GUID = "0ec215"
secondary12CardZone_GUID = "d865d4"
secondary21CardZone_GUID = "3c8d71"
secondary22CardZone_GUID = "88cac4"

CPMissionBook_GUID = "731ec4"

local spawnedDiceObjects = {}

--[[
GUID reference for primary / mission / deployment cards
Yeah, I could use variables but I didn't, oh well

Leviathan:
----------

Sites of Power ec78cd
Scorched Earth 3ad5a3
Purge the Foe 5444d4
Priority Targets f97708
Deploy Servo-Skulls 44ff29
Take and Hold 884291
Supply Drop a34ae1
The Ritual 646b49
Vital Ground 6fc1c2

Chilling Rain db0022
Hidden Supplies 0dc3c3
Scrambler Fields aea986
Chosen Battlefield 876ac7

Hammer and Anvil 117c77
Dawn of War 7e4b95
Sweeping Engagement 381d7c
Search and Destroy ad4220
Crucible of Battle 3c0679

Pariah Nexus:
-------------

Burden of Trust 85718e
Linchpin 540fd0
Purge the Foe d9d35a
Scorched Earth 6860de
Supply Drop 981226
Take and Hold bffd57
Terraform 7fa6d0
The Ritual 7067e2
Unexploded Ordnance 41f293

Adapt or Die 9650f1
Fog of War c58f11
Hidden Supplies c4fe8c
Inspired Leadership 499169
Prepared Positions 9789b7
Raise Banners 62e744
Rapid Escalation d35008
Smoke and Mirrors 25b5a6
Stalwarts 8b7dbc
Swift Action dc273c

Crucible of Battle e96d18
Dawn of War 7f45dc
Hammer and Anvil 97f3f0
Search and Destroy 09c961
Sweeping Engagement c6edf3
Tipping Point 77cde6

]]--


MISSION_PACK_LEVIATHAN = 1
MISSION_PACK_PARIAH_NEXUS = 2
packSelected = nil
missionPackData = {
    {
        id = MISSION_PACK_LEVIATHAN,
        name = "Leviathan",
        deploymentDeck_GUID = "a30deb",
        missionDeck_GUID = "1665ca",
        primaryDeck_GUID = "3ca4a6",
        gambitDeck_GUID = "d0a9f9",
        fixedSecondaryDeck_GUID = "30c8fe",
        redSecondaryDeck_GUID = "2c6243",
        blueSecondaryDeck_GUID = nil,
        tournamentMissions = {
            -- Take and Hold / Chilling Rain / Search and Destroy
            {name = "A", primary = "884291", mission = "db0022", deployment = "ad4220"},
            -- Priority Targets / Hidden Supplies / Search and Destroy
            {name = "B", primary = "f97708", mission = "0dc3c3", deployment = "ad4220"},
            -- The Ritual / Scrambler Fields / Sweeping Engagement
            {name = "C", primary = "646b49", mission = "aea986", deployment = "381d7c"},
            -- Deploy Servo-skulls / Chilling Rain / Search and Destroy
            {name = "D", primary = "44ff29", mission = "db0022", deployment = "ad4220"},
            -- Take and Hold / Chosen Battlefield / Sweeping Engagement
            {name = "E", primary = "884291", mission = "876ac7", deployment = "381d7c"},
            -- Supply Drop / Chilling Rain / Search and Destroy
            {name = "F", primary = "a34ae1", mission = "db0022", deployment = "ad4220"},
            -- Sites of Power / Chilling Rain / Hammer and Anvil
            {name = "G", primary = "ec78cd", mission = "db0022", deployment = "117c77"},
            -- The Ritual / Chilling Rain / Hammer and Anvil
            {name = "H", primary = "646b49", mission = "db0022", deployment = "117c77"},
            -- Take and Hold / Hidden Supplies / Hammer and Anvil
            {name = "I", primary = "884291", mission = "0dc3c3", deployment = "117c77"},
            -- Priority Targets / Chilling Rain / Crucible of Battle
            {name = "J", primary = "f97708", mission = "db0022", deployment = "3c0679"},
            -- Deploy Servo-skulls / Hidden Supplies / Crucible of Battle
            {name = "K", primary = "44ff29", mission = "0dc3c3", deployment = "3c0679"},
            -- Scorched Earth / Chilling Rain / Dawn of War
            {name = "L", primary = "3ad5a3", mission = "db0022", deployment = "7e4b95"},
            -- Purge the Foe / Chilling Rain / Crucible of Battle
            {name = "M", primary = "5444d4", mission = "db0022", deployment = "3c0679"},
            -- Priority Targets / Chosen Battlefield / Dawn of War
            {name = "N", primary = "f97708", mission = "876ac7", deployment = "7e4b95"},
            -- Vital Ground / Chilling Rain / Crucible of Battle
            {name = "O", primary = "6fc1c2", mission = "db0022", deployment = "3c0679"}
        }
    },
    {
        id = MISSION_PACK_PARIAH_NEXUS,
        name = "Pariah Nexus",
        deploymentDeck_GUID = "2dc2e8",
        missionDeck_GUID = "ffdf05",
        primaryDeck_GUID = "d26e9c",
        gambitDeck_GUID = "79d2ae",
        fixedSecondaryDeck_GUID = "b55459",
        redSecondaryDeck_GUID = "c0fb49",
        blueSecondaryDeck_GUID = nil,
        tournamentMissions = {
            -- A: Take and Hold / Raise Banners / Tipping Point
            {name = "A", primary = "bffd57", mission = "62e744", deployment = "77cde6"},
            -- B: Purge the Foe / Smoke and Mirrors / Tipping Point
            {name = "B", primary = "d9d35a", mission = "25b5a6", deployment = "77cde6"},
            -- C: Linchpin / Fog of War / Tipping Point
            {name = "C", primary = "540fd0", mission = "c58f11", deployment = "77cde6"},
            -- D: Scorched Earth / Swift Action / Tipping Point
            {name = "D", primary = "6860de", mission = "dc273c", deployment = "77cde6"},
            -- E: Take and Hold / Prepared Positions / Hammer and Anvil
            {name = "E", primary = "bffd57", mission = "9789b7", deployment = "97f3f0"},
            -- F: Burden of Trust / Hidden Supplies / Hammer and Anvil
            {name = "F", primary = "85718e", mission = "c4fe8c", deployment = "97f3f0"},
            -- G: The Ritual / Stalwarts / Hammer and Anvil
            {name = "G", primary = "7067e2", mission = "8b7dbc", deployment = "97f3f0"},
            -- H: Supply Drop / Smoke and Mirrors / Hammer and Anvil
            {name = "H", primary = "981226", mission = "25b5a6", deployment = "97f3f0"},
            -- I: Burden of Trust / Prepared Positions / Search and Destroy
            {name = "I", primary = "85718e", mission = "9789b7", deployment = "09c961"},
            -- J: Linchpin / Raise Banners / Search and Destroy
            {name = "J", primary = "540fd0", mission = "62e744", deployment = "09c961"},
            -- K: Scorched Earth / Stalwarts / Search and Destroy
            {name = "K", primary = "6860de", mission = "8b7dbc", deployment = "09c961"},
            -- L: Take and Hold / Hidden Supplies / Search and Destroy
            {name = "L", primary = "bffd57", mission = "c4fe8c", deployment = "09c961"},
            -- M: Purge the Foe / Rapid Escalation / Crucible of Battle
            {name = "M", primary = "d9d35a", mission = "d35008", deployment = "e96d18"},
            -- N: The Ritual / Swift Action / Crucible of Battle
            {name = "N", primary = "7067e2", mission = "dc273c", deployment = "e96d18"},
            -- O: Terraform / Stalwarts / Crucible of Battle
            {name = "O", primary = "7fa6d0", mission = "8b7dbc", deployment = "e96d18"},
            -- P: Scorched Earth / Inspired Leadership / Crucible of Battle
            {name = "P", primary = "6860de", mission = "499169", deployment = "e96d18"},
            -- Q: Supply Drop / Rapid Escalation / Sweeping Engagement
            {name = "Q", primary = "981226", mission = "d35008", deployment = "c6edf3"},
            -- R: Terraform / Swift Action / Sweeping Engagement
            {name = "R", primary = "7fa6d0", mission = "dc273c", deployment = "c6edf3"},
            -- S: Linchpin / Raise Banners / Dawn of War
            {name = "S", primary = "540fd0", mission = "62e744", deployment = "7f45dc"},
            -- T: Unexploded Ordnance / Inspired Leadership / Dawn of War
            {name = "T", primary = "41f293", mission = "499169", deployment = "7f45dc"}
        }
    },
}

turnOrder = {}
nonPlaying = {"White", "Brown","Orange","Yellow","Green","Teal","Purple","Pink"}
allowMenu = true
allowAutoSeat = true
redPlayerID = ""
bluePlayerID = ""

-- Grid layout for each player
PLAYER_GRID_SPAWN = {
    Red = {
        origin = {x = 18.93, y = 1.28, z = 42.30},
        right = {-1, 0}, -- negative X
        down = {0, 1},   -- positive Z
    },
    Blue = {
        origin = {x = -19.16, y = 1.28, z = -42.63},
        right = {1, 0},  -- positive X
        down = {0, -1},  -- negative Z
    }
}

-- Grid layout for each player
PLAYER_GRID_SPAWN = {
    Red = {
        origin = {x = 18.93, y = 1.28, z = 42.30},
        right = {-1, 0}, -- negative X
        down = {0, 1},   -- positive Z
    },
    Blue = {
        origin = {x = -19.16, y = 1.28, z = -42.63},
        right = {1, 0},  -- positive X
        down = {0, -1},  -- negative Z
    }
}

function onChat(message, player)
    local color = player.color
    
    if message == "!shoot" then
        local descs = getSelectedDescriptions(color)
        local fullText = table.concat(descs, "\n---\n")
        printToColor("Full concatenated description block:\n" .. fullText, color, {1, 1, 0.6})
        log("[" .. player.steam_name .. "]: " .. fullText)
        local weapons = parseWeaponsByModel(descs, "Ranged")
        local grouped = groupWeapons(weapons, "bs")
        spawnWeaponDice(color, grouped)
    elseif message == "!attack" then
        local descs = getSelectedDescriptions(color)
        local fullText = table.concat(descs, "\n---\n")
        printToColor("Full concatenated description block:\n" .. fullText, color, {1, 1, 0.6})
        log("[" .. player.steam_name .. "]: " .. fullText)
        local weapons = parseWeaponsByModel(descs, "Melee")
        local grouped = groupWeapons(weapons, "ws")
        spawnWeaponDice(color, grouped)
    end
    if message:lower() == "!drawlos" then
        drawAllLOSCornerBoxes()
        printToColor("LOS debug boxes drawn.", player.color, {1, 0.8, 0})
        return false -- suppress message from chat log if desired
    end

end

local function extractStatBlock(stats)
    local out = {
        a = 0,
        hit = nil,
        s = 0,
        ap = 0,
        d = 1,
    }

    for token in stats:gmatch("[^%s]+") do
        local key, value = token:match("([A-Z]+):([%-%+%d]+)")
        if key and value then
            if key == "A" then
                out.a = tonumber(value)
            elseif key == "BS" or key == "WS" then
                out.hit = value
            elseif key == "S" then
                out.s = tonumber(value)
            elseif key == "AP" then
                out.ap = tonumber(value)
            elseif key == "D" then
                out.d = tonumber(value)
            end
        end
    end

    return out
end


function getSelectedDescriptions(color)
    local out = {}
    for _, obj in ipairs(Player[color].getSelectedObjects()) do
        local desc = obj.getDescription()
        table.insert(out, desc)
        printToColor("Selected object description:\n" .. desc, color, {0.8, 0.8, 0.8})
    end
    return out
end

function parseWeaponsByModel(objects, requestedType)
    local result = {}

    for _, obj in ipairs(objects) do
        local desc = obj.getDescription()
        local lines = {}
        for line in string.gmatch(desc, "[^\r\n]+") do
            local clean = line:gsub("%b[]", ""):gsub("^%s+", ""):gsub("%s+$", "")
            if clean ~= "" then table.insert(lines, clean) end
        end

        local i = 1
        while i <= #lines do
            local line = lines[i]
            local isRanged = line:match("^%d+%s*\"%s*A:%d+")
            local isMelee = not isRanged and line:match("^A:%d+")

            if (isRanged and requestedType == "Ranged") or (isMelee and requestedType == "Melee") then
                -- Look upward for the weapon name
                local name = "Unknown"
                for j = i - 1, 1, -1 do
                    local prior = lines[j]
                    if not prior:match("^%d+%s*\"%s*A:%d+") and not prior:match("^A:%d+") then
                        name = prior
                        break
                    end
                end

                local stats = extractStatBlock(line)
                local range = isRanged and line:match("^(%d+)%s*\"") or nil

                local abilities = {}
                for tag in line:gmatch("%[(.-)%]") do
                    if not tag:match("^[0-9a-fA-F]+$") and tag ~= "-" then
                        for ability in tag:gmatch("[^,]+") do
                            table.insert(abilities, ability:match("^%s*(.-)%s*$"))
                        end
                    end
                end

                result[obj] = result[obj] or {}
                table.insert(result[obj], {
                    name = name,
                    a = stats.a or 1,
                    hit = stats.hit,
                    s = stats.s or 0,
                    ap = stats.ap or 0,
                    d = stats.d or 1,
                    range = range,
                    abilities = table.concat(abilities, ", ")
                })
            end

            i = i + 1
        end
    end

    return result
end





function groupWeaponsByModel(weaponsByModel, hitKey)
    local groups = {}

    for model, weaponList in pairs(weaponsByModel) do
        for _, w in ipairs(weaponList) do
            local key = string.format("%s::A:%d::%s:%s::S:%d::AP:%d::D:%d::%s",
                w.name, w.a, hitKey, w.hit or "-", w.s, w.ap, w.d, w.abilities or "")

            printToColor(string.format("Grouping key: %s", key), "Red", {1,1,0})

            if not groups[key] then
                groups[key] = {
                    count = 0,
                    label = w.name .. "\nA:" .. w.a .. " " .. hitKey .. ":" .. (w.hit or "-") ..
                            " S:" .. w.s .. " AP:" .. w.ap .. " D:" .. w.d ..
                            ((w.abilities ~= "") and "\n[" .. w.abilities .. "]" or "")
                }
            end

            groups[key].count = groups[key].count + 1
        end
    end

    return groups
end


function clearSpawnedDiceObjects()
    for _, obj in ipairs(spawnedDiceObjects) do
        if obj and obj.getGUID then
            destroyObject(obj)
        end
    end
    spawnedDiceObjects = {}
end


function spawnWeaponDice(playerColor, grouped)
    clearSpawnedDiceObjects()
    local grid = PLAYER_GRID_SPAWN[playerColor]
    if not grid then
        printToAll("No grid defined for color: " .. playerColor, {1,0,0})
        return
    end

    local origin = grid.origin
    local dx, dz = grid.right[1], grid.right[2]
    local dyx, dyz = grid.down[1], grid.down[2]

    local rowSize = 5
    local spacing = 1.6
    local groupOffsetZ = 0

    local groupList = {}
    for _, group in pairs(grouped) do
        table.insert(groupList, group)
    end

    table.sort(groupList, function(a, b)
        return a.label < b.label
    end)

    for _, group in ipairs(groupList) do
        local groupColor = group.color or stringColorToRGB(playerColor)
        local attacksPerModel = tonumber(group.label:match("A:(%d+)") or 0)
        local totalDice = group.count * attacksPerModel
        local rows = math.ceil(totalDice / rowSize)
        local groupOffsetX = 0

        printToColor(string.format("Spawning group: %s | Models: %d | Dice: %d", group.label, group.count, totalDice), playerColor, {0.6, 1, 0.6})

        for i = 0, totalDice - 1 do
            local row = math.floor(i / rowSize)
            local col = i % rowSize
            local pos = {
                x = origin.x + col * spacing * dx + row * spacing * dyx + groupOffsetX,
                y = origin.y + 2,
                z = origin.z + col * spacing * dz + row * spacing * dyz + groupOffsetZ,
            }
            local die = spawnObject({
                type = "Die_6_Rounded",
                position = pos,
                rotation = {0, math.random() * 360, 0},
                callback_function = function(obj)
                    obj.setColorTint(groupColor)
                end
            })
            table.insert(spawnedDiceObjects, die)
            
        end

        -- Raise label above grid center
        local labelPos = {
            x = origin.x + 2 * spacing * dx + groupOffsetX,
            y = origin.y + 4.0,
            z = origin.z + 2 * spacing * dz + groupOffsetZ,
        }

        local diceText = spawnObject({
            type = "3DText",
            position = labelPos,
            rotation = {
                0,
                (playerColor == "Red") and 180 or 0,
                0
            },
            scale = {0.8, 0.8, 0.8},
            sound = false,
            callback_function = function(obj)
                obj.TextTool.setValue(group.label)
                obj.TextTool.setFontColor(groupColor)
            end
        })

        table.insert(spawnedDiceObjects, diceText)

        local groupSpacing = (rows + 1.5) * spacing
        groupOffsetZ = groupOffsetZ + groupSpacing * dyz
        groupOffsetX = groupOffsetX + groupSpacing * dyx
    end
end






-- Global state
measuringState = { source = nil, target = nil }
highlightedObjects = {}

function clearHighlights()
    for _, obj in ipairs(highlightedObjects) do
        if obj and obj.highlightOff then obj.highlightOff() end
    end
    highlightedObjects = {}
end


-- Hotkey targeting system for attack eligibility

-- Hotkey targeting system for attack eligibility with visual aid

-- Globals to track targeting state
local targetingState = {
    sourceGUID = nil,
    sourceUnit = {},
    targetGUID = nil,
    targetUnit = {},
    colorMap = {}  -- label -> RGB
}

local allVectorLines = {}  -- used by setVectorLines()


-- Helper: extract uuid from an object's tags
function getUUIDFromTags(obj)
    for _, tag in ipairs(obj.getTags()) do
        local uuid = tag:match("^uuid:(.+)")
        if uuid then return uuid end
    end
    return nil
end

-- Helper: extract weapon range in inches
function extractRangeInches(rangeStr)
    if not rangeStr then return nil end
    local value = rangeStr:match("(%d+)%s*\"")
    return tonumber(value)
end

-- Generate deterministic color from string
function colorFromLabel(label, playerColor)
    local playerColorMap = {
        White = {1, 1, 1},
        Brown = {0.4, 0.2, 0},
        Red = {1, 0, 0},
        Orange = {1, 0.5, 0},
        Yellow = {1, 1, 0},
        Green = {0, 1, 0},
        Teal = {0, 1, 1},
        Blue = {0, 0, 1},
        Purple = {0.5, 0, 1},
        Pink = {1, 0.4, 0.7},
        Grey = {0.5, 0.5, 0.5},
        Black = {0, 0, 0},
    }

    local baseColor = playerColorMap[playerColor] or {1, 1, 1}

    -- Create a pseudo-random color from label hash
    local seed = 0
    for i = 1, #label do
        seed = seed + label:byte(i) * i
    end

    -- Generate a unique but repeatable color from the label
    local r = (math.sin(seed * 0.1 + 1) * 0.5 + 0.5)
    local g = (math.sin(seed * 0.13 + 2) * 0.5 + 0.5)
    local b = (math.sin(seed * 0.07 + 3) * 0.5 + 0.5)

    local labelColor = {r, g, b}

    -- Blend player color and label color (bias towards player color)
    local bias = 0.4  -- 0.0 = only label color, 1.0 = only player color

    local blended = {
        baseColor[1] * bias + labelColor[1] * (1 - bias),
        baseColor[2] * bias + labelColor[2] * (1 - bias),
        baseColor[3] * bias + labelColor[3] * (1 - bias)
    }

    return blended
end


-- Clear previous draw lines
function clearDraw()
    Global.setVectorLines({})
end


function getBoundingBoxCorners(obj)
    if not obj or not obj.getBounds then
        log("[getBoundingBoxCorners] Invalid object passed.")
        return {}
    end
    local bounds = obj.getBounds()
    local cx, cy, cz = bounds.center.x, bounds.center.y, bounds.center.z
    local sx, sy, sz = bounds.size.x / 2, bounds.size.y / 2, bounds.size.z / 2

    local corners = {
        {x = cx - sx, y = cy - sy, z = cz - sz},
        {x = cx + sx, y = cy - sy, z = cz - sz},
        {x = cx + sx, y = cy - sy, z = cz + sz},
        {x = cx - sx, y = cy - sy, z = cz + sz},
        {x = cx - sx, y = cy + sy, z = cz - sz},
        {x = cx + sx, y = cy + sy, z = cz - sz},
        {x = cx + sx, y = cy + sy, z = cz + sz},
        {x = cx - sx, y = cy + sy, z = cz + sz}
    }

    return corners
end
debugVectorLines = {}
function drawBoundingBox(obj, color)
    local c = color or {1, 1, 0}
    local corners = getBoundingBoxCorners(obj)
    local lines = {
        -- bottom square
        {1,2}, {2,3}, {3,4}, {4,1},
        -- top square
        {5,6}, {6,7}, {7,8}, {8,5},
        -- verticals
        {1,5}, {2,6}, {3,7}, {4,8}
    }

    for _, pair in ipairs(lines) do
        local p1 = corners[pair[1]]
        local p2 = corners[pair[2]]
        table.insert(debugVectorLines, {
            color = c,
            points = {
                {p1.x, p1.y, p1.z},
                {p2.x, p2.y, p2.z}
            },
            thickness = 0.03
        })
    end

    Global.setVectorLines(debugVectorLines)
end



function getMinimumDistanceBetweenBoundingBoxes(obj1, obj2)
    local corners1 = getBoundingBoxCorners(obj1)
    local corners2 = getBoundingBoxCorners(obj2)

    local minDist = math.huge
    for _, c1 in ipairs(corners1) do
        for _, c2 in ipairs(corners2) do
            local dx = c1.x - c2.x
            local dy = c1.y - c2.y
            local dz = c1.z - c2.z
            local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
            if dist < minDist then
                minDist = dist
            end
        end
    end

    return minDist
end

function spawnFloatingHeightMarker(playerColor)
    local player = Player[playerColor]
    local pos = player.getPointerPosition()  -- where mouse points

    pos.y = pos.y + 2.5  -- float above surface

    local marker = spawnObject({
        type = "BlockSquare",
        position = pos,
        scale = {1, 0.1, 1},
        sound = false,
        callback_function = function(obj)
            obj.setName("Height Marker")
            obj.setDescription("Use buttons 8/9 to raise/lower. Press 0 to confirm height.")
            obj.setColorTint({0, 1, 1})
            obj.addTag("heightMarker")
            obj.setLock(true)
            obj.use_gravity = false
            obj.interactable = true

            obj.setVar("raiseDelta", 0.2)
        end
    })
end

currentHeightMarker = {
    pos = nil,
    height = nil
}

function drawHeightMarker(pos, height)
    local size = 2
    local half = size / 2
    local lines = {}
    local y0 = pos.y
    local y1 = y0+ height

    -- Define bottom corners
    local corners = {
        {pos.x - half, y0, pos.z - half},  -- 1
        {pos.x + half, y0, pos.z - half},  -- 2
        {pos.x + half, y0, pos.z + half},  -- 3
        {pos.x - half, y0, pos.z + half},  -- 4
    }

    -- Define top corners
    local topCorners = {}
    for _, p in ipairs(corners) do
        table.insert(topCorners, {p[1], y1, p[3]})
    end

    -- Bottom loop
    table.insert(lines, {
        color = {0, 1, 1},
        thickness = 0.1,
        points = {corners[1], corners[2], corners[3], corners[4], corners[1]}
    })

    -- Top loop
    table.insert(lines, {
        color = {0, 1, 1},
        thickness = 0.1,
        points = {topCorners[1], topCorners[2], topCorners[3], topCorners[4], topCorners[1]}
    })

    -- Diagonal twist lines (bottom[i] to top[i+1])
    for i = 1, 4 do
        local j = (i % 4) + 1
        table.insert(lines, {
            color = {0, 1, 1},
            thickness = 0.1,
            points = {corners[i], topCorners[j]}
        })
    end

    for i = 1, 4 do
        local j = (i % 4) + 1
        table.insert(lines, {
            color = {0, 1, 1},
            thickness = 0.1,
            points = {corners[j], topCorners[i]}
        })
    end

    Global.setVectorLines(lines)
end






function bakeLOSCorners(obj, height)
    local bounds = obj.getBounds()
    local pos = obj.getPosition()
    local sx = bounds.size.x / 2
    local sz = bounds.size.z / 2
    local bottomY = bounds.center.y - bounds.size.y / 2 + 0.1

    -- Define 4 bottom corners
    local bottoms = {
        {x = -sx, y = bottomY - pos.y, z = -sz},
        {x =  sx, y = bottomY - pos.y, z = -sz},
        {x =  sx, y = bottomY - pos.y, z =  sz},
        {x = -sx, y = bottomY - pos.y, z =  sz}
    }

    -- 4 top corners above the base
    local corners = {}
    for _, pt in ipairs(bottoms) do table.insert(corners, pt) end
    for _, pt in ipairs(bottoms) do
        table.insert(corners, {x = pt.x, y = pt.y + height, z = pt.z})
    end

    -- Store in GM Notes
    local notes = obj.getGMNotes()
    local data = {}
    local ok, decoded = pcall(JSON.decode, notes)
    if ok and type(decoded) == "table" then data = decoded end

    data.los_corners = corners
    obj.setGMNotes(JSON.encode_pretty(data))
    obj.addTag("losBaked")
end


function getBakedLOSCorners(obj)
    local notes = obj.getGMNotes()
    local ok, decoded = pcall(JSON.decode, notes or "")
    if ok and decoded and decoded.los_corners then
        return decoded.los_corners
    end
    return nil
end


function drawLOSCornerBox(corners, obj, color)
    local c = color or {1, 0.8, 0}
    local objPos = obj.getPosition()
    local lines = {
        {1,2}, {2,3}, {3,4}, {4,1},
        {5,6}, {6,7}, {7,8}, {8,5},
        {1,5}, {2,6}, {3,7}, {4,8}
    }

    local vectorLines = {}
    for _, pair in ipairs(lines) do
        local p1 = corners[pair[1]]
        local p2 = corners[pair[2]]

        local wp1 = {p1.x + objPos.x, p1.y + objPos.y, p1.z + objPos.z}
        local wp2 = {p2.x + objPos.x, p2.y + objPos.y, p2.z + objPos.z}

        table.insert(vectorLines, {
            color = c,
            thickness = 0.05,
            points = {wp1, wp2}
        })
    end

    return vectorLines
end


function drawAllLOSCornerBoxes()
    local allLines = {}

    for _, obj in ipairs(getAllObjects()) do
        if obj.hasTag("losBaked") then
            local corners = getBakedLOSCorners(obj)
            if corners and #corners == 8 then
                local lines = drawLOSCornerBox(corners, obj, {1, 0.8, 0})
                for _, line in ipairs(lines) do
                    table.insert(allLines, line)
                end
            end
        end
    end

    Global.setVectorLines(allLines)
    print("LOS debug boxes drawn.")
end

function getModelDistance(source, target)
    local function getWorldCorners(obj)
        local objPos = obj.getPosition()
        local corners = nil

        -- Prefer baked LOS corners
        if obj.hasTag("losBaked") then
            local notes = obj.getGMNotes()
            local ok, decoded = pcall(JSON.decode, notes or "")
            if ok and decoded and decoded.los_corners and #decoded.los_corners == 8 then
                corners = {}
                for _, rel in ipairs(decoded.los_corners) do
                    table.insert(corners, {
                        x = objPos.x + rel.x,
                        y = objPos.y + rel.y,
                        z = objPos.z + rel.z
                    })
                end
            end
        end

        -- Fallback: bounding box
        if not corners then
            local bounds = obj.getBounds()
            local cx, cy, cz = bounds.center.x, bounds.center.y, bounds.center.z
            local sx, sy, sz = bounds.size.x / 2, bounds.size.y / 2, bounds.size.z / 2

            corners = {
                {x = cx - sx, y = cy - sy, z = cz - sz},
                {x = cx + sx, y = cy - sy, z = cz - sz},
                {x = cx + sx, y = cy - sy, z = cz + sz},
                {x = cx - sx, y = cy - sy, z = cz + sz},
                {x = cx - sx, y = cy + sy, z = cz - sz},
                {x = cx + sx, y = cy + sy, z = cz - sz},
                {x = cx + sx, y = cy + sy, z = cz + sz},
                {x = cx - sx, y = cy + sy, z = cz + sz}
            }
        end

        return corners
    end

    local c1 = getWorldCorners(source)
    local c2 = getWorldCorners(target)

    local minDist = math.huge
    for _, p1 in ipairs(c1) do
        for _, p2 in ipairs(c2) do
            local dx = p1.x - p2.x
            local dy = p1.y - p2.y
            local dz = p1.z - p2.z
            local d = math.sqrt(dx*dx + dy*dy + dz*dz)
            if d < minDist then
                minDist = d
            end
        end
    end

    return minDist
end



heldButtons = {}

function startHeightAdjustLoop(playerColor, index)
    local delta = (index == 8) and 0.05 or -0.05  -- U raises, I lowers

    Wait.time(function()
        -- Stop if button no longer held
        if not (heldButtons[playerColor] and heldButtons[playerColor][index]) then
            return
        end

        -- Initialize if needed
        if not currentHeightMarker.pos then
            local pos = Player[playerColor].getPointerPosition()
            currentHeightMarker.pos = {x = pos.x, y = pos.y, z = pos.z}
            currentHeightMarker.height = pos.y + 2.5
        else
            currentHeightMarker.height = currentHeightMarker.height + delta
        end

        drawHeightMarker(currentHeightMarker.pos, currentHeightMarker.height)
        

        -- Repeat the loop while held
        startHeightAdjustLoop(playerColor, index)
    end, 0.01)  -- repeat every 0.2s
end

-- Override scripting button down (B = 1, C = 2, K = 3)
function onScriptingButtonDown(index, playerColor)
    if index == 1 then  -- 'B' key pressed
        log(playerColor .. " pressed Button 1 (Select unit)")

        local hoverObj = Player[playerColor].getHoverObject()
        if not hoverObj then
            broadcastToColor("No object under pointer.", playerColor, {1,0.5,0.5})
            return
        end

        local uuid = getUUIDFromTags(hoverObj)
        if not uuid then
            broadcastToColor("Hovered model has no UUID tag.", playerColor, {1,0.5,0.5})
            drawBoundingBox(hoverObj, {0, 1, 0})
            return
        end

        if not targetingState.sourceGUID then
            targetingState.sourceGUID = uuid
            targetingState.sourceUnit = getObjectsWithTag("uuid:" .. uuid)
            for _, obj in ipairs(targetingState.sourceUnit) do 
                obj.highlightOn({0,1,0}) 
                drawBoundingBox(obj, {0, 1, 0})
            end
            broadcastToColor("Source unit selected.", playerColor, {0.5,1,0.5})
        else
            targetingState.targetGUID = uuid
            targetingState.targetUnit = getObjectsWithTag("uuid:" .. uuid)
            for _, obj in ipairs(targetingState.targetUnit) do 
                obj.highlightOn({1,0,0}) 
                drawBoundingBox(obj, {1, 0, 0})
            end
            broadcastToColor("Target unit selected.", playerColor, {1,0.4,0.4})
        end

    elseif index == 2 then  -- 'C' key pressed to confirm fire
        log(playerColor .. " pressed Button 2 (Confirm)")

        if not targetingState.sourceUnit or not targetingState.targetUnit then
            broadcastToColor("Select source and target units first.", playerColor, {1,1,0})
            return
        end

        -- Clear prior vector lines
        Global.setVectorLines({})

        local weaponMap = parseWeaponsByModel(targetingState.sourceUnit, "Ranged")
        local groupedByLabel = {}
        local allVectorLines = {}

        for source, weapons in pairs(weaponMap) do
            for _, weapon in ipairs(weapons) do
                local label = weapon.name .. "\nA:" .. weapon.a .. " BS:" .. (weapon.hit or "-") ..
                              " S:" .. weapon.s .. " AP:" .. weapon.ap .. " D:" .. weapon.d ..
                              ((weapon.abilities ~= "") and "\n[" .. weapon.abilities .. "]" or "")

                local rangeInches = tonumber(weapon.range)
                if not rangeInches then ::continue:: end

                local sourcePos = source.getPosition()
                local closestTarget = nil
                local closestDist = math.huge

                for _, target in ipairs(targetingState.targetUnit) do
                    local dist = getModelDistance(source, target)
                    if dist < closestDist and dist <= rangeInches then
                        closestTarget = target
                        closestDist = dist
                    end
                end

                if closestTarget then
                    groupedByLabel[label] = groupedByLabel[label] or {
                        label = label,
                        color = colorFromLabel(label, playerColor),
                        count = 0,
                        instances = {}
                    }
                    groupedByLabel[label].count = groupedByLabel[label].count + 1
                    table.insert(groupedByLabel[label].instances, {source = source, target = closestTarget})

                    local tgt = closestTarget.getPosition()
                    local mid = {
                        (sourcePos.x + tgt.x) / 2,
                        math.max(sourcePos.y, tgt.y) + 0.3 + 0.2 * groupedByLabel[label].count,
                        (sourcePos.z + tgt.z) / 2
                    }

                    local srcRaise = {sourcePos.x, sourcePos.y + 0.3 + 0.2 * groupedByLabel[label].count, sourcePos.z}
                    local tgtRaise = {tgt.x, tgt.y + 0.3 + 0.2 * groupedByLabel[label].count, tgt.z}

                    table.insert(allVectorLines, {
                        color = groupedByLabel[label].color,
                        points = {srcRaise, mid, tgtRaise},
                        thickness = 0.05
                    })
                end

                ::continue::
            end
        end

        Global.setVectorLines(allVectorLines)
        spawnWeaponDice(playerColor, groupedByLabel)

    elseif index == 3 then  -- 'K' key to clear
        log(playerColor .. " pressed Button 3 (Clear)")

        for _, obj in ipairs(targetingState.sourceUnit) do obj.highlightOff() end
        for _, obj in ipairs(targetingState.targetUnit) do obj.highlightOff() end
        Global.setVectorLines({})
        targetingState = {
            sourceUnit = {}, targetUnit = {}, sourceGUID = nil, targetGUID = nil,
            drawHandles = {}, colorMap = {}
        }
        broadcastToColor("Cleared target/source selection.", playerColor, {0.8,0.8,0.8})
    


    -- O key – Apply current marker height to selected models
    elseif index == 7 then
        if not currentHeightMarker.pos or not currentHeightMarker.height then
            broadcastToColor("No height marker set.", playerColor, {1, 0.5, 0.5})
            return
        end

        local selected = Player[playerColor].getSelectedObjects()
        if #selected == 0 then
            broadcastToColor("No models selected to apply height to.", playerColor, {1, 0.5, 0.5})
            return
        end

        local updated = 0
        for _, obj in ipairs(selected) do
            bakeLOSCorners(obj, currentHeightMarker.height)
            updated = updated + 1
        end

        Global.setVectorLines({})
        currentHeightMarker = {pos = nil, height = nil}
        broadcastToColor("Applied height to " .. updated .. " selected model(s).", playerColor, {0, 1, 0})

    elseif index == 8 or index == 9 then  -- U/I keys
        heldButtons[playerColor] = heldButtons[playerColor] or {}
        heldButtons[playerColor][index] = true

        -- Start hold loop
        startHeightAdjustLoop(playerColor, index)
    end

end


function onScriptingButtonUp(index, playerColor)
    if heldButtons[playerColor] then
        heldButtons[playerColor][index] = false
    else
        heldButtons[playerColor] = {}  -- Ensure it's at least a table
    end
end



-- Global state tables
unitOwnerByUUID = {}        -- unit UUID -> first player color to pick up
unitGroupsByColor = {}      -- color -> list of unit UUIDs
unitCandidates = {}         -- GUID -> object waiting for group match

-- Triggered when object is spawned into world
function onObjectSpawn(obj)
    -- Wait to avoid clashing with object's internal initialization
    Wait.frames(function()
        if not obj then return end

        local script = obj.getLuaScript()
        if not script or #script < 50 then
            log("Spawned object has no meaningful script: " .. obj.getGUID())
            return
        end

        -- Attempt to extract unitData block from the object's script
        local unitData = extractUnitDataFromScript(script)
        if not unitData or not unitData.uuid then
            log("No valid unitData or UUID found in script for: " .. obj.getGUID())
            return
        end

        local uuid = unitData.uuid
        local uuidTag = "uuid:" .. uuid
        local group = getObjectsWithTag(uuidTag)

        if not group or #group == 0 then
            log("No other tagged models found for unit UUID: " .. uuid .. " from " .. obj.getGUID())
            return
        end

        log("Registering unit UUID: " .. uuid .. " with " .. #group .. " models")
        for _, model in ipairs(group) do
            if not model.getVar("unitUUID") then
                model.setVar("unitUUID", uuid)
                log("Set unitUUID on model " .. model.getGUID() .. " -> " .. uuid)
            end
        end
    end, 20)
end

function extractUnitDataFromScript(code)
    local lines = {}
    local inside = false
    local braceDepth = 0

    for line in code:gmatch("[^\r\n]+") do
        if not inside then
            if line:find("unitData%s*=%s*{") then
                inside = true
                braceDepth = 1
                table.insert(lines, line)
            end
        elseif inside then
            table.insert(lines, line)
            -- Count opening and closing braces to find when the block ends
            local openCount = select(2, line:gsub("{", ""))
            local closeCount = select(2, line:gsub("}", ""))
            braceDepth = braceDepth + openCount - closeCount

            if braceDepth <= 0 then break end
        end
    end

    if #lines == 0 then
        log("[unitData] No unitData block found.")
        return nil
    end

    local block = table.concat(lines, "\n")
    local uuid = block:match('uuid%s*=%s*"([%w%-]+)"')

    if uuid then
        log("[unitData] Extracted unit UUID: " .. uuid)
        return { uuid = uuid }
    else
        log("[unitData] Failed to find UUID in full block:\n" .. block)
        return nil
    end
end


function onObjectPickUp(player_color, obj)
    local objUUID = extractUUIDFromTag(obj)
    if not objUUID then
        return
    end

    if hasTag(obj, "ownerClaimed:true") then
        return
    end

    local group = getObjectsWithTag("uuid:" .. objUUID)
    if #group == 0 then
        return
    end

    for _, model in ipairs(group) do
        model.addTag("ownerClaimed:true")
    end

    unitOwnerByUUID[objUUID] = player_color
    log("[UnitTracker] Player " .. player_color .. " claimed unit UUID " .. objUUID .. " (" .. #group .. " models tagged)")
end

-- Extract UUID from tag like "uuid:xyz123"
function extractUUIDFromTag(obj)
    local tags = obj.getTags()
    for _, tag in ipairs(tags) do
        local match = tag:match("^uuid:(%w+)$")
        if match then return match end
    end
    return nil
end

-- Utility to check if object has a specific tag
function hasTag(obj, tagName)
    local tags = obj.getTags()
    for _, tag in ipairs(tags) do
        if tag == tagName then return true end
    end
    return false
end





function hasStatline(desc)
    desc = desc or ""
    local statlineHeaders = { "M", "T", "Sv", "W", "Ld", "OC" }
    for line in desc:gmatch("[^\r\n]+") do
        local tokens = {}
        for token in line:gmatch("%S+") do table.insert(tokens, token) end
        local match = 0
        for _, header in ipairs(statlineHeaders) do
            for _, token in ipairs(tokens) do
                if token == header then match = match + 1 break end
            end
        end
        if match >= 4 then return true end
    end
    return false
end

function maybeAddContextMenus(obj)
    if not hasStatline(obj.getDescription()) then return end

    obj.addContextMenuItem("Create Unit", function(playerColor)
        assignToUnit(obj, playerColor)
    end)

    obj.addContextMenuItem("Disband Unit", function(playerColor)
        disbandUnit(obj, playerColor)
    end)
end

function assignToUnit(obj, playerColor)
    local guid = obj.getGUID()

    if objectToUnitMap[guid] then
        broadcastToColor("Object is already in a unit.", playerColor, {1, 0.6, 0.6})
        return
    end

    unitGroups[playerColor] = unitGroups[playerColor] or {}
    local newId = #unitGroups[playerColor] + 1

    unitGroups[playerColor][newId] = { guid }
    objectToUnitMap[guid] = { color = playerColor, id = newId }

    broadcastToColor("Assigned object to unit #" .. newId, playerColor, {0.7, 1, 0.7})
end

function disbandUnit(obj, playerColor)
    local guid = obj.getGUID()
    local meta = objectToUnitMap[guid]
    if not meta or meta.color ~= playerColor then
        broadcastToColor("Object is not part of a unit you control.", playerColor, {1, 0.4, 0.4})
        return
    end

    local group = unitGroups[playerColor][meta.id]
    if not group then return end

    for _, g in ipairs(group) do
        objectToUnitMap[g] = nil
    end
    unitGroups[playerColor][meta.id] = nil
    broadcastToColor("Disbanded unit #" .. meta.id, playerColor, {1, 0.4, 0.4})
end





function onSave()
    blueSecondaryDeckGUID = nil
    if packSelected then
        blueSecondaryDeckGUID = missionPackData[packSelected].blueSecondaryDeck_GUID
    end
    saved_data = JSON.encode({
                                svredPlayerID = redPlayerID,
                                svbluePlayerID = bluePlayerID,
                                svPackSelected = packSelected,
                                svBlueSecondaryDeckGUID = blueSecondaryDeckGUID
                            })
    --saved_data = ""
    return saved_data
end

function onLoad(saved_data)
    Turns.enable=false
    --- load vars from saved
    if saved_data ~= "" then
         local loaded_data = JSON.decode(saved_data)
         redPlayerID = loaded_data.svredPlayerID
         bluePlayerID = loaded_data.svbluePlayerID
         packSelected = loaded_data.svPackSelected
         if packSelected then
            missionPackData[packSelected].blueSecondaryDeck_GUID = loaded_data.svBlueSecondaryDeckGUID
         end
    else
        redPlayerID = ""
        bluePlayerID = ""
        packSelected = nil
    end
    ---- end loading
    if allowMenu then
        if allowAutoSeat and redPlayerID ~= "" and bluePlayerID ~= "" then --  if the game is not started dont autoseat
                autoSeatAll()
        else
            Global.UI.setAttribute("main", "active", "true")
            local presentPersons= Player.getPlayers()
            for i, person in ipairs(presentPersons) do
                person.team="Diamonds"
            end
            presentPersons= Player.getSpectators()
            for i, person in ipairs(presentPersons) do
                person.team="Diamonds"
            end
            showHideRedBlueBtn()
        end
    else
        Global.UI.setAttribute("main", "active", "false")
    end
end

function setMissionPack(params)
    packSelected = params.pack
    redSecondaryDeck = getObjectFromGUID(missionPackData[packSelected].redSecondaryDeck_GUID)
    blueSecondaryDeck = redSecondaryDeck.clone({position = redSecondaryDeck.getPosition()})
    missionPackData[packSelected].blueSecondaryDeck_GUID = blueSecondaryDeck.getGUID()
end

function autoSeatPerson(_person)
    if _person.steam_id == redPlayerID then
        if Player.Red.seated then
            Player.Red.changeColor("Grey")
        end
        _person.changeColor("Red")
        _person.team="None"
        return
    end
    if _person.steam_id == bluePlayerID then
        if Player.Blue.seated then
            Player.Blue.changeColor("Grey")
        end
        _person.changeColor("Blue")
        _person.team="None"
        return
    end
    --_person.changeColor("Grey")
    _person.team="None"
end

function autoSeatGroup(persons)
    for i, person in ipairs(persons) do
        autoSeatPerson(person)
    end
end

function autoSeatAll()
    if redPlayerID=="" or bluePlayerID=="" then --  if the game is not started dont autoseat
        return
    end
    local presents = Player.getPlayers()
    autoSeatGroup(presents)
    presents = Player.getSpectators()
    autoSeatGroup(presents)
end

function recordPlayers()
    redPlayerID = Player.Red.steam_id
    bluePlayerID = Player.Blue.steam_id
end

function onPlayerChangeColor(player_color)
    promotePlayers()
    --demotePlayers()  -- RIC
    showHideRedBlueBtn()
end

function onPlayerConnect(player_id)
    if allowMenu then
        if allowAutoSeat and redPlayerID ~= "" and bluePlayerID ~= "" then --  if the game is not started dont autoseat
                autoSeatPerson(player_id)
        else
        player_id.team="Diamonds"
        end
    end
end

function promotePlayers()
    local colors={"Red", "Blue", "Orange", "Yellow", "Purple", "Teal"}
    for i, color in ipairs(colors) do
        if Player[color].seated and  Player[color].host == false and not Player[color].promoted then
            Player[color].promote()
        end
    end
end

function demotePlayers()
    for i, color in ipairs(nonPlaying) do
        if Player[color].seated  and Player[color].host == false then
            Player[color].promote(false)
        end
    end
    local spectators=Player.getSpectators()
    for i, person in ipairs(spectators) do
        if person.host == false then
            person.promote(false)
        end
    end
end

function promotePlayersOnConnect()  --NOT USED
    if player_color == "Red" or player_color == "Blue"  then
        Player["Red"].promote(true)
        Player["Blue"].promote(true)
    end
end

function showHideRedBlueBtn()
    if allowMenu then
        if Player.Red.seated == true then
            Global.UI.setAttribute("redBtn", "active", "false")
        else
            Global.UI.setAttribute("redBtn", "active", "true")
        end
        if Player.Blue.seated == true then
            Global.UI.setAttribute("blueBtn", "active", "false")
        else
            Global.UI.setAttribute("blueBtn", "active", "true")
        end
    end
end

function setViewForPlayer(player, color)
    if color=="Grey" then return end
    local pos= {0,0,0}
    if color == "Red" then
        pos = getObjectFromGUID(redDiceMat_GUID).getPosition()
    end
    if color == "Blue" then
        pos = getObjectFromGUID(blueDiceMat_GUID).getPosition()
    end
    player.lookAt({
        position = pos,
        pitch    = 25,
        yaw      = 180,
        distance = 20,
        })
end

function placeToColor(player, color)
    player.changeColor(color)
    player.team="None"
    broadcastToColor("READ INSTRUCTIONS FIRST!\n(Click Notebook at the top)", color, "Purple")
    --setViewForPlayer(player, color) --bugged
end

function placeToRed(player, value, id)
    placeToColor(player, "Red")
    --player.changeColor("Red")
    --player.team="None"
end

function placeToBlue(player, value, id)
    placeToColor(player, "Blue")
    --player.changeColor("Blue")
    --player.team="None"
end

function placeToGray(player, value, id)
    placeToColor(player, "Grey")
    --player.changeColor("Grey")
    --player.team="None"
end
function closeMenu(player, value, id)
    player.team="None"
    broadcastToColor("READ INSTRUCTIONS FIRST!\n(Click Notebook at the top)", player.color, "Purple")
end

backPosition={{0,0,0},{0,0,0},{0,0,0},{0,0,0}}
function goToDiceRoller(player, value, id)
    local matPositionOffset=12
    local color=player.color
    local diceMatGUID=redDiceMat_GUID
    local i=1
    if color == "Red" then
        i=1
    end
    if color == "Orange" then
        i=2
    end
    if color == "Blue" then
        diceMatGUID = blueDiceMat_GUID
        i=3
        matPositionOffset=-matPositionOffset
    end
    if color == "Teal" then
        diceMatGUID = blueDiceMat_GUID
        i=4
        matPositionOffset=-matPositionOffset
    end
    if Player[color].getSelectedObjects()[1] ~= nil then
        backPosition[i]=Player[color].getSelectedObjects()[1].getPosition()
    end

    local matPos=getObjectFromGUID(diceMatGUID).getPosition()
    matPos.x=matPos.x+matPositionOffset
    moveCameraTo(matPos,30,color)
end

function goToSquad(player, value, id)
    local i = 1
    local color=player.color
    if color == "Red" then
        i=1
    end
    if color == "Orange" then
        i=2
    end
    if color == "Blue" then
        i=3
    end
    if color == "Teal" then
        i=4
    end
    moveCameraTo(backPosition[i], 20, color)
end
function moveCameraTo(pos, dist, color)
    if color == "Red" then
        rot = {0,180,0}
    end
    if color == "Orange" then
        rot = {0,180,0}
    end
    if color == "Blue" then
        rot = {0,0,0}
    end
    if color == "Teal" then
        rot = {0,0,0}
    end
    if pos[2]==0 then dist=dist+30 end
    Player[color].lookAt({position=pos, pitch=90, yaw=rot[2], distance=dist})
end

function moveAllFromZoneToDeck(params)
    local zoneObj = getObjectFromGUID(Global.getVar(params.zone .. "CardZone_GUID"))
    local deckObj = getObjectFromGUID(missionPackData[packSelected][params.deck .. "Deck_GUID"])

    local objects = zoneObj.getObjects()
    for _,object in ipairs(objects) do
        object.locked = false
        deckObj.putObject(object)
    end

    deckObj.shuffle()
end

function moveOneFromDeckToZone(params)
    local zoneObj = getObjectFromGUID(Global.getVar(params.zone .. "CardZone_GUID"))
    local deckObj = getObjectFromGUID(missionPackData[packSelected][params.deck .. "Deck_GUID"])
    local takeParams = {}
    takeParams.position = zoneObj.getPosition()
    takeParams.flip = true
    takeParams.smooth = true
    takeParams.callback_function = function(card)
        Wait.frames(function()
            card.locked = true
        end)
    end
    if params["card"] then
        takeParams.guid = params.card
    else
        deckObj.shuffle()
    end
    deckObj.takeObject(takeParams)
end