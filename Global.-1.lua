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

redRollerGUID = "63ea6b"



CPMissionBook_GUID = "731ec4"

-- Globals to track targeting state
targetingState = {
    sourceGUID = nil,
    sourceUnit = nil,
    targetGUIDs = {},             -- ordered list of selected target UUIDs
    targetUnits = {},             -- map: uuid -> list of models
    colorMap = {},                -- label -> RGB
    confirmed = false,
    previewing = false
}


allVectorLines = {}  -- used by setVectorLines()

bbVectorLines = {}


-- Global storage for tracking dice groups and buttons
spawnedDiceObjects = {}
diceGroupButtons = {}
diceGroupsByButtonGUID = {}
diceDescriptionByButtonGUID = {}
spawnedAssignmentUI = {
    texts = {},
    buttons = {}
}
buttonsByAssignmentKey = {}



assignmentMap = {}
lastBuiltGraph = nil



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



function spawnAssignmentUIAligned(playerColor, graph)
    clearAssignmentUI()
    local grid = PLAYER_GRID_SPAWN[playerColor]
    if not grid then
        printToAll("No UI grid for color: " .. playerColor, {1, 0, 0})
        return
    end

    local origin = grid.origin
    local dx = grid.xDir
    local dz = grid.zDir
    local spacing = 1.8
    local offsetX = 0

    lastBuiltGraph = graph
    assignmentMap = {}


    local function wrapText(text, maxLen)
        local out = ""
        local lineLen = 0
        for word in text:gmatch("%S+") do
            if lineLen + #word > maxLen then
                out = out .. "\n"
                lineLen = 0
            end
            out = out .. word .. " "
            lineLen = lineLen + #word + 1
        end
    
        return (out:gsub("^%s+", ""):gsub("%s+$", ""))  -- Safe trim
    end
    

    for _, source in ipairs(graph.sourceNodes) do
        if not source.validTargets or #source.validTargets == 0 then 
        else
            buttonsByAssignmentKey[source.signature] = buttonsByAssignmentKey[source.signature] or {}
            local label = string.format(
                "%s [%d]\nA:%d BS:%s S:%d AP:%d D:%d",
                source.weapon.name,
                #source.models,
                source.weapon.a_n or 1,
                source.weapon.hit or "-",
                source.weapon.s or 0,
                source.weapon.ap or 0,
                source.weapon.d_n or 1
            )

            label = wrapText(label, 20)

            local labelPos = {
                x = origin.x + offsetX + 2 * spacing * dx,
                y = origin.y + 3,
                z = origin.z + 0 * spacing * dz
            }

            -- spawn 3DText
            local textObj = spawnObject({
                type = "3DText",
                position = labelPos,
                rotation = {
                    0,
                    (playerColor == "Red") and 180 or 0,
                    0
                },
                scale = {0.7, 0.7, 0.7},
                sound = false,
                callback_function = function(obj)
                    obj.TextTool.setValue(label)
                    obj.TextTool.setFontColor({0.8, 1, 0.8})
                    obj.setLock(true)
                    obj.setName("Weapon: " .. source.weapon.name)
                end
            })

            table.insert(spawnedAssignmentUI.texts, textObj)


            -- build initial assignments
            assignmentMap[source.signature] = {}
            assignmentMap[source.signature][source.validTargets[1]] = #source.models

            if #source.validTargets > 1 then
                for i, targetUUID in ipairs(source.validTargets) do
                    local targetLabel = targetUUID:sub(1, 6)
                    local count = assignmentMap[source.signature][targetUUID] or 0
                    assignmentMap[source.signature][source.validTargets[i]] = assignmentMap[source.signature][source.validTargets[i]] or 0
                    local btnPos = {
                        x = origin.x + offsetX + 2 * spacing * dx,
                        y = origin.y + 1,
                        z = origin.z + (i + 0.5) * spacing * dz
                    }


                    local rawName = getUnitNameFromUUID(targetUUID) or "Unknown Unit"
                    local count = assignmentMap[source.signature][targetUUID] or 0

                    -- Auto-wrap name after N characters per line


                    local wrappedName = wrapText(rawName, 16)
                    local numLines = select(2, wrappedName:gsub("\n", "\n")) + 1
                    local labelText = wrappedName .. "\n[" .. count .. "]"

                    -- Scale font size to fit more lines if needed
                    local fontSize = 200
                    if numLines >= 3 then
                        fontSize = 170
                    elseif numLines == 2 then
                        fontSize = 200
                    end

                    local btnObj = spawnObject({
                        type = "BlockSquare",
                        position = btnPos,
                        scale = {1.4, 0.2, 0.6},
                        sound = false,
                        callback_function = function(obj)
                            obj.setColorTint({0.2, 0.2, 0.2})
                            obj.setLock(true)
                            obj.interactable = true
                            obj.use_gravity = false

                            obj.setVar("sourceSig", source.signature)
                            obj.setVar("targetUUID", targetUUID)

                            obj.createButton({
                                label = labelText,
                                click_function = "assignButtonClick",
                                function_owner = Global,
                                position = {0, 0.5, 0},
                                rotation = {0, 0, 0},
                                width = 1600,
                                height = 800,
                                font_size = fontSize,
                                color = {0.2, 0.2, 0.2},
                                font_color = {1, 1, 1}
                            })
                        end
                    })

                    btnObj.setVar("unitName", wrappedName)

                    table.insert(spawnedAssignmentUI.buttons, btnObj)
                    buttonsByAssignmentKey[source.signature][targetUUID] = btnObj
                end
            end

            -- spacing between groups
            offsetX = offsetX + (5 + 2) * spacing * dx
        end
    end
end

function clearAssignmentUI()
    -- Destroy all 3DText labels
    for _, t in ipairs(spawnedAssignmentUI.texts) do
        if t and t.destroy then t.destroy() end
    end
    spawnedAssignmentUI.texts = {}

    -- Destroy all buttons (BlockSquares)
    for _, b in ipairs(spawnedAssignmentUI.buttons) do
        if b and b.destroy then b.destroy() end
    end
    spawnedAssignmentUI.buttons = {}

    -- Reset state
    assignmentMap = {}
    buttonsByAssignmentKey = {}
    lastBuiltGraph = nil
end

function getUnitNameFromUUID(uuid)
    local tagged = getObjectsWithTag("uuid:" .. uuid)
    if #tagged == 0 then return "Unknown" end
    local obj = tagged[1]


    local script = obj.getLuaScript()
    local name = extractUnitNameFromScript(script)
    if name then
        print("✅ Unit name is: " .. name)
    else
        print("⚠️ No unit name found.")
    end

    if name and name ~= "" then
        return name
    end

    -- Try calling buildUI only if needed
    local ok, err = pcall(function()
        obj.call("maybeBuildUI")
    end)

    -- Try again to read the unit name from the UI
    local updated = obj.UI.getValue("data-unitName")
    return updated and updated ~= "" and updated or obj.getName():match("^%d+/%d+%s+(.+)$") or obj.getName()
end


function extractUnitNameFromScript(code)
    local name = code:match('unitName%s*=%s*"([^"]+)"')
    if name then
        log("[unitData] Found unitName: " .. name)
        return name
    else
        log("[unitData] Could not find unitName.")
        return nil
    end
end



function spawnTargetedDice(obj, playerColor, sourceSig, targetUUID)
    local matGUID = (playerColor == "Red") and redDiceMat_GUID or blueDiceMat_GUID
    local mat = getObjectFromGUID(matGUID)
    if not mat then
        broadcastToColor("❌ Dice mat not found.", playerColor, {1, 0.5, 0.5})
        return
    end

    -- Count how many models are assigned to this target
    local assignedCount = assignmentMap[sourceSig] and assignmentMap[sourceSig][targetUUID] or 0
    if assignedCount == 0 then
        broadcastToColor("⚠️ No models assigned to this target.", playerColor, {1, 0.5, 0.5})
        return
    end

    -- Look up the weapon stats from lastBuiltGraph
    local weapon
    for _, node in ipairs(lastBuiltGraph.sourceNodes or {}) do
        if node.signature == sourceSig then
            weapon = node.weapon
            break
        end
    end
    if not weapon then
        broadcastToColor("⚠️ Could not find weapon info for: " .. sourceSig, playerColor, {1, 0.4, 0.4})
        return
    end

    -- Parse the weapon's attack profile
    local numDice = weapon.a_n or 1
    local sides = weapon.a_s or 1
    local modifier = weapon.a_mod or 0

    local totalDice = 0
    for i = 1, assignedCount do
        totalDice = totalDice + rollDice(numDice, sides, modifier, "")
    end


    mat.call("clearAllHelper", playerColor)
    mat.call("spawnDiceHelper", { n = totalDice, player = playerColor })

    local unitName = getUnitNameFromUUID(targetUUID) or "Target"
    broadcastToColor(string.format("🎲 Spawning %d dice for %s", totalDice, unitName), playerColor, {0.5, 1, 0.5})
end





function assignButtonClick(obj, playerColor, alt_click)
    local sourceSig = obj.getVar("sourceSig")
    local targetUUID = obj.getVar("targetUUID")


    if not sourceSig or not targetUUID then
        broadcastToColor("Missing source or target data on button.", playerColor, {1,0.4,0.4})
        return
    end

    if alt_click then
        
        log(sourceSig)
        log(targetUUID)
        spawnTargetedDice(obj, playerColor, sourceSig, targetUUID)
        obj.editButton({
            index = 0,
            color = {1, 0.2, 0.2}  -- red background
        })

        local rollHelperObj = getObjectFromGUID(redRollerGUID)

        -- ✅ Use structured weapon data directly
        for _, node in ipairs(lastBuiltGraph.sourceNodes) do
            if node.signature == sourceSig then
                rollHelperObj.call("applyWeaponStats", {
                    weapon = node.weapon,
                    target = lastBuiltGraph.targetNodes[targetUUID]
                })
                break
            end
        end
    else
        assignIncrementBtn(obj, playerColor)  -- your existing assign logic
    end
end




function assignIncrementBtn(obj, playerColor)
    local sourceSig = obj.getVar("sourceSig")
    log(sourceSig)
    local targetUUID = obj.getVar("targetUUID")
    log(targetUUID)
    if not sourceSig or not targetUUID then return end

    local data = assignmentMap[sourceSig]
    log(data)
    local maxModels = getMaxModelCountForSource(sourceSig)
    local currentTotal = getAssignedTotal(data)
    log(currentTotal)

    if (data[targetUUID] or 0) < maxModels and currentTotal < maxModels then
        data[targetUUID] = (data[targetUUID] or 0) + 1
        updateAllAssignmentButtonLabels(sourceSig)
        return
    end

    -- Auto-decrement another group
    for otherUUID, count in pairs(data) do
        if otherUUID ~= targetUUID and count > 0 then
            data[otherUUID] = count - 1
            data[targetUUID] = (data[targetUUID] or 0) + 1
            updateAllAssignmentButtonLabels(sourceSig)
            return
        end
    end

    broadcastToColor("🚫 No more models to assign.", playerColor, {1, 0.4, 0.4})
end


function updateAllAssignmentButtonLabels(sourceSig)
    local sourceMap = buttonsByAssignmentKey[sourceSig]
    if not sourceMap then return end

    local data = assignmentMap[sourceSig]
    for targetUUID, btn in pairs(sourceMap) do
        local count = data[targetUUID] or 0
        local unitName = btn.getVar("unitName")
        local labelText = unitName .. "\n[" .. count .. "]"
        btn.editButton({
            index = 0,
            label = labelText
        })
    end
end


function getAssignedTotal(data)
    local total = 0
    log(data)
    for _, v in pairs(data) do total = total + v end
    return total
end

function getMaxModelCountForSource(sourceSig)
    if not lastBuiltGraph then return 0 end
    for _, node in ipairs(lastBuiltGraph.sourceNodes) do
        if node.signature == sourceSig then
            return #node.models
        end
    end
    return 0
end



-- Grid layout for each player
PLAYER_GRID_SPAWN = {
    Red = {
        origin = {x = 18.93, y = 1.28, z = 42.30},
        xDir = -1, -- negative X
        zDir = 1,   -- positive Z
    },
    Blue = {
        origin = {x = -19.16, y = 1.28, z = -42.63},
        xDir = 1,  -- positive X
        zDir = -1,  -- negative Z
    }
}

function onChat(message, player)
    local color = player.color
    
    if message == "!shoot" then
        local descs = getSelectedDescriptions(color)
        local fullText = table.concat(descs, "\n---\n")
        printToColor("Full concatenated description block:\n" .. fullText, color, {1, 1, 0.6})
        log("[" .. player.steam_name .. "]: " .. fullText)
    elseif message == "!attack" then
        local descs = getSelectedDescriptions(color)
        local fullText = table.concat(descs, "\n---\n")
        printToColor("Full concatenated description block:\n" .. fullText, color, {1, 1, 0.6})
        log("[" .. player.steam_name .. "]: " .. fullText)
    end
    if message:lower() == "!drawlos" then
        drawAllLOSCornerBoxes()
        printToColor("LOS debug boxes drawn.", player.color, {1, 0.8, 0})
        return false -- suppress message from chat log if desired
    end

end

-- Updated dice expression parser and model support

-- Function to parse dice expressions like "2D6+3", "D6+2", "3", etc.
-- Returns (numDice, numSides, flatBonus)
function parseDiceExpression(expr)
    expr = expr:upper():gsub("%s+", "")  -- Normalize: uppercase and strip whitespace

    -- Match forms: XdY+Z, dY+Z, XdY, dY, Z
    local n, s, b = expr:match("^(%d+)D(%d+)%+(%d+)$")
    if n then return tonumber(n), tonumber(s), tonumber(b) end

    n, s = expr:match("^(%d+)D(%d+)$")
    if n then return tonumber(n), tonumber(s), 0 end

    s, b = expr:match("^D(%d+)%+(%d+)$")
    if s then return 1, tonumber(s), tonumber(b) end

    s = expr:match("^D(%d+)$")
    if s then return 1, tonumber(s), 0 end

    b = expr:match("^(%d+)$")
    if b then return tonumber(b), 1, 0 end

    return 0, 1, 0  -- Fallback: 0 dice of 1 side with 0 bonus
end

-- Stringify dice expressions from components
function formatDiceExpression(n, s, b)
    if n == 0 then return tostring(b or 0) end
    local base = (n > 1) and (n .. "D" .. s) or ("D" .. s)
    if b and b > 0 then
        return base .. "+" .. b
    else
        return base
    end
end

-- Updated weapon label stringification
function weaponToLabel(weapon)
    local attackStr = formatDiceExpression(weapon.a_n or 1, weapon.a_s or 1, weapon.a_b or 0)
    local damageStr = formatDiceExpression(weapon.d_n or 1, weapon.d_s or 1, weapon.d_b or 0)
    local statLine = "A:" .. attackStr .. " BS:" .. (weapon.hit or "-") ..
                     " S:" .. weapon.s .. " AP:" .. weapon.ap .. " D:" .. damageStr
    local abilityStr = (weapon.abilities and weapon.abilities ~= "") and ("\n[" .. weapon.abilities .. "]") or ""
    return weapon.name .. "\n" .. statLine .. abilityStr
end

function buildWeaponAssignmentGraph(sourceUnit, targetUnits)
    local targetNodes = {}
    local targetUUIDToModels = {}

    -- Group models by unit UUID
    for _, targetObj in ipairs(targetUnits) do
        local uuid = getUUIDFromTags(targetObj)
        if uuid then
            targetUUIDToModels[uuid] = targetUUIDToModels[uuid] or {}
            table.insert(targetUUIDToModels[uuid], targetObj)
        end
    end

    for uuid, models in pairs(targetUUIDToModels) do
        local targetData = {
            guid = uuid,
            models = models
        }
    
        -- 🔍 Extract toughness from description
        local desc = models[1].getDescription()
        targetData.toughness = extractToughnessFromDescription(desc)
    
        -- 📜 Extract keywords from script
        local script = models[1].getLuaScript()
        local keywordStr = script:match('keywords%s*=%s*"([^"]+)"')
        if keywordStr then
            local keywords = {}
            for word in keywordStr:gmatch("[^,%s]+") do
                table.insert(keywords, word)
            end
            targetData.keywords = keywords
        else
            targetData.keywords = {}
        end
    
        targetNodes[uuid] = targetData
    end
    

    -- Flatten weapons across source models
    local rawWeapons = {}
    for _, model in ipairs(sourceUnit) do
        local weaponList = parseWeaponsByModel({model})[model] or {}
        for _, weapon in ipairs(weaponList) do
            log(weapon.abilities)
            table.insert(rawWeapons, { model = model, weapon = weapon })
        end
    end

    -- Group by profile + valid target set
    local weaponGroups = {}

    for _, entry in ipairs(rawWeapons) do
        local model = entry.model
        local w = entry.weapon
        local validTargetUUIDs = {}

        for targetUUID, targetData in pairs(targetNodes) do
            local minDist = math.huge
            for _, tgtModel in ipairs(targetData.models) do
                local dist = getModelDistance(model, tgtModel)
                if dist < minDist then minDist = dist end
            end

            if w.range and minDist <= w.range then
                table.insert(validTargetUUIDs, targetUUID)
            end
        end

        table.sort(validTargetUUIDs)
        local sig = w.name .. "::" .. w.a_n .. "d" .. w.a_s .. "->" .. w.d_n .. "d" .. w.d_s .. "::" .. (w.hit or "-") .. "::" .. table.concat(validTargetUUIDs, "::")

        if not weaponGroups[sig] then
            weaponGroups[sig] = {
                weapon = w,
                models = {},
                validTargets = validTargetUUIDs,
                signature = sig
            }
        end

        table.insert(weaponGroups[sig].models, model)
    end

    -- Convert to list
    local sourceNodes = {}
    for _, group in pairs(weaponGroups) do
        table.insert(sourceNodes, group)
    end

    -- Log output
    log("=== Weapon Assignment Graph ===")
    for _, node in ipairs(sourceNodes) do
        log(string.format(
            "[SourceNode] %s | Range: %s | Models: %d | Targets: %s",
            node.weapon.name,
            tostring(node.weapon.range),
            #node.models,
            table.concat(node.validTargets, ", ")
        ))
    end
    for uuid, tnode in pairs(targetNodes) do
        log(string.format("[TargetNode] %s | Models: %d | Toughness: %s", uuid, #tnode.models, tostring(tnode.toughness)))
    end
    log("===============================")

    return {
        sourceNodes = sourceNodes,
        targetNodes = targetNodes
    }
end





function parseStatBlock(nameLine, statLine)
    local result = {
        name = nameLine,
        count = 1,  -- default to 1 weapon
        a_n = 0, a_s = 1, a_mod = 0,
        d_n = 1, d_s = 1, d_mod = 0,
        hit = nil,
        s = nil,
        ap = nil,
        range = nil,
        abilities = {}
    }

    

    -- Strip any (parenthetical) content and trim whitespace
    nameLine = nameLine:gsub("%s*%(.-%)", ""):gsub("^%s+", ""):gsub("%s+$", "")

    -- Match prefix like "2x Weapon Name" (case-insensitive, optional space)
    local prefix, rest = nameLine:match("^(%d+)[xX]%s*(.+)")
    if prefix and rest then
        result.count = tonumber(prefix)
        nameLine = rest
    end

    result.name = nameLine


    -- Ranged weapon statline: starts with number followed by quote
    if statLine:match("^%d+%s*\"") then
        result.range = tonumber(statLine:match("^(%d+)%s*\""))
    elseif not statLine:match("^A:") then
        return nil
    end

    for tag in statLine:gmatch("%[(.-)%]") do
        local clean = tag:match("^%s*(.-)%s*$")
        if not clean:match("^[%x%-]+$") then
            table.insert(result.abilities, clean)
        end
    end

    local containsTorrent = statLine:lower():find("torrent") ~= nil

    for token in statLine:gmatch("[^%s%[%]]+") do
        local key, value = token:match("([A-Z]+):([%-%+%w]+)")
        if key and value then
            if key == "A" then
                result.a_n, result.a_s, result.a_mod = parseDiceExpression(value)
            elseif key == "BS" or key == "WS" then
                result.hit = value
            elseif key == "S" then
                result.s = tonumber(value)
            elseif key == "AP" then
                result.ap = tonumber(value)
            elseif key == "D" then
                result.d_n, result.d_s, result.d_mod = parseDiceExpression(value)
            end
        end
    end

    if containsTorrent then
        result.hit = 0
    end

    if result.a_n > 0 and result.hit ~= nil and result.s ~= nil and result.ap ~= nil and result.d_n > 0 then
        return result
    else
        return nil
    end
end


function extractToughnessFromDescription(desc)
    -- Find the block with "M   T   Sv ..." then grab the next line
    local lines = {}
    for line in desc:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    for i, line in ipairs(lines) do
        if line:find("M%s+T%s+Sv") and lines[i + 1] then
            local values = {}
            for token in lines[i + 1]:gmatch("%S+") do
                table.insert(values, token)
            end
            local tVal = tonumber(values[2])  -- second column is Toughness
            return tVal
        end
    end
    return nil
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

function parseWeaponsByModel(objects)
    local result = {}

    for _, obj in ipairs(objects) do
        local desc = obj.getDescription()
        local lines = {}

        for line in string.gmatch(desc, "[^\r\n]+") do
            -- Remove bracketed hex/ID values, but preserve gameplay tags
            line = line:gsub("%[(%s*[%x%-]+%s*)%]", "")
            local clean = line:gsub("^%s+", ""):gsub("%s+$", "")
            if clean ~= "" then table.insert(lines, clean) end
        end

        local i = 1
        while i < #lines do
            local nameLine = lines[i]
            local statLine = lines[i + 1]
            local parsed = parseStatBlock(nameLine, statLine)

            if parsed then
                result[obj] = result[obj] or {}
                parsed.range = parsed.range or nil
                parsed.abilities = table.concat(parsed.abilities, ", ")

                for _ = 1, parsed.count or 1 do
                    local copy = {}
                    for k, v in pairs(parsed) do copy[k] = v end
                    copy.count = nil -- optional, since it's now unrolled
                    table.insert(result[obj], copy)
                end

                i = i + 2
            else
                i = i + 1
            end
        end
    end

    return result
end


function formatWeaponLabel(weapon)
    -- Format A (attacks)
    local a = (weapon.a_s == 1) and tostring(weapon.a_n) or (weapon.a_n .. "d" .. weapon.a_s)

    -- Format D (damage)
    local d = (weapon.d_s == 1) and tostring(weapon.d_n) or (weapon.d_n .. "d" .. weapon.d_s)

    -- Format hit
    local bs = weapon.hit or "-"

    -- Format abilities
    local abilities = (weapon.abilities and weapon.abilities ~= "") and ("\n[" .. weapon.abilities .. "]") or ""

    return weapon.name .. "\nA:" .. a .. " BS:" .. bs ..
           " S:" .. tostring(weapon.s) ..
           " AP:" .. tostring(weapon.ap) ..
           " D:" .. d ..
           abilities
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
                    label = formatWeaponLabel(w)
                }
            end

            groups[key].count = groups[key].count + 1
        end
    end

    return groups
end


function resetTargetingState()
    if targetingState.sourceUnit then
        for _, obj in ipairs(targetingState.sourceUnit) do
            obj.highlightOff()
        end
    end

    if targetingState.targetUnits then
        for _, unitList in pairs(targetingState.targetUnits) do
            for _, obj in ipairs(unitList) do
                obj.highlightOff()
            end
        end
    end

    targetingState = {
        sourceGUID = nil,
        sourceUnit = nil,
        targetGUIDs = {},
        targetUnits = {},
        colorMap = {},
        confirmed = false,
        previewing = false
    }

    Global.setVectorLines({})
    clearSpawnedDiceObjects()
end


function clearSpawnedDiceObjects()
    local remaining = {}

    for _, obj in ipairs(spawnedDiceObjects) do
        if obj ~= nil then
            obj.destruct()
        end
    end

    for _, group in pairs(diceGroupsByButtonGUID) do
        if group then
            for _, die in ipairs(group) do
                if die ~= nil then
                    die.destruct()
                end
            end
        end
    end


    if #remaining > 0 then
        log("Some objects could not be destroyed, possibly UI or missing refs.")
    end

    spawnedDiceObjects = {}
    diceGroupsByButtonGUID = {}
    diceGroupButtons = {}
    diceDescriptionByButtonGUID = {}
end


-- Roll the dice expression
function rollDice(numDice, sides, modifier, label)
    local total = 0
    local rolls = {}

    for i = 1, numDice do
        local roll = math.random(1, sides)
        table.insert(rolls, roll)
        total = total + roll
    end

    local rollStr = table.concat(rolls, ", ")
    if sides > 1 then
        broadcastToAll("• Rolled " .. label .. ": [" .. rollStr .. "] = " .. total, {0.8, 1, 0.8})
    end
    return total + modifier
end




function onLoadRollClicked(obj, playerColor)
    local matGUID = nil

    if playerColor == "Red" then
        matGUID = redDiceMat_GUID
    elseif playerColor == "Blue" then
        matGUID = blueDiceMat_GUID
    else
        printToColor("No dice mat assigned for player color: " .. playerColor, playerColor, {1, 0.5, 0.5})
        return
    end

    local mat = getObjectFromGUID(matGUID)
    if not mat then
        printToColor("Dice mat object not found for color: " .. playerColor, playerColor, {1, 0.5, 0.5})
        return
    end

    local oldDice = diceGroupsByButtonGUID[obj.getGUID()]
    local inheritedColor = stringColorToRGB(playerColor)  -- default fallback

    -- Step 1: Capture color and remove placeholder dice
    if oldDice and #oldDice > 0 then
        if oldDice[1] and oldDice[1].getColorTint then
            inheritedColor = oldDice[1]:getColorTint()
        end
        for _, die in ipairs(oldDice) do
            if die and die.destruct then
                die:destruct()
            end
        end
    end
    diceGroupsByButtonGUID[obj.getGUID()] = nil

    -- Step 2: Extract label text
    local labelText = diceDescriptionByButtonGUID[obj.getGUID()]
    if not labelText then
        broadcastToColor("Could not find weapon label near button.", playerColor, {1, 0.3, 0.3})
        return
    end

    -- Step 3: Parse A:# / A:d# / A:#d# format
    local diceExpr = labelText:match("A:([^%s]+)")
    local numDice, sides, modifier = parseDiceExpression((diceExpr or "1"))
    local totalAttacks = rollDice(numDice, sides, modifier, diceExpr)

    -- Step 4: Spawn dice with inherited color
    local spawned = {}
    for i = 1, totalAttacks do
        local die = spawnObject({
            type = "Die_6_Rounded",
            position = {0, 3 + i * 0.2, 0},
            rotation = {0, math.random() * 360, 0},
            scale = {1, 1, 1},
            callback_function = function(obj)
                obj:setColorTint(inheritedColor)
            end
        })
        table.insert(spawned, die)
    end

    -- Step 5: Move dice to the roller
    mat.call("moveDiceToRollerWrapper", {
        playerColor = playerColor,
        dice = spawned
    })

    -- Step 6: Apply weapon UI
    local uiObj = getObjectFromGUID((playerColor == "Red") and redRollerGUID or blueRollerGUID)
    if not uiObj then
        broadcastToColor("⚠️ No UI panel for color: " .. playerColor, playerColor, {1, 0.5, 0.5})
        return
    end

    uiObj.call("applyWeaponLabel", labelText)
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
        table.insert(bbVectorLines, {
            color = c,
            points = {
                {p1.x, p1.y, p1.z},
                {p2.x, p2.y, p2.z}
            },
            thickness = 0.03
        })
    end

    Global.setVectorLines(bbVectorLines)
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
    local delta = (index == 9) and 0.05 or -0.05  -- U raises, I lowers

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

function previewTargeting(playerColor)
    local weaponMap = parseWeaponsByModel(targetingState.sourceUnit, "Ranged")
    local groupedByLabel = {}
    local allVectorLines = {}

    for source, weapons in pairs(weaponMap) do
        for _, weapon in ipairs(weapons) do
            local label = formatWeaponLabel(weapon)
            log(weapon)
            log(label)
            local rangeInches = tonumber(weapon.range)
            if rangeInches then  

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
            end
        end
    end

    Global.setVectorLines(allVectorLines)
    targetingState.confirmed = true
    targetingState.previewing = true
    broadcastToColor("Previewing targeting: press 7 to add/remove source models, or 8 to confirm or clear.", playerColor, {1,1,0})
end


function visualizeWeaponAssignmentGraph(graph, position)
    local lines = {}
    for _, node in ipairs(graph.sourceNodes) do
        table.insert(lines, string.format(
            "%s [%d models] → %s",
            node.weapon.name,
            #node.models,
            table.concat(node.validTargets, ", ")
        ))
    end

    local fullText = table.concat(lines, "\n")

    spawnObject({
        type = "3DText",
        position = position or {0, 3, 0},
        scale = {0.7, 0.7, 0.7},
        callback_function = function(obj)
            obj.TextTool.setValue(fullText)
            obj.TextTool.setFontColor({0.8, 1, 0.8})
            obj.setName("Weapon Assignment Debug")
        end
    })
end


-- Override scripting button down (B = 1, C = 2, K = 3)
-- Override scripting button down (B = 1, C = 2, K = 3)
-- Override scripting button down (B = 1, C = 2, K = 3)
function onScriptingButtonDown(index, playerColor)
    heldButtons[playerColor] = heldButtons[playerColor] or {}
    if index == 7 then  -- 'O' key
        local hoverObj = Player[playerColor].getHoverObject()
    
        if not hoverObj then
            if targetingState.sourceUnit and next(targetingState.targetUnits or {}) then
                broadcastToColor("🔍 Finalizing selection. Parsing weapons and building graph...", playerColor, {1, 1, 0})
                local allTargetModels = {}
                for _, models in pairs(targetingState.targetUnits) do
                    for _, m in ipairs(models) do table.insert(allTargetModels, m) end
                end
    
                local graph = buildWeaponAssignmentGraph(targetingState.sourceUnit, allTargetModels)
                -- Optional: store or visualize it here
                visualizeWeaponAssignmentGraph(graph, {x=0, y=3, z=0})
                spawnAssignmentUIAligned(playerColor, graph)
                targetingState.confirmed = true
                return
            else
                broadcastToColor("⚠️ You must select a source and at least one target before confirming.", playerColor, {1, 0.6, 0.6})
                return
            end
        end
    
        local guid = hoverObj.getGUID()
        local uuid = getUUIDFromTags(hoverObj)
        if not uuid then
            broadcastToColor("⚠️ Object under pointer has no UUID tag.", playerColor, {1, 0.5, 0.5})
            return
        end
    
        -- No source selected yet
        if not targetingState.sourceGUID then
            targetingState.sourceGUID = uuid
            targetingState.sourceUnit = getObjectsWithTag("uuid:" .. uuid)
            broadcastToColor("✅ Source unit selected.", playerColor, {0.5, 1, 0.5})
        
        -- Same as source → invalid target
        elseif uuid == targetingState.sourceGUID then
            broadcastToColor("⚠️ Cannot target the same unit as the source.", playerColor, {1, 0.5, 0.5})
            return
        
        -- Already a selected target → ignore
        elseif targetingState.targetUnits and targetingState.targetUnits[uuid] then
            broadcastToColor("⚠️ Target unit already selected.", playerColor, {1, 0.5, 0.5})
            return
    
        -- New target → add to selection
        else
            targetingState.targetGUIDs = targetingState.targetGUIDs or {}
            targetingState.targetUnits = targetingState.targetUnits or {}
            targetingState.targetGUIDs[#targetingState.targetGUIDs + 1] = uuid
            targetingState.targetUnits[uuid] = getObjectsWithTag("uuid:" .. uuid)
            broadcastToColor("🎯 Added target unit: " .. uuid, playerColor, {1, 0.4, 0.4})
        end
    
        -- Highlight all current selections
        if targetingState.sourceUnit then
            for _, obj in ipairs(targetingState.sourceUnit) do
                obj.highlightOn({0,1,0})
                drawBoundingBox(obj, {0, 1, 0})
            end
        end
    
        if targetingState.targetUnits then
            for _, models in pairs(targetingState.targetUnits) do
                for _, obj in ipairs(models) do
                    obj.highlightOn({1, 0, 0})
                    drawBoundingBox(obj, {1, 0, 0})
                end
            end
        end
    

    elseif index == 8 then  -- Only clear targeting
        if targetingState.previewing then
            resetTargetingState()
            currentHeightMarker = {pos = nil, height = nil}
            broadcastToColor("Cleared selection and targeting preview.", playerColor, {0.8,0.8,0.8})
        
        elseif targetingState.sourceUnit and targetingState.targetUnit then
            previewTargeting(playerColor)
    
        elseif currentHeightMarker.pos and currentHeightMarker.height then
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
            broadcastToColor("Applied height to " .. updated .. " model(s).", playerColor, {0, 1, 0})
    
        else
            resetTargetingState()
            currentHeightMarker = {pos = nil, height = nil}
            broadcastToColor("Cleared selection and height marker.", playerColor, {0.8,0.8,0.8})
        end

    elseif index == 9 or index == 10 then
        heldButtons[playerColor][index] = true
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
                model.use_hands = false
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
    -- load vars from saved
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

    -- original flow
    if allowMenu then
        if allowAutoSeat and redPlayerID ~= "" and bluePlayerID ~= "" then
            autoSeatAll()
        else
            Global.UI.setAttribute("main", "active", "true")
            local presentPersons = Player.getPlayers()
            for i, person in ipairs(presentPersons) do
                person.team = "Diamonds"
            end
            presentPersons = Player.getSpectators()
            for i, person in ipairs(presentPersons) do
                person.team = "Diamonds"
            end
            showHideRedBlueBtn()
        end
    else
        Global.UI.setAttribute("main", "active", "false")
    end
end






function closeDiceCalc(obj, playerColor)
    obj.UI.hide("dice_calc_panel")
    Wait.time(function() obj.destruct() end, 0.5)  -- Optional: delete the UI object
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