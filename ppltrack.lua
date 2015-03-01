local toTrack
local posX = Self.Position().x
local posY = Self.Position().y


-- GUI
local textOffset = 230
local hudArr = {}
local playerGui
local speedGui
local speedXGui
local speedYGui
local avgSize = 5
local running = false
local pattern = 000000000
 tiles = {}
tilesCache = {}
-- SIZE __MUST__ BE ODD! 5,7,9
GRID_SIZE_X         = 13
GRID_SIZE_Y         = 13
GRID_OFFSET_TOP     = 20
GRID_OFFSET_LEFT    = 50
CENTERX             = math.ceil(GRID_SIZE_X/2)
CENTERY             = math.ceil(GRID_SIZE_Y/2)
CENTERPOS           = math.ceil((GRID_SIZE_X*GRID_SIZE_X)/2)

local limX = math.floor(GRID_SIZE_X/2)
local limY = math.floor(GRID_SIZE_Y/2)

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
  for l=0, avgSize do
    speedLog["totalS"][l] = 0
    speedLog["speedX"][l] = 0
    speedLog["speedY"][l] = 0
  end

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
        updateGrid(Self.Position(), charobj:Position()["x"], charobj:Position()["y"],  charobj:Position()["z"], averageSpeed)
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

function canAnalyze(x, y, z)
  pat = 0
  for i = -1, 1 do
    for j = -1, 1 do
      if (not tilesCache[x+j]) then
        return false
      end
      if (not tilesCache[x+j][y + i]) then
        return false
      end
      if (not tilesCache[x+j][y + i][z]) then
        return false
      end
      if (not tilesCache[x+j][y + i][z].set) then
        return false
      end

      print(i .. " " .. j)
    end
  end
  return true
end

function getGreenVal(obj, avg, avgTot, i, lim, j)
  local negative = 1
  local simmax = 200
  if (canAnalyze(obj.x, obj.y, obj.z) == true) then
    print(obj.x .. " " .. obj.y .. " " .. obj.z .. " " .. obj.val)
    if (not tilesCache[obj.x][obj.y - 1][obj.z].walkable) and (not tilesCache[obj.x][obj.y + 1][obj.z].walkable) then
      negative = 3
    elseif (not tilesCache[obj.x - 1][obj.y][obj.z].walkable) and (not tilesCache[obj.x + 1][obj.y][obj.z].walkable) then
      negative = 3
    end
  end

  local m = (simmax*math.abs(avg)/avgTot - (math.abs(j)/lim)*simmax - (math.abs(i)/lim)*simmax + obj.val)*negative;
  if m <= 0 then
    return 0
  elseif (obj.val >= 255) then
    return 255
  else
    return m
  end

end
function updateGrid(posarr, x, y, z, avges)

  -- Y VALUE FIRST
  for i= limY * -1, limX do
    -- X VALUE SECOND
    for j= limX * -1, limY do
      --Check if cached X
      if (not tilesCache[x+j]) then
        tilesCache[x+j] = {}
      end
      -- Check if cached Y
      if (not tilesCache[x+j][y+i]) then
        tilesCache[x+j][y+i] = {}
      end
      -- Check if cached Z
      if (not tilesCache[x+j][y+i][z]) then
        tilesCache[x+j][y+i][z] = {}
        tilesCache[x+j][y+i][z].set = false;
        tilesCache[x+j][y+i][z].val = 0;
        tilesCache[x+j][y+i][z].x = x+j;
        tilesCache[x+j][y+i][z].y = y+i;
        tilesCache[x+j][y+i][z].z = z;
      end

      -- Set tile to not hold a player by default
      tilesCache[x+j][y+i][z].hasPlayer = false;

      -- Check if we are out of our view
      if (math.abs(posarr.x - (x+j) )) > 7 then
      elseif (math.abs(posarr.y - (y+i) )) > 5 then
      else
        -- Check if value is set, if not set it and add defaults
        if (not tilesCache[x+j][y+i][z].set) then
          tilesCache[x+j][y+i][z].walkable = Map.IsTileWalkable(x+j, y+i, z)
          tilesCache[x+j][y+i][z].set = true;
        end

        tilesCache[x+j][y+i][z].val = 0;
        -- If the tile is walkable
        if (tilesCache[x+j][y+i][z].walkable) then
          -- Check if we are on the west side of the map
          if (j < 0 and avges.x > 0) then
            tilesCache[x+j][y+i][z].val  = getGreenVal(tilesCache[x+j][y+i][z], avges.x, avges.total, i, limY, j)
          elseif (j > 0 and avges.x < 0) then
            tilesCache[x+j][y+i][z].val  = getGreenVal(tilesCache[x+j][y+i][z], avges.x, avges.total, i, limY, j)
          end

          if (i < 0 and avges.y > 0) then
            tilesCache[x+j][y+i][z].val  = getGreenVal(tilesCache[x+j][y+i][z], avges.y, avges.total, j, limY, i)
          elseif (i > 0 and avges.y < 0) then
            tilesCache[x+j][y+i][z].val  = getGreenVal(tilesCache[x+j][y+i][z], avges.y, avges.total, j, limY, i)
          end

        end
      end

    end
  end

  for name, creatureobj in Creature.iPlayers(5) do
    local pos = creatureobj:Position()
    tilesCache[pos.x][pos.y][pos.z].hasPlayer = true;
  end


  drawMap(x, y, z)
end

function drawMap(x, y, z)
  local n = 1
  for i= limY * -1, limX do
    for j= limX * -1, limY do
      if (i == 0) and (j == 0) then
        hudArr[n]:SetTextColor(125,255,0)
      elseif (not tilesCache[x+j][y+i][z].set) then
        hudArr[n]:SetTextColor(255,0,0)
      elseif (tilesCache[x+j][y+i][z].hasPlayer) then
        hudArr[n]:SetTextColor(255,0,255)
      elseif (tilesCache[x+j][y+i][z].walkable) then
        hudArr[n]:SetTextColor(0,tilesCache[x+j][y+i][z].val,255)
      else
        hudArr[n]:SetTextColor(255,0,0)
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
      hudArr[#hudArr+1] = HUD.New(GRID_OFFSET_TOP + y*12, GRID_OFFSET_LEFT + i*12, "@", 255, 0, 0)
    end
  end

  playerGui  =  HUD.New(12, textOffset, "Player " .. toTrack .. " not on screen", 255, 0, 0)
  speedGui   =  HUD.New(12, textOffset + 20, "Speed: 0", 255, 0, 0)
  speedXGui  =  HUD.New(12, textOffset + 40, "Horizontal: 0", 255, 0, 0)
  speedYGui  =  HUD.New(12, textOffset + 60, "Vertical: 0", 255, 0, 0)
end

function channelspeak(c, ppl)
  c:SendYellowMessage("Client", "Target updated")
  toTrack = ppl

  if running == true then
    Module("track"):Stop()
  else
    drawGui()
  end

  running = true
  Module.New("track", positionLoop, true)

end

function channelclose()

end



local c = Channel.New("AlphaWaller", channelspeak, channelclose)
c:SendOrangeMessage("TestWare", "Type a target name:")



--Creature:isOnScreen(multifloor)

--
