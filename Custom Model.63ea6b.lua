toggleButtonIndices = {}

inputStates = {}

inputIndices = {}



handlersInitialized = false

-- Updated tracked vars
local inputVars = {
    "a_n", "a_s", "a_mod", "reroll_threshold",
    "bs", "s", "ap", "d", "hit_mod",
    "sustained_hits", "crit_hit", "wound_mod",
    "anti_val",  -- was anti_vehicle, anti_monster, anti_infantry
    "t"
}

local toggleVars = {
    "blast", "reroll_nattacks",
    "lethal_hits", "reroll_hits", "reroll_hit_1", 
    "devastating_wounds","reroll_wounds", "reroll_wound_1",
    "anti_active"  -- new toggle for whether target has matching keyword
}

defaultInputs = {
    a_n = "1", a_s = "1", a_mod = "0", reroll_threshold = "3",
    bs = "", s = "", ap = "", d = "",
    hit_mod = "0", sustained_hits = "0", crit_hit = "6",
    wound_mod = "0", anti_val = "",
    t = ""
}

defaultToggles = {
    blast = false,
    reroll_nattacks = false,
    lethal_hits = false,
    reroll_hit_1 = false,
    reroll_hits = false,
    anti_active = false,
    devastating_wounds = false,
    reroll_wound_1 = false,
    reroll_wounds = false
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


function applyWeaponStats(params)
    local weapon = params.weapon
    local target = params.target


    -- Reset all inputs to default values
    for var, def in pairs(defaultInputs) do
        if inputIndices[var] then
            updateInput(var, def)
        end
    end

    -- Reset all toggles to false
    for var, def in pairs(defaultToggles) do
        updateToggle(var, def)
    end

    -- Base stats
    if weapon.a_n and inputIndices["a_n"] then updateInput("a_n", tostring(weapon.a_n)) end
    if weapon.a_s and inputIndices["a_s"] then updateInput("a_s", tostring(weapon.a_s)) end
    if weapon.a_mod and inputIndices["a_mod"] then updateInput("a_mod", tostring(weapon.a_mod)) end
    if weapon.hit and inputIndices["bs"] then updateInput("bs", tostring(weapon.hit)) end
    if weapon.s and inputIndices["s"] then updateInput("s", tostring(weapon.s)) end
    if weapon.ap and inputIndices["ap"] then updateInput("ap", tostring(weapon.ap)) end
    if weapon.d_n and inputIndices["d"] then updateInput("d", tostring(weapon.d_n)) end



    if target and target.toughness and inputIndices["t"] then
        updateInput("t", tostring(target.toughness))
    end
    

    log(weapon)

    -- Optional ability flags
    local abilities = weapon.abilities:lower()  
    local sustainedVal = abilities:match("sustained hits%s*(%d+)")
    if sustainedVal then
        updateInput("sustained_hits", sustainedVal)
    end


    if abilities:find("devastating wounds") then
        updateToggle("devastating_wounds", true)
    end


    -- Match Anti abilities like: "Anti-Infantry 2+", "Anti-Monster 4+", etc.
    local antiKeyword, antiVal = abilities:match("anti%-(%a+)%s+(%d+%+)")
    if antiKeyword and antiVal then
        -- Check if the target has the relevant keyword
        if target and target.keywords then
            for _, kw in ipairs(target.keywords) do
                if kw:lower() == antiKeyword:lower() then
                    updateInput("anti_val", antiVal)
                    updateToggle("anti_active", true)
                    break
                end
            end
        end
    end


    if abilities:find("lethal") then
        updateToggle("lethal_hits", true)
    end

    if abilities:find("twin-linked") then
        updateToggle("reroll_wounds", true)
    end

    if abilities:find("blast") then
        updateToggle("blast", true)
    end
    
end


function applyWeaponLabel(labelText)
    local stats = extractStatBlock(labelText)


    -- 🔄 Reset all inputs to their default values
    for var, def in pairs(defaultInputs) do
        if inputIndices[var] then
            updateInput(var, def)
        end
    end

    -- 🔄 Reset all toggles to false
    for var, def in pairs(defaultToggles) do
        updateToggle(var, def)
    end


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


function updateToggle(var, val)
    log("update input")
    log(var)
    log(val)

    local index = toggleButtonIndices[var]
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
        print(v .. " = " .. tostring(inputStates[v]))
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

-- TOGGLE GENERATORS
-- Clean version
function updateToggle(var, val)
    toggleStates[var] = val

    local index = toggleButtonIndices[var]
    if index then
        self.editButton({
            index = index,
            color = val and {0.2, 0.6, 0.4} or {0.2, 0.2, 0.2},
            font_color = {0.4, 0.8, 1.0}
        })
    end
end


-- Enhanced physical UI layout for Warhammer Dice Calculator
toggleStates = {}

function addFullPhysicalUI(obj)
    local zOffset = 2
    obj.clearButtons()
    obj.clearInputs()

    local y = 2.0
    local dy = 1.5
    local xSpacing = 1.9
    local sectionLabelX = -6

    local function input(label, varName, defaultValue, x, z)
        obj.createButton({
            label = label, click_function = "do_nothing", function_owner = self,
            position = {x, 0.3, z + zOffset + 0.5}, width = 0, height = 0,
            font_size = 120, alignment = 3, font_color = {0.4, 0.8, 1.0}
        })
    
        local index = obj.getInputs() and #obj.getInputs() or 0
        
        obj.createInput({
            input_function = "handleInput_" .. varName, function_owner = self,
            label = defaultValue, value = defaultValue, alignment = 3, tooltip = label,
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
            input(field.label, field.var, field.defaultValue, xSpacing * (i - 2.8), y)
        end

        if toggles then
            for i, tog in ipairs(toggles) do
                toggle(tog.label, tog.var, xSpacing * (#fields + i - 2.8), y)
            end
        end

        y = y - dy
    end


    row("# Of Attacks", {
        {label = "# Dice", var = "a_n", defaultValue = "1"},
        {label = "# Sides", var = "a_s", defaultValue = "1"},
        {label = "Attack Mod", var = "a_mod", defaultValue = "0"},
        {label = "Reroll Threshold", var = "reroll_threshold", defaultValue = "3"}
    }, {
        {label = "Blast", var = "blast"},
        {label = "Reroll", var = "reroll_nattacks"}
    })

    -- Build each row with section label on the left
    row("Attack Stats", {
        {label = "BS/WS", var = "bs"},
        {label = "S", var = "s"},
        {label = "AP", var = "ap"},
        {label = "D", var = "d"}
    })

    row("Hit Phase", {
        {label = "Hit Mod", var = "hit_mod", defaultValue = "0"},
        {label = "Sustained", var = "sustained_hits", defaultValue = "0"},
        {label = "Crit On", var = "crit_hit", defaultValue = "6"}
    }, {
        {label = "Lethal Hits", var = "lethal_hits"},
        {label = "Reroll 1s", var = "reroll_hit_1"},
        {label = "Reroll All", var = "reroll_hits"}
        
    })

    row("Wound Phase", {
        {label = "Wound Mod", var = "wound_mod", defaultValue = "0"},
        {label = "Anti-X", var = "anti_val", defaultValue = ""}
    }, {
        {label = "Anti Active", var = "anti_active"},
        {label = "Devastating", var = "devastating_wounds"},
        {label = "Reroll 1s", var = "reroll_wound_1"},
        {label = "Reroll All", var = "reroll_wounds"}
    })
    

    row("Defense", {
        {label = "Tough", var = "t", defaultValue = ""}
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