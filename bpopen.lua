-- The item BP
local dpbp    = "yellow backpack"
local bpid    = Item.GetID(dpbp)
local mainbp  = Self.Backpack().id

-- Close all containers
Self.CloseContainers()

-- Open your depot
Self.OpenDepot()

--Open BP
local dp = Container(0);
dp:UseItem(0,true)

local curdpbp = Container.New(0);
-- Print item amountContainer(0):ItemCount()
local icount    = curdpbp:ItemCount()

--OPen your own bp
local curmainbp = Self.OpenMainBackpack(false)

-- Container(curdpbp):MoveItemToContainer(0)
print(curdpbp:ItemCount())
for i=0, curdpbp:ItemCount() do
  print("Moved item.")
  curdpbp:MoveItemToContainer(0,1,0)
  sleep(500)
end
