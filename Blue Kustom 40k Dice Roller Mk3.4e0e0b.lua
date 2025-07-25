-- FTC-GUID: 4e0e0b,beae28
--Based off: https://steamcommunity.com/sharedfiles/filedetails/?id=726800282
--Link for this mod: https://steamcommunity.com/sharedfiles/filedetails/?id=959360907
lastRolls={}
scaleBtn=3
printLastBtn={
    label="Last roll", click_function="printLast", function_owner=self,
    position={-2.5,0.1,-0.87}, rotation={0,0,0}, height=50, width=400,
    font_size=60, color={0,0,0}, font_color={1,1,1}, scale={scaleBtn,scaleBtn,scaleBtn}
}
printLast5Btn={
    label="Last 5 rolls", click_function="printLast5", function_owner=self,
    position={2.5,0.1,-0.87}, rotation={0,0,0}, height=50, width=400,
    font_size=60, color={0,0,0}, font_color={1,1,1}, scale={scaleBtn,scaleBtn,scaleBtn}
}

function printLast()
	printResults(1)
end

function printLast5()
	printResults(5)
end

function printResults(n)
	if #lastRolls==0 then
		printToAll("NO LAST ROLLS\n", "Yellow")
	else
		printToAll("LAST ROLLS\n")

		-- This little bit of complexity ensures we present the LAST n from
		-- _lastrolls_ and, if asked to present (say) the last 3 out of a table
		-- of 6, number them 3-2-1 despite them being indexes 4-5-6!
		n = math.min(n, #lastRolls)
		first = #lastRolls - n + 1
		for i = first, #lastRolls do
			result = lastRolls[i]
			printToAll("-- " .. #lastRolls - i + 1 .. " --\n" .. result.msg, result.color)
		end
	end
end

--Initialize Global Variables and pRNG Seed
ver = 'BCB-2022-12-30'
lastHolder = {}
customFace = {4, 6, 8, 10, 12, 20}
diceGuidFaces = {}
sortedKeys = {}
resultsTable = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
seedCounter = 0

thisBoxIsBlue = (self.guid == Global.getVar("blueDiceRoller_GUID")) and true or false
seed = os.time() + (thisBoxIsBlue and 1 or 0)
math.randomseed(seed)

orderedOnNextRoll = false
groupSizeOnNextRoll = 1

objectToPlaceDiceOnGUID = thisBoxIsBlue and Global.getVar("blueDiceMat_GUID") or Global.getVar("redDiceMat_GUID")
objectToPlaceDiceOn = getObjectFromGUID(objectToPlaceDiceOnGUID)
if objectToPlaceDiceOn == nil then
    objectToPlaceDiceOn = self
end

-- used to nil out a passed parameter
--   remember, this will leave the parameter itself nil
-- LUA will not clear out globally scoped variables automatically
-- setting each element to nil will allow the gc to clear it out
function clearDataForGC(data)
  if data == nil then
    -- nothing needs to be done, return
    return
  end
  for n, element in ipairs(data) do
    element = nil
  end
end

--Determine the person who put the dice in the box.
function onObjectPickedUp(playerColor, obj)
	lastHolder[obj] = playerColor
end

--Reset the person holding the dice when no dice are held.
function onObjectDestroyed(obj)
	lastHolder[obj] = nil
end

--Reset description on load if empty.
function onLoad(save_state)
	if self.getDescription() == '' then
		setDefaultState()
	end
	self.createButton(printLastBtn)
	self.createButton(printLast5Btn)
end

--Returns description on game save.
function onSave()
	return self.getDescription()
end

--Reset description on drop if empty.
function onDropped(player_color)
	if self.getDescription() == '' then
		setDefaultState()
	end
end

--Sets default description.
function setDefaultState()
	self.setDescription(JSON.encode_pretty({Results = 'no', SmoothDice = 'no', RotateDice = 'no', Rows = 'yes', SortNoRows = 'asc', Step = 1.05, Version = ver}))
end

--Creates a table and sorts the dice guids by value.
function sortByVal(t, type)
	local keys = {}
	for key in pairs(t) do
		table.insert(keys, key)
	end
	if type == 'asc' then
		table.sort(keys, function(a, b) return t[a] < t[b] end)
	elseif type == 'desc' then
		table.sort(keys, function(a, b) return t[a] > t[b] end)
	end
	return keys
end

--Checks the item dropped in the bag has a guid.
function hasGuid(t, g)
	for k, v in ipairs(t) do
		if v.guid == g then return true end
	end

	return false
end

--Runs when non-dice is put into bag
function onObjectEnterContainer(container, obj)
    if container == self then
        if obj.tag == "Dice" then
            collision_info = {collision_object = obj}
            onCollisionEnter(collision_info)

            --Creates a timer to take the dice out and position them.
        	Wait.time(|| takeDiceOut(), 0.3)
        else
            local pos = self.getPosition()
            local f = self.getTransformRight()
            self.takeObject({
                position          = {pos.x+20,pos.y+50,pos.z+20},
                smooth            = false,
            })
        end
    end
end

--Runs when an object is dropped in bag.
function onCollisionEnter(collision_info)
	playerColor = lastHolder[collision_info.collision_object]
	if collision_info.collision_object.getGUID() == nil then return end
    clearDataForGC(diceGuidFaces)
    clearDataForGC(sortedKeys)
	diceGuidFaces = {}
	sortedKeys = {}

    -- Save number of faces on dice
	for k, v in ipairs(getAllObjects()) do
		if v.tag == 'Dice' then
			objType = tostring(v)
			faces = tonumber(string.match(objType, 'Die_(%d+).*'))
			if faces == nil then
				faces = tonumber(customFace[v.getCustomObject().type + 1])
			end
            diceGuidFaces[v.getGUID()] = faces
            table.insert(sortedKeys, v.getGUID())
		end
	end

--[[Benchmarking code
if resetclock ~= 1 then
clockstart = os.clock()
resetclock = 1
end--]]

end

--Function to take the dice out of the bag and position them.
function takeDiceOut(tab)
	local data = JSON.decode(self.getDescription())
	if data == nil then
		setDefaultState()
		data = JSON.decode(self.getDescription())
		printToAll('Warning - invalid description. Restored default configuration.', {0.8, 0.5, 0})
	end

	if data.Step < 1 then
		setDefaultState()
		data = JSON.decode(self.getDescription())
		printToAll('Warning - "step" can\'t be lower than 1. Restored default configuration.', {0.8, 0.5, 0})
	end

    clearDataForGC(diceGuids)
	diceGuids = {}
	for k, v in pairs(self.getObjects()) do
		faces = diceGuidFaces[v.guid]
		if v.name =="BCB-D3" then
			faces=3
		end
		r = math.random(faces)
		diceGuids[v.guid] = r
	end

	local ordered = orderedOnNextRoll
	orderedOnNextRoll = false
	local groupSize = groupSizeOnNextRoll
	groupSizeOnNextRoll = 1

	local objs = self.getObjects()
	local position = objectToPlaceDiceOn.getPosition()
	rotation = objectToPlaceDiceOn.getRotation()
	local displayInRows = true
	if data.Rows == 'no' then displayInRows = false end
	if ordered then displayInRows = false end
	local sortType = data.SortNoRows
	if ordered then sortType = "none" end
	sortedKeys = sortByVal(diceGuids, sortType)
    clearDataForGC(Rows)
	Rows = {}
	n = 1

	for _, key in pairs(sortedKeys) do
		if diceGuids[key] == math.floor(diceGuids[key]) then
			resultsTable[diceGuids[key]] = resultsTable[diceGuids[key]] + 1
		end

    	if hasGuid(objs, key) then
    		if Rows[diceGuids[key]] == nil then
    			Rows[diceGuids[key]] = 0
    		end
    		Rows[diceGuids[key]] = Rows[diceGuids[key]] + 1
    		params = {}
    		params.guid = key
    		local d12Xoffset=0
    		if diceGuids[key]>6 then
    			 d12Xoffset=-24
    		end

            local newXPos
            local newZPos
            if displayInRows then
				-- Dice should be displayed next to the 1-6 buttons according to their values.
				newXPos = 0 - d12Xoffset - 20.4 + (Rows[diceGuids[key]]* data.Step)
				newZPos = -3.17 + ((((diceGuids[key] - 1) % 6) + 1) * data.Step)
            else
				-- Dice should simply be in one big group.
				local pos = n - 1
				local limit = 25
				if groupSize > 1 then
					-- We want subgroups of size _step_, with a gap between each subgroup.
					pos = pos + math.floor(pos / groupSize)
					local step = groupSize + 1
					local maxGroups = math.floor(limit / step)
					local remainder = limit % (step * maxGroups)
					limit = limit - remainder
				end
				row = math.floor(pos / limit) + 1
				col = pos % limit
				newXPos = 0 - 15.0 + (col * data.Step)
				newZPos = -3.17 + (row * data.Step)
            end

			-- Having calculated X and Z relative to the default rotation of the dice mat,
			-- now recalculate them according to the actual rotation.
			params.position = {
				position.x + (newXPos * math.cos((180 + rotation.y) * 0.0174532)) - (newZPos * math.sin((180 + rotation.y) * 0.0174532)),
				position.y + 2,
				position.z + (newXPos * math.sin((rotation.y) * 0.0174532)) + (newZPos* math.cos((0 + rotation.y) * 0.0174532))
			}
            params.rotation = rotation
    		params.callback = 'setValueCallback'
    		params.params = {diceGuids[key]}
    		params.smooth = false
    		if data.SmoothDice == 'yes' then params.smooth = true end

    		self.takeObject(params)
    		n = n + 1
    	end
    end

	printresultsTable()
--[[Benchmarking code
	clockend = os.clock()
	resetclock=0
	print('Runtime: ' .. clockend-clockstart .. ' seconds.')--]]
end

--Function to count resultsTable for printing.
function sum(t)
	local sum = 0
	for k, v in pairs(t) do
		sum = sum + v
	end

	return sum
end

function setPlayerColor(params)
    playerColor = params.color
end

function setLastHolder(params)
    lastHolder[params.obj] = params.color
end

--Prints resultsTable.
function printresultsTable()
	local data = JSON.decode(self.getDescription())
	local description = {'Ones.', 'Twos.', 'Threes.', 'Fours.', 'Fives.', 'Sixes.', 'Sevens.', 'Eights.', 'Nines.', 'Tens.', 'Elevens.', 'Twelves.', 'Thirteens.', 'Fourteens.', 'Fifteens.', 'Sixteens.', 'Seventeens', 'Eighteens.', 'Nineteens.', 'Twenties.'}
	local msg = ''
	local color={1,1,1}
	for dieFace, numRolled in ipairs(resultsTable) do
		if numRolled > 0 then
			msg = msg .. numRolled .. ' ' .. description[dieFace] .. ' '
		end
	end

	local time = '[' .. os.date("%H") .. ':' .. os.date("%M") .. ':' .. os.date("%S") .. ' UTC] '
	if playerColor == nil then
		msg=time .. '~UNKNOWN PLAYER~ rolls:\n' .. msg .. '*******************************************************'
	else
		msg=time .. Player[playerColor].steam_name .. ' rolls:\n' .. msg .. '*******************************************************'
		color=stringColorToRGB(playerColor)
	end
	local rolltorecord={msg=msg, color=color}
	if sum(resultsTable) > 0 then
		if #lastRolls >= 5 then
			table.remove(lastRolls, 1)
		end
		table.insert(lastRolls, #lastRolls+1, rolltorecord)
	end

	if sum(resultsTable) > 0 and data.Results == 'yes' then
		printToAll(msg, color)
	end

	for k,v in ipairs(resultsTable) do
		resultsTable[k] = 0
	end
end

--Sets the value of the physical dice object and reorients them if needed.
function setValueCallback(obj, tab)
    local rotValues = obj.getRotationValues()
	obj.setRotation(rotValues[tab[1]].rotation + Vector(0, 180.0 + objectToPlaceDiceOn.getRotation()[2], 0))
end