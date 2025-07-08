toggleButtonIndices = {}

inputStates = {}

inputIndices = {}



handlersInitialized = false

-- Updated tracked vars
local inputVars = {
    "bs", "s", "ap", "d", "hit_mod",
    "sustained_hits", "crit_hit", "wound_mod",
    "anti_val",  -- was anti_vehicle, anti_monster, anti_infantry
    "t"
}

local toggleVars = {
    "lethal_hits", "reroll_all", "reroll_1s",
    "devastating_wounds",
    "anti_active"  -- new toggle for whether target has matching keyword
}

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


function applyWeaponLabel(labelText)
    local stats = extractStatBlock(labelText)

    -- Apply base stats only if tracked
    if stats.hit and inputVars["bs"] then updateInput("bs", stats.hit:gsub("%D", "")) end
    if stats.s and inputVars["s"] then updateInput("s", tostring(stats.s)) end
    if stats.ap and inputVars["ap"] then updateInput("ap", tostring(stats.ap)) end
    if stats.d and inputVars["d"] then updateInput("d", tostring(stats.d)) end

    -- Parse abilities inside brackets
    local abilBlock = labelText:match("%[(.-)%]")
    if abilBlock then
        for ability in abilBlock:gmatch("[^,%]]+") do
            local trimmed = ability:gsub("^%s*", ""):gsub("%s*$", "")
            local lowerTrimmed = trimmed:lower()

            -- Sustained Hits X
            local shVal = trimmed:match("Sustained Hits%s*(%d+)")
            if shVal and inputVars["sustained_hits"] then
                updateToggle("sustained_hits", true)
            end

            -- Devastating Wounds
            if lowerTrimmed == "devastating wounds" and toggleVars["devastating_wounds"] then
                updateToggle("devastating_wounds", true)

            -- Rapid Fire N
            elseif trimmed:match("Rapid Fire%s*%d+") and toggleVars["lethal_hits"] then
                -- Only toggle if you use 'lethal_hits' for this or want to add a new key
                updateToggle("lethal_hits", true)

            -- Ignores Cover → not tracked
            -- Psychic → not tracked
            -- Anti-X Y+
            elseif trimmed:match("Anti%-%a+ %d+%+") then
                local antiVal = trimmed:match("(%d+)%+")
                if antiVal and inputVars["anti_val"] then
                    updateInput("anti_val", antiVal)
                    if toggleVars["anti_active"] then
                        updateToggle("anti_active", true)
                    end
                end
            end
        end
    end
end

function updateInput(var, val)
    log("update input")
    log(var)
    log(val)

    local index = inputIndices[var]
    if index then
        log("✏️ Editing input at index: " .. tostring(index) .. " with value: " .. tostring(val))
        self.editInput({index = index, value = val})
        inputStates[var] = val
    end
end



-- Final Action
function onRollPressed(obj, color)
    print(color .. " pressed ROLL!")
    print("Inputs:")
    for _, v in ipairs(inputVars) do
        print(v .. " = " .. tostring(_G[v]))
    end
    print("Toggles:")
    for k, v in pairs(toggleStates) do
        print(k .. " = " .. tostring(v))
    end
end

-- INPUT GENERATORS
function makeInputHandler(varName)
    _G["handleInput_" .. varName] = function(obj, playerColor, input)
        -- Sanitize to only allow integers (optional minus)
        local sanitized = input:match("^-?%d+") or ""
        inputStates[varName] = sanitized
        print("Input for " .. varName .. ": " .. sanitized)

        local index = inputIndices[varName]
        if index then
            -- First pass: clear immediately
            obj.editInput({
                index = index,
                value = ""
            })

            -- Second pass: write correct value after flush
            Wait.time(function()
                obj.editInput({
                    index = index,
                    value = sanitized
                })
            end, 0)

            -- Optional: another pass for stability (remove if unnecessary)
            Wait.time(function()
                obj.editInput({
                    index = index,
                    value = sanitized
                })
            end, 0.1)
        else
            print("⚠️ No input index for: " .. varName)
        end
    end
end







-- TOGGLE GENERATORS
function makeToggleHandler(varName)
    _G["toggle_" .. varName] = function(obj, color)
        toggleStates[varName] = not toggleStates[varName]

        local index = toggleButtonIndices[varName]
        if index then
            obj.editButton({
                index = index,
                color = toggleStates[varName] and {0.2, 0.6, 0.4} or {0.2, 0.2, 0.2},
                font_color = toggleStates[varName] and {0.4, 0.8, 1.0} or {0.4, 0.8, 1.0}
            })
        else
            print("⚠️ Could not find button index for toggle: " .. varName)
        end

        print((toggleStates[varName] and "Enabled: " or "Disabled: ") .. varName)
    end
end


-- Enhanced physical UI layout for Warhammer Dice Calculator
toggleStates = {}

function addFullPhysicalUI(obj)
    local zOffset = 2
    obj.clearButtons()
    obj.clearInputs()

    local y = 1.0
    local dy = 1.5
    local xSpacing = 1.9
    local sectionLabelX = -6

    local function input(label, varName, x, z)
        obj.createButton({
            label = label, click_function = "do_nothing", function_owner = self,
            position = {x, 0.3, z + zOffset + 0.5}, width = 0, height = 0,
            font_size = 120, alignment = 3, font_color = {0.4, 0.8, 1.0}
        })
    
        local index = obj.getInputs() and #obj.getInputs() or 0
    
        obj.createInput({
            input_function = "handleInput_" .. varName, function_owner = self,
            label = "", alignment = 3, tooltip = label,
            position = {x, 0.3, z + zOffset}, rotation = {0, 0, 0},
            width = 800, height = 180, font_size = 120
        })
    
        -- Store index for this var
        inputIndices[varName] = index
    end
    
    
    local function toggle(label, varName, x, z)
        toggleStates[varName] = false
        local index = obj.getButtons() and #obj.getButtons() or 0
    
        obj.createButton({
            label = label,
            click_function = "toggle_" .. varName,
            function_owner = self,
            position = {x, 0.3, z + zOffset},
            rotation = {0, 0, 0},
            width = 800,
            height = 350,
            font_size = 130,
            alignment = 3,
            color = {0.2, 0.2, 0.2},       -- Charcoal gray (off state)
            font_color = {0.4, 0.8, 1.0}   -- Light gray text
        })
    
        toggleButtonIndices[varName] = index
    end
    

    local function row(label, fields, toggles)
        obj.createButton({
            label = label,
            click_function = "do_nothing",
            function_owner = self,
            position = {sectionLabelX, 0.3, y + zOffset},
            height = 0,
            width = 0,
            font_size = 220,
            alignment = 3,
            font_color = {0.4, 0.8, 1.0}     -- light gray on black
        })

        for i, field in ipairs(fields) do
            input(field.label, field.var, xSpacing * (i - 2.8), y)
        end

        if toggles then
            for i, tog in ipairs(toggles) do
                toggle(tog.label, tog.var, xSpacing * (#fields + i - 2.8), y)
            end
        end

        y = y - dy
    end

    -- Build each row with section label on the left
    row("Attack Stats", {
        {label = "BS/WS", var = "bs"},
        {label = "S", var = "s"},
        {label = "AP", var = "ap"},
        {label = "D", var = "d"}
    })

    row("Hit Phase", {
        {label = "Hit Mod", var = "hit_mod"},
        {label = "Sustained", var = "sustained_hits"},
        {label = "Crit Hit", var = "crit_hit"}
    }, {
        {label = "Lethal Hits", var = "lethal_hits"},
        {label = "Reroll All", var = "reroll_all"},
        {label = "Reroll 1s", var = "reroll_1s"}
    })

    row("Wound Phase", {
        {label = "Wound Mod", var = "wound_mod"},
        {label = "Anti-X", var = "anti_val"}
    }, {
        {label = "Anti Active", var = "anti_active"},
        {label = "Devastating", var = "devastating_wounds"}
    })
    

    row("Defense", {
        {label = "Tough", var = "t"}
    })

    obj.createButton({
        label = "Roll!", click_function = "onRollPressed", function_owner = self,
        position = {0, 0.3, y + 1}, rotation = {0, 0, 0},
        width = 1400, height = 400, font_size = 260, alignment = 3,
        color = {0.8, 0.2, 0.2},      -- Rich red
        font_color = {1, 1, 1}
    })
    

    if not handlersInitialized then
        for _, name in ipairs(inputVars) do makeInputHandler(name) end
        for _, name in ipairs(toggleVars) do makeToggleHandler(name) end
        handlersInitialized = true
    end
end






function do_nothing() end

function onLoad()
    addFullPhysicalUI(self)

    if not handlersInitialized then
        for _, name in ipairs(inputVars) do makeInputHandler(name) end
        for _, name in ipairs(toggleVars) do makeToggleHandler(name) end
        handlersInitialized = true
    end
end