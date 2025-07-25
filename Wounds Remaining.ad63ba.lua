-- FTC-GUID: ad63ba,2e4f26,5fd19f



wounds=10
mini_GUID=""
mini=nil
btnY=3
btnYstep=7


woundsBtn={ label=wounds, tooltip="LMB -\nRMB +\nNumpad 1 lower\nNumpad 2 raise" ,click_function="modifyWounds", function_owner=self,
            position={0,3,0}, rotation={0,180,0}, height=600, width=600,
            font_size=400, color="Grey", font_color="Red"
}

linkMiniBtn={ label="Link", click_function="linkMini", function_owner=self,
            position={0,1,-1}, rotation={0,180,0}, height=200, width=300,
            font_size=100, color={0,0,0}, font_color={1,1,1}
}

function onSave()
    saved_data = JSON.encode({
                                svwounds=wounds,
                                svbtnY=btnY,
                                svmini_GUID=mini_GUID})
    return saved_data
end

function onload(saved_data)
    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        alreadyActed = loaded_data.svalreadyActed
        btnY=loaded_data.svbtnY
        wounds=loaded_data.svwounds
    end
    writeMenu()
end

function writeMenu()
    self.clearButtons()
    woundsBtn.position[2]=btnY
    woundsBtn.label=wounds
    if wounds== 6 or wounds == 9 then
        woundsBtn.label=" "..wounds.."."
    end
    self.createButton(woundsBtn)
    --self.createButton(linkMiniBtn)
end

function modifyWounds(obj, player, alt)
    if not alt then
        wounds=wounds-1
    else
        wounds=wounds+1
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