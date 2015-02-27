-- The item BP
local frombp = 1  -- 0 withdrawer, 1 depositer
local tobp = 0    -- 1 withdrawer, 0 depositer



local curmainbp;
local mincap = 100
Self.CloseContainers()
Self.OpenDepot()
Container(0):UseItem(0,true)
curmainbp = Self.OpenMainBackpack(false):Index()


function flytt(from,to)
  fra=Container.New(from)
  for i=0, fra:ItemCount() do
    if Item.isContainer(fra:GetItemData(from).id) then
      fra:UseItem(from, true)
      flytt(from,to)
    else
      if Container(to):isFull() then
        if Item.isContainer(Container(to):GetItemData(19).id) then
          Container(to):UseItem(19,true)
        else
          return
        end
      else
        if Self.Cap() >= 100 then
          fra:MoveItemToContainer(from,to,19)
        else
          return
        end
      end
    end
    sleep(400)
  end
end

--flytt(0,1)
flytt(frombp,tobp)
