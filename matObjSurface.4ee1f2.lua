-- FTC-GUID: 4ee1f2
-- MAT obj_surface
version=2.02
function onLoad()
    flexControl = getObjectFromGUID(Global.getVar("flexControl_GUID"))
    gameMenu= getObjectFromGUID(Global.getVar("startMenu_GUID"))
    self.interactable=false
    Wait.time(refresh, 0.05)
    --showMenu()
end

function refresh()
    flexControl.call('refreshSurface')
    if gameMenu ~= nil then
        gameMenu.call('refreshMat')
    end
end

btnHeight=2500
btnWidth=7000
btnXPos=28
btnYPos=11
btnZPos=9
deleteBtn={
    index=1, label="REMOVE\nterrain", click_function="deleteTerrain", function_owner=self,
    position={btnXPos,btnYPos,-btnZPos}, scale={1,1,0.66}, rotation={0,270,0}, height=btnHeight, width=btnWidth,
    font_size=800, color={0.5,0.5,0.5}, font_color={0.8,0,0}
}
confirmBtn={
    index=1, label="CONFIRM\nterrain", click_function="confirmTerrain", function_owner=self,
    position={btnXPos,btnYPos,btnZPos},scale={1,1,0.66}, rotation={0,270,0}, height=btnHeight, width=btnWidth,
    font_size=800, color={0,0.6,0}, font_color={1,1,1}
}

terrainAreaData={
        type = "ScriptingTrigger",
        position          = {x=12, y=10, z=0},
        rotation          = {x=0, y=0, z=0},
        scale             = {x=96, y=40, z=48},
        sound             = false,
        snap_to_grid      = false,
    }


function showMenu()
    showMenu2()
end

function showMenu2()
    self.clearButtons()
    self.createButton(confirmBtn)
    self.createButton(deleteBtn)
end

function confirmTerrain()
    self.clearButtons()
end

function deleteTerrain()
    deleteTerrain1()
end

function deleteTerrain1()
    local customInfo = self.getCustomObject()
    customInfo.diffuse = ""
    self.setCustomObject(customInfo)
    self = self.reload()
    terrainArea= spawnObject(terrainAreaData)
    Wait.frames(deleteTerrain2, 2)
end

function deleteTerrain2()
    local objList=terrainArea.getObjects()
    for i, obj in ipairs(objList) do
        if obj.getVar("BCBtype") == "terrain" then
            obj.destroy()
        end
    end
    terrainArea.destroy()
    setDefaultLights()
    self.clearButtons()
end

function setDefaultLights()
    local lightEquatorColor={r=0.5, g=0.5, b=0.5}
    local lightGroundColor={r=0.5, g=0.5, b=0.5}
    local lightSkyColor={r=0.5, g=0.5, b=0.5}
    local lightColor={r=1, g=0.98, b=0.89}
    local lightAmbientType=1
    local lightAmbientIntensity=1.3
    local lightLightIntensity=0.54
    local lightReflectionIntesity=1
    if lightEquatorColor ~= nil then
        Lighting.setAmbientEquatorColor(lightEquatorColor)
    end
    if lightGroundColor ~= nil then
        Lighting.setAmbientGroundColor(lightGroundColor)
    end
    if lightSkyColor ~= nil then
        Lighting.setAmbientSkyColor(lightSkyColor)
    end
    if lightColor ~= nil then
        Lighting.setLightColor(lightColor)
    end
    if lightAmbientType ~= nil then
        Lighting.ambient_type = lightAmbientType
    end
    if lightAmbientIntensity ~= nil then
        Lighting.ambient_intensity = lightAmbientIntensity
    end
    if lightLightIntensity ~= nil then
        Lighting.light_intensity = lightLightIntensity
    end
    if lightReflectionIntesity ~= nil then
        Lighting.reflection_intensity = lightReflectionIntesity
    end
    Lighting.apply()
end

function none()
end