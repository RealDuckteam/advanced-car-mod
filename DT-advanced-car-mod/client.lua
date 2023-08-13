local isUiOpen = false 
local speedBuffer = {}
local velBuffer = {}
local SeatbeltON = false
local InVehicle = false

local leftSignalActive = false
local rightSignalActive = false
local isUnbuckleSoundPlaying = false

function Notify(string)
  SetNotificationTextEntry("STRING")
  AddTextComponentString(string)
  DrawNotification(false, true)
end

-- Made with <3 by Duckteam
AddEventHandler('seatbelt:sounds', function(soundFile, soundVolume)
  SendNUIMessage({
    transactionType = 'playSound',
    transactionFile = soundFile,
    transactionVolume = soundVolume
  })
end)

function IsCar(veh)
  local vc = GetVehicleClass(veh)
  return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)
end	

-- Made with <3 by Duckteam
function Fwv(entity)
  local hr = GetEntityHeading(entity) + 90.0
  if hr < 0.0 then hr = 360.0 + hr end
  hr = hr * 0.0174533
  return { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }
end

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
  
    local ped = PlayerPedId()
    local car = GetVehiclePedIsIn(ped)

    if car ~= 0 and (InVehicle or IsCar(car)) then
      InVehicle = true
      if isUiOpen == false and not IsPlayerDead(PlayerId()) then
        if Config.Blinker then
          SendNUIMessage({displayWindow = 'true'})
        end
        isUiOpen = true
      end

      if SeatbeltON then 
        DisableControlAction(0, 75, true)  -- Disable exit vehicle when stop | Made with <3 by Duckteam
        DisableControlAction(27, 75, true) -- Disable exit vehicle when Driving | Made with <3 by Duckteam
      end
-- Made with <3 by Duckteam

      speedBuffer[2] = speedBuffer[1]
      speedBuffer[1] = GetEntitySpeed(car)

      if not SeatbeltON and speedBuffer[2] ~= nil and GetEntitySpeedVector(car, true).y > 1.0 and speedBuffer[1] > (Config.Speed / 3.6) and (speedBuffer[2] - speedBuffer[1]) > (speedBuffer[1] * 0.255) then
        local co = GetEntityCoords(ped)
        local fw = Fwv(ped)
        SetEntityCoords(ped, co.x + fw.x, co.y + fw.y, co.z - 0.47, true, true, true)
        SetEntityVelocity(ped, velBuffer[2].x, velBuffer[2].y, velBuffer[2].z)
        Citizen.Wait(1)
        SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
      end

      velBuffer[2] = velBuffer[1]
      velBuffer[1] = GetEntityVelocity(car)

-- Made with <3 by Duckteam      
      if IsControlJustReleased(0, Config.Control) and GetLastInputMethod(0) then
        SeatbeltON = not SeatbeltON 
        if SeatbeltON then
          Citizen.Wait(1)

          if Config.Sounds then  
            TriggerEvent("seatbelt:sounds", "buckle", Config.Volume)
          end
          if Config.Notification then
            Notify(Config.Strings.seatbelt_on)
          end

          if Config.Blinker then
            SendNUIMessage({displayWindow = 'false'})
          end
          isUiOpen = true 
        else 
          if Config.Notification then
            Notify(Config.Strings.seatbelt_off)
          end

          if Config.Sounds then
            TriggerEvent("seatbelt:sounds", "unbuckle", Config.Volume)
          end

          if Config.Blinker then
            SendNUIMessage({displayWindow = 'true'})
          end
          isUiOpen = true  
        end
      end

-- Made with <3 by Duckteam
      if IsControlJustReleased(0, 174) then
        if not leftSignalActive and not rightSignalActive then
          leftSignalActive = true
          rightSignalActive = false
          SetVehicleIndicatorLights(car, 1, leftSignalActive)
          SetVehicleIndicatorLights(car, 0, rightSignalActive)
          if Config.Sounds then
            isUnbuckleSoundPlaying = true
            TriggerEvent("seatbelt:sounds", "blink", Config.Volume)
            Citizen.Wait(700) -- Warte, bis der Sound fertig abgespielt ist
            Citizen.CreateThread(function()
              while isUnbuckleSoundPlaying do
                TriggerEvent("seatbelt:sounds", "blink", Config.Volume)
                Citizen.Wait(700) -- Verzögerung zwischen den Soundwiederholungen
              end
            end)
          end
        elseif leftSignalActive or rightSignalActive then
          leftSignalActive = false
          rightSignalActive = false
          SetVehicleIndicatorLights(car, 1, leftSignalActive)
          SetVehicleIndicatorLights(car, 0, rightSignalActive)
          isUnbuckleSoundPlaying = false
        end
      end
  
      if IsControlJustReleased(0, 175) then
        if not leftSignalActive and not rightSignalActive then
          rightSignalActive = true
          leftSignalActive = false
          SetVehicleIndicatorLights(car, 0, rightSignalActive)
          SetVehicleIndicatorLights(car, 1, leftSignalActive)
          if Config.Sounds then
            isUnbuckleSoundPlaying = true
            TriggerEvent("seatbelt:sounds", "blink", Config.Volume)
            Citizen.Wait(700) -- Warte, bis der Sound fertig abgespielt ist
            Citizen.CreateThread(function()
              while isUnbuckleSoundPlaying do
                TriggerEvent("seatbelt:sounds", "blink", Config.Volume)
                Citizen.Wait(700) -- Verzögerung zwischen den Soundwiederholungen
              end
            end)
          end
        elseif leftSignalActive or rightSignalActive then
          leftSignalActive = false
          rightSignalActive = false
          SetVehicleIndicatorLights(car, 1, leftSignalActive)
          SetVehicleIndicatorLights(car, 0, rightSignalActive)
          isUnbuckleSoundPlaying = false
        end
      end
  
      if IsControlJustReleased(0, 172) then
        if not leftSignalActive and not rightSignalActive then
          leftSignalActive = true
          rightSignalActive = true
          SetVehicleIndicatorLights(car, 1, leftSignalActive)
          SetVehicleIndicatorLights(car, 0, rightSignalActive)
          if Config.Sounds then
            isUnbuckleSoundPlaying = true
            TriggerEvent("seatbelt:sounds", "warn", Config.Volume)
            Citizen.Wait(700) -- Warte, bis der Sound fertig abgespielt ist
            Citizen.CreateThread(function()
              while isUnbuckleSoundPlaying do
                TriggerEvent("seatbelt:sounds", "warn", Config.Volume)
                Citizen.Wait(700) -- Verzögerung zwischen den Soundwiederholungen
              end
            end)
          end
        else
          leftSignalActive = false
          rightSignalActive = false
          SetVehicleIndicatorLights(car, 1, leftSignalActive)
          SetVehicleIndicatorLights(car, 0, rightSignalActive)
          isUnbuckleSoundPlaying = false
        end
      end
    
    elseif InVehicle then
      InVehicle = false
      SeatbeltON = false
      speedBuffer[1], speedBuffer[2] = 0.0, 0.0
      leftSignalActive = false
      rightSignalActive = false
      isUnbuckleSoundPlaying = false

      SetVehicleIndicatorLights(car, 1, false)
      SetVehicleIndicatorLights(car, 0, false)
      if Config.Sounds then
        isUnbuckleSoundPlaying = false
      end

      if isUiOpen == true and not IsPlayerDead(PlayerId()) then
        if Config.Blinker then
          SendNUIMessage({displayWindow = 'false'})
        end
        isUiOpen = false 
      end
    end
  end
end)
-- Made with <3 by Duckteam

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(10)
    local Vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
    local VehSpeed = GetEntitySpeed(Vehicle) * 3.6

    if Config.AlarmOnlySpeed and VehSpeed > Config.AlarmSpeed then
      ShowWindow = true
    else
      ShowWindow = false
      SendNUIMessage({displayWindow = 'false'})
    end

    if IsPlayerDead(PlayerId()) or IsPauseMenuActive() then
      if isUiOpen == true then
        SendNUIMessage({displayWindow = 'false'})
      end
    elseif not SeatbeltON and InVehicle and not IsPauseMenuActive() and not IsPlayerDead(PlayerId()) and Config.Blinker then
      if Config.AlarmOnlySpeed and ShowWindow and VehSpeed > Config.AlarmSpeed then
        SendNUIMessage({displayWindow = 'true'})
      end
    end
  end
end)
-- Made with <3 by Duckteam

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(3500)
    if not SeatbeltON and InVehicle and not IsPauseMenuActive() and Config.LoopSound and ShowWindow then
      TriggerEvent("seatbelt:sounds", "seatbelt", Config.Volume)
    end    
  end
end)


-- Made with <3 by Duckteam