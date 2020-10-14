N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

-- Code

N1Core.Functions.CreateUseableItem("radio", function(source, item)
  local Player = N1Core.Functions.GetPlayer(source)
  TriggerClientEvent('N1-radio:use', source)
end)

N1Core.Functions.CreateCallback('N1-radio:server:GetItem', function(source, cb, item)
  local src = source
  local Player = N1Core.Functions.GetPlayer(src)
  if Player ~= nil then 
    local RadioItem = Player.Functions.GetItemByName(item)
    if RadioItem ~= nil then
      cb(true)
    else
      cb(false)
    end
  else
    cb(false)
  end
end)