local toTrack = "Aracrel Skara"
local posX = Self.Position().x
local posY = Self.Position().y


-- GUI
local textOffset = 200
local hudArr = {}
local playerGui
local speedGui
local speedXGui
local speedYGui
local avgSize = 5
 tiles = {}
-- SIZE __MUST__ BE ODD! 5,7,9
GRID_SIZE_X         = 15
GRID_SIZE_Y         = 15
GRID_OFFSET_TOP     = 20
GRID_OFFSET_LEFT    = 20
CENTERX             = math.ceil(GRID_SIZE_X/2)
CENTERY             = math.ceil(GRID_SIZE_Y/2)
CENTERPOS           = math.ceil((GRID_SIZE_X*GRID_SIZE_X)/2)

function positionLoop()
  for name, creatureobj in Creature.iPlayers(7) do
    local pos = creatureobj:Position()
    if (name == toTrack) then
      hudArr[CENTERPOS]:SetTextColor(0, 255, 0)
      playerGui:SetTextColor(0, 255, 0)
      playerGui:SetText("Player on screen!")

      updateSpeedGui(0,0,0)
      Module("track"):Stop()
      playerOnScreen(creatureobj)
      break
    end
  end
end

function playerOnScreen(charobj)
  local speed     = {lastX, lastY, vecX = 0, vecY = 0, ms = 0, lastdiff = 0, set = 0}
  local speedLog  = {totalS = {}, speedX = {}, speedY = {}}
  local i = 0
  while charobj:isOnScreen(false) do
    local lastX = charobj:Position()["x"]
    local lastY = charobj:Position()["y"]
    local vecX = lastX - Self.Position().x
    local vecY = lastY - Self.Position().y
    local averageSpeed = {total = 0, x = 0, y = 0}

    if (lastX ~= speed["lastX"] or lastY ~= speed["lastY"]) then
      if (speed["lastdiff"] ~= 0 or speed["lastdiff"] > 10) then
        vec = {x = speed["lastX"]-lastX, y = speed["lastY"]-lastY }

        travelvec = math.sqrt(math.pow(vec.x,2) + math.pow(vec.y,2))

        speedLog["totalS"][i] = travelvec / speed["lastdiff"]
        speedLog["speedX"][i] = vec.x / speed["lastdiff"]
        speedLog["speedY"][i] = vec.y / speed["lastdiff"]
        i = i + 1

        local avges = {total = 0, x = 0, y = 0}

        for l=0, #speedLog["totalS"] do
          --[[ if (i > 2) then
            if (math.abs(speedLog["speedX"][i]-speedLog["speedX"][i-1]) > 2) then
              averageSpeed = {total = 0, x = 0, y = 0}
              i = 0
              break
            end
          end
           ]]

          avges.total = avges.total + speedLog["totalS"][l]
          avges.x = avges.x + speedLog["speedX"][l]
          avges.y = avges.y + speedLog["speedY"][l]
        end

        averageSpeed.x     = avges.x/#speedLog["speedX"]
        averageSpeed.y     = avges.y/#speedLog["speedY"]
        averageSpeed.total = avges.total/#speedLog["totalS"]
        updateSpeedGui(averageSpeed.total, averageSpeed.x, averageSpeed.y)

        if i == avgSize then
          i = 0
        end

      end

      if (vecX ~= speed["vecX"] or vecY ~= speed["vecY"]) then
        speed["vecX"] = vectX;
        speed["vecY"] = vectY;
        updateGrid(charobj:Position()["x"], charobj:Position()["y"],  charobj:Position()["z"], averageSpeed)
      end

      speed["lastX"] = lastX;
      speed["lastY"] = lastY;
      speed["lastdiff"] = os.clock() - speed["ms"]
      speed["ms"]    = os.clock()
    end


  end
  hudArr[math.ceil((GRID_SIZE_X*GRID_SIZE_X)/2)]:SetTextColor(255, 0, 0)
  Module.New("track", positionLoop, true)
  textReset()
  return
end

function getGreenVal(cur, avg, avgTot, i, lim)
  local m = 255*math.abs(avg)/avgTot - (math.abs(i)/lim)*255 + cur;
  if m <= 0 then
    return 0
  elseif (cur >= 255) then
    return 255
  else
    return m
  end

end
function updateGrid(x, y, z, avges)
  local limX = math.floor(GRID_SIZE_X/2)
  local limY = math.floor(GRID_SIZE_Y/2)
  tiles = {}
  n = 1
  for i= limY * -1, limX do
    for j= limX * -1, limY do
      if n ~= CENTERPOS then
        tiles[n] = {}
        if Map.IsTileWalkable(x+j, y+i, z) then

          tiles[n].g = 0
          tiles[n].b  = 255
          tiles[n].r  = 0
          -- BEGIN
            if (j < 0 and avges.x > 0) then

              tiles[n].g  = getGreenVal(tiles[n].g, avges.x, avges.total, i, limY)
            elseif (j > 0 and avges.x < 0) then
              tiles[n].g = getGreenVal(tiles[n].g, avges.x, avges.total, i, limY)
            end

            if (i < 0 and avges.y > 0) then
              tiles[n].g  = getGreenVal(tiles[n].g, avges.y, avges.total, j, limY)
            elseif (i > 0 and avges.y < 0) then
              tiles[n].g  = getGreenVal(tiles[n].g, avges.y, avges.total, j, limY)
            end


        else
          tiles[n].r  = 255
          tiles[n].g  = 0
          tiles[n].b  = 0
        end
        hudArr[n]:SetTextColor(tiles[n].r, tiles[n].g, tiles[n].b)
      end
      n = n + 1
    end
  end
end

function updateSpeedGui(total, x, y)
    speedGui:SetText("Total speed: "..total )
    speedXGui:SetText("Horizontal: " .. x )
    speedYGui:SetText("Vertical: ".. y )
    speedGui:SetTextColor(255, 255, 0)
    speedXGui:SetTextColor(255, 255, 0)
    speedYGui:SetTextColor(255, 255, 0)

end

function textReset()
  speedGui:SetText("Speed: 0")
  speedGui:SetTextColor(255, 0, 0)
  speedXGui:SetText("Horizontal: 0")
  speedXGui:SetTextColor(255, 0, 0)
  speedYGui:SetText("Vertical: 0")
  speedYGui:SetTextColor(255, 0, 0)
  playerGui:SetTextColor(255, 0, 0)
  playerGui:SetText("Player " .. toTrack .. " not on screen")
end

function drawGui()
  for i=0, GRID_SIZE_Y-1 do
    for y=0, GRID_SIZE_X-1 do
      hudArr[#hudArr+1] = HUD.New(GRID_OFFSET_TOP + y*12, i*12, "@", 255, 0, 0)
      tiles[#hudArr+1] = {}
      tiles[#hudArr+1]["r"] = 255
      print(tiles[#hudArr+1].r)
    end
  end

  playerGui  =  HUD.New(12, textOffset, "Player " .. toTrack .. " not on screen", 255, 0, 0)
  speedGui   =  HUD.New(12, textOffset + 20, "Speed: 0", 255, 0, 0)
  speedXGui  =  HUD.New(12, textOffset + 40, "Horizontal: 0", 255, 0, 0)
  speedYGui  =  HUD.New(12, textOffset + 60, "Vertical: 0", 255, 0, 0)
end

Module.New("track", positionLoop, true)
drawGui()


--Creature:isOnScreen(multifloor)

--
