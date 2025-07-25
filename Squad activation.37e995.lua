-- FTC-GUID: 229946,bcf2a4,37e995


BCBtype="ActivationToken"
alreadyActed=false
mini_GUID=""
mini=nil
btnY=3
btnYstep=7


statusBtn={ label="", tooltip="LMB toggle\nNumpad 1 lower\nNumpad 2 raise", click_function="toggleStatus", function_owner=self,
            position={0,3,0}, rotation={0,180,0}, height=600, width=600,
            font_size=250, color="Red", font_color={1,1,1}
}

linkMiniBtn={ label="Link", click_function="linkMini", function_owner=self,
            position={0,1,-1}, rotation={0,180,0}, height=200, width=300,
            font_size=100, color={0,0,0}, font_color={1,1,1}
}

function onSave()
    saved_data = JSON.encode({
                                svalreadyActed=alreadyActed,
                                svbtnY=btnY,
                                svmini_GUID=mini_GUID})
    return saved_data
end

function onload(saved_data)
    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        alreadyActed = loaded_data.svalreadyActed
        btnY=loaded_data.svbtnY
    end
--    print("btnY "..btnY)
    -- btnY=3
    writeMenu()
end




function writeMenu()
    self.clearButtons()
    if alreadyActed then
        statusBtn.color="Red"
    else
        statusBtn.color="Green"
    end
    statusBtn.position[2]=btnY
    self.createButton(statusBtn)
    --self.createButton(linkMiniBtn)
end

function setAlredyActed()
    alreadyActed= true
    writeMenu()
end

function resetAlredyActed()
    alreadyActed= false
    writeMenu()
end

function toggleStatus(obj, player, alt)
    if not alt then
        alreadyActed= not alreadyActed
    end
    writeMenu()
end

function onScriptingButtonDown(index, player_color)
    selectedObjects = Player[player_color].getSelectedObjects()
    if Player[player_color].getHoverObject() == self or (selectedObjects and selectedObjects[1] == self) then
        if index==2 then
            btnY=btnY+btnYstep
            if btnY>btnYstep*7 then btnY=3 end
        end
        if index==1 then
            btnY=btnY-btnYstep
            if btnY<3 then btnY=3 end
        end
        writeMenu()
    end
end

function linkMini()
end