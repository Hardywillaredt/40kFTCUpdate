-- FTC-GUID: ee92cf
titleBtn={
    index=1, label="Game rounds", click_function="none", function_owner=self,
    position={0,0.3,0.23}, rotation={0,180,0}, height=0, width=00,
    font_size=40, color={0,0,0}, font_color={1,1,1}
}

btnHeight=300
btnWidth=500
btnXPos=0.7
btnYPos=0.25
btnZPos=-0.68
endLbl="Game Over"
continueLbl="Continue\n3+"
endBtn={
    index=1, label=endLbl, click_function="gameOver", function_owner=self,
    position={-btnXPos,btnYPos,btnZPos}, rotation={0,180,0}, height=btnHeight, width=btnWidth,
    font_size=90, color={1,0,0}, font_color={1,1,1}
}
continueBtn={
    index=1, label=continueLbl, click_function="gameContinues", function_owner=self,
    position={btnXPos,btnYPos,btnZPos}, rotation={0,180,0}, height=btnHeight, width=btnWidth,
    font_size=90, color={0,0.6,0}, font_color={1,1,1}
}
function onLoad()
    counterA=getObjectFromGUID(Global.getVar("redVPCounter_GUID"))
    counterB=getObjectFromGUID(Global.getVar("blueVPCounter_GUID"))
    startObject=getObjectFromGUID(Global.getVar("startMenu_GUID"))
end

function writeButtons()
    self.clearButtons()
    self.createButton(continueBtn)
    self.createButton(endBtn)
end

function checkGameEnd()
    if self.Counter.getValue() > 5 then
        --[[startObject.setVar("checkEnd", true)
        startObject.call("writeMenus")
    end
    if self.Counter.getValue() == 6 then
        broadcastToAll("Check if game ends now", "Yellow")
        continueBtn.label="Continue\n3+"
        writeButtons()
    end
    if self.Counter.getValue() == 7 then
        broadcastToAll("Check if game ends now", "Yellow")
        continueBtn.label="Continue\n4+"
        writeButtons()
    end
    if self.Counter.getValue() > 7 then--]]
        broadcastToAll("GAME OVER", "Red")
        gameOver()

    end
end

function gameOver()
    self.clearButtons()
    startObject.setVar("checkEnd", false)
    startObject.call("writeMenus")
    if  counterA.Counter.getValue() > counterB.Counter.getValue() then
        broadcastToAll("Red Player WINS !", "Green")
    end
    if  counterA.Counter.getValue() < counterB.Counter.getValue() then
        broadcastToAll("Blue Player WINS !", "Green")
    end
    if  counterA.Counter.getValue() == counterB.Counter.getValue() then
        broadcastToAll("Game ends in a DRAW !", "Green")
    end
end

function gameContinues()
    self.clearButtons()
    startObject.setVar("checkEnd", false)
    startObject.call("writeMenus")
end

function none()
end