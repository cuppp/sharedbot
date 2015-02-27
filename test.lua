--Color of item bp
local dpbp    = "Grey Backpack"
local mainbp  = Self.Backpack().id

--Backpack ID
local bpid    = Item.GetID(dpbp)

--Close all containers
Self.CloseContainers()

--Open your depot
Self.OpenDepot()

--Open BP
Container(0):OpenChildren(bpid)
local curdpbp = Container(bpid)
local maincurbp = mainbp

--Print item amount
local icount = curdpbp:ItemCount()

--Open main bp
Self.OpenMainBackpack()

for slot, item in curdpbp:iItems() do
  curdpbp:MoveItemToContainer(1,maincurbp,1,1)
end
