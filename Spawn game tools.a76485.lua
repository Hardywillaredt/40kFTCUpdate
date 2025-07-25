-- FTC-GUID: a76485

Ypos=6
Xoffset=-70



XposReset=115.2
ZposReset=15.75
resetBtnLbl="Reset Activation tokens\n(auto at phase change)"
resetBtnR={ label=resetBtnLbl, click_function="resetTokens", function_owner=self,
            position={XposReset,Ypos,ZposReset}, rotation={0,0,0},
            height=500, width=2400,
            font_size=200, color="White", font_color={0,0,0}
}
resetBtnB={ label=resetBtnLbl, click_function="resetTokens", function_owner=self,
            position={XposReset+Xoffset,Ypos,-ZposReset}, rotation={0,180,0},
            height=500, width=2400,
            font_size=200, color="White", font_color={0,0,0}
}

activationWoundsOffset=5
activationWoundsOffsetWidth=1800
activationWoundsOffsetWidthFontSize=200
XposSpawnA=XposReset-activationWoundsOffset
ZposSpawnA=ZposReset
spawnABtnLbl="Spawn Activation\ntoken"
spawnActivationBtnR={label=spawnABtnLbl, click_function="spawnActivation", function_owner=self,
            position={XposSpawnA,Ypos,ZposSpawnA}, rotation={0,0,0},
            height=500, width=activationWoundsOffsetWidth,
            font_size=activationWoundsOffsetWidthFontSize, color={0,0,0}, font_color={1,1,1}
        }
spawnActivationBtnB={label=spawnABtnLbl, click_function="spawnActivation", function_owner=self,
            position={XposSpawnA+Xoffset,Ypos,-ZposSpawnA}, rotation={0,180,0},
            height=500, width=activationWoundsOffsetWidth,
            font_size=activationWoundsOffsetWidthFontSize, color={0,0,0}, font_color={1,1,1}
        }

XposSpawnW=XposReset+activationWoundsOffset
ZposSpawnW=ZposSpawnA
spawnWBtnLbl="Spawn Wound\ntoken"
spawnWoundsBtnR={label=spawnWBtnLbl, click_function="spawnWounds", function_owner=self,
            position={XposSpawnW,Ypos,ZposSpawnW}, rotation={0,0,0},
            height=500, width=activationWoundsOffsetWidth,
            font_size=activationWoundsOffsetWidthFontSize, color={0,0,0}, font_color={1,1,1}
        }
spawnWoundsBtnB={label=spawnWBtnLbl, click_function="spawnWounds", function_owner=self,
            position={XposSpawnW+Xoffset,Ypos,-ZposSpawnW}, rotation={0,180,0},
            height=500, width=activationWoundsOffsetWidth,
            font_size=activationWoundsOffsetWidthFontSize, color={0,0,0}, font_color={1,1,1}
        }


XposHideArmy = XposReset+3
ZposHideArmy = ZposReset-2.5
hideShowArmyBtnLbl="ARMY\nfor reserves/embarked"
hideArmyBtnR={ label="HIDE "..hideShowArmyBtnLbl, click_function="hideArmyR", function_owner=self,
            position={XposHideArmy,Ypos,ZposHideArmy}, rotation={0,0,0},
            height=500, width=2400,
            font_size=200, color="Red", font_color={1,1,1}
}
hideArmyBtnB={ label="HIDE "..hideShowArmyBtnLbl, click_function="hideArmyB", function_owner=self,
            position={XposHideArmy+Xoffset,Ypos,-ZposHideArmy}, rotation={0,180,0},
            height=500, width=2400,
            font_size=200, color="Red", font_color={1,1,1}
}

showArmyBtnR={ label="SHOW "..hideShowArmyBtnLbl, click_function="showArmyR", function_owner=self,
            position={XposHideArmy-6,Ypos,ZposHideArmy}, rotation={0,0,0},
            height=500, width=2400,
            font_size=200, color="Green", font_color={1,1,1}
}
showArmyBtnB={ label="SHOW "..hideShowArmyBtnLbl, click_function="showArmyB", function_owner=self,
            position={XposHideArmy+Xoffset-6,Ypos,-ZposHideArmy}, rotation={0,180,0},
            height=500, width=2400,
            font_size=200, color="Green", font_color={1,1,1}
}

linkMiniBtn={ label="Link", click_function="linkMini", function_owner=self,
            position={0,1,-2}, rotation={0,180,0}, height=200, width=300,
            font_size=100, color={0,0,0}, font_color={1,1,1}
}
instructionsLbl="Instructions on the\n'Gaming instuctions' panel"
instructionsRBtn={ label=instructionsLbl, click_function="none", function_owner=self,
            position={XposReset,Ypos,ZposReset-1.2},  rotation={0,0,0},
            height=0, width=0,
            font_size=190, color="Green", font_color={1,1,1}
}
instructionsBBtn={ label=instructionsLbl, click_function="resetTokens", function_owner=self,
            position={XposReset+Xoffset,Ypos,-ZposReset+1.2}, rotation={0,180,0},
            height=0, width=0,
            font_size=190, color="Green", font_color={1,1,1}
}

function webRequestCallback(webReturn)
    print("Web Request Returned")
    print(webReturn.is_done)
    print(webReturn.text)
    local sec_data = JSON.decode(web_data.text)

    local version_data = sec_data.ver
    local secNames = sec_data.names
    --printToAll("\n\nVersion "..version_data, "Orange")
end

function printData(table)
    for i, thing in ipairs(table) do
        print(i.."  "..thing)
    end
end

function onLoad()
    self.setName("Spawn game tools")
    self.setPosition({80,-5,0})
    self.setRotation({0,0,0})
    self.setScale({1,1,1})
    activation=getObjectFromGUID(Global.getVar("activation_GUID"))
    wounds=getObjectFromGUID(Global.getVar("wounds_GUID"))
    lockItem(activation)
    lockItem(wounds)
    lockItem(self)
    createMenu()
    activation.setPosition({80,-5,-3})
    wounds.setPosition({80,-5,3})
end

function lockItem(obj)
    obj.setLock(true)
    obj.interactable=false
end



function createMenu()
    self.clearButtons()
    self.createButton(resetBtnR)
    self.createButton(resetBtnB)
    self.createButton(spawnWoundsBtnR)
    self.createButton(spawnWoundsBtnB)
    self.createButton(spawnActivationBtnR)
    self.createButton(spawnActivationBtnB)
    if true then
        self.createButton(hideArmyBtnR)
        self.createButton(hideArmyBtnB)
        self.createButton(showArmyBtnR)
        self.createButton(showArmyBtnB)
    end
    self.createButton(instructionsRBtn)
    self.createButton(instructionsBBtn)
end
-- SECONDARIES OBJECTIVES MANAGER
secondaryObjectivesList={
    {faction="Generic",
    category={
        {name="Purge The Enemy", objectives=  {
                                                    {name="Assassinate", description="Some text here"},
                                                    {name="Bring It Down", description="Some other text here"},
                                                    -- and so on
                                                    }

        },
        {name="No Mercy, No Respite", objectives=  {
                                                    {name="Attrition", description="Some text here"},
                                                    {name="First Strike", description="Some other text here"},
                                                    -- and so on
                                                    }

        },
        {name="CICCION", objectives=  {
                                                    {name="Blablabla", description="Some text here"},
                                                    {name="asfasfasfas", description="Some other text here"},
                                                    {name="lololololo", description="Some other text here"},
                                                    -- and so on
                                                    }

        },
    }
    }-- end faction GENERIC
}
-- END Secondaries Objectives manager
function resetTokens()
    for i, obj in ipairs(getAllObjects()) do
        if obj.getVar("BCBtype") == "ActivationToken" then
            obj.call("resetAlredyActed")
        end
    end
end

function spawnActivation(obj, player, alt)
    spawnItem(obj, player, alt, activation)
end

function spawnWounds(obj, player, alt)
    spawnItem(obj, player, alt, wounds)
end

function spawnItem(obj, player, alt, original)
    local localPos={}
    local mousePos=Player[player].getPointerPosition()
    local rot={0,0,0}
    if mousePos.z> 0 then -- red player
        rot={0,180,0}
        if original== activation then
            localPos=spawnActivationBtnR.position
        else
            localPos=spawnWoundsBtnR.position
        end
    else -- blue player
        if original== activation then
            localPos=spawnActivationBtnB.position
        else
            localPos=spawnWoundsBtnB.position
        end
    end
    local clone=original.clone({
        position     = self.positionToWorld({-localPos[1],localPos[2]+5.5,localPos[3]*0.95}),
        rotation = rot
    })
    --clone.setRotation(rot)
    clone.setLock(false)
    clone.interactable=true
end

-- HIDE SHOW ARMY MANAGER

hiddenZone={}

function hideArmyR(obj, player, alt)
    if player ~= "Red" then print("INTRUDER") return end
    hideShowArmy("Red", true)
end

function hideArmyB(obj, player, alt)
    if player ~= "Blue" then print("INTRUDER") return end
    hideShowArmy("Blue", true)
end

function showArmyR(obj, player, alt)
    if player ~= "Red" then print("INTRUDER") return end
    hideShowArmy("Red", false)
end

function showArmyB(obj, player, alt)
    if player ~= "Blue" then print("INTRUDER") return end
    hideShowArmy("Blue", false)
end

function hideShowArmy(color, hideShow)
    hiddenZone["Red"] = getObjectFromGUID(Global.getVar("redHiddenZone_GUID"))
    hiddenZone["Blue"] = getObjectFromGUID(Global.getVar("blueHiddenZone_GUID"))
    local zoneData={position={hide={x=20, y=0.75, z=74.25}, show={x=0, y=-50.75, z=74.25}}, scale={hide={x=140, y=230, z=48}, show={0.1,0.1,0.1}}}


    local hideIndex="hide"
    if not hideShow then
        hideIndex="show"
    end
    if color == "Blue" then
        zoneData.position.hide.z = -zoneData.position.hide.z
        zoneData.position.show.z = -zoneData.position.show.z
    end
    hiddenZone[color].setPosition(zoneData.position[hideIndex])
    hiddenZone[color].setScale(zoneData.scale[hideIndex])
    hiddenZone[color].setRotation({0,0,0})
end

-- END Hide show army manager

function removeVal(list, value) -- rimuove solo il primo valore trovato
    for i, val in ipairs(list) do
        if val == value then
            table.remove(list, i)
            break
        end
    end
    return list
end

function linkMini()
end

function none()
end