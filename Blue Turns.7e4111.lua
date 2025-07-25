-- FTC-GUID: 7e4111,055302
-- Description contains the guid of game turn counter


function increaseSelf()
        self.Counter.increment()
        gameUpdate()

end

function gameUpdate()
    guidGC=self.getDescription()
    gameTurn=getObjectFromGUID(guidGC)

    -- required to inform startMenu of change in Round
    startMenu=getObjectFromGUID(Global.getVar("startMenu_GUID"))

    if gameTurn == nil then
    else
        if self.Counter.getValue() > gameTurn.Counter.getValue() then
            gameTurn.Counter.setValue(self.Counter.getValue())
            gameTurn.call("checkGameEnd")
            startMenu.call("newRoundStarted")
        end
    end
end