VehMonitor = {}
VehMonitor._index = VehMonitor

VehMonitor.inVehicle = false
VehMonitor.enteringVehicle = false
VehMonitor.vehicleUndriveable = false

function VehMonitor:GetSeatPedIsIn()
    local playerPed = cache.ped or PlayerPedId()
    for i = -1, 16 do
        if GetPedInVehicleSeat(self.vehicle, i) == playerPed then
            return i
        end
    end
    return -1
end

function VehMonitor:GetVehicleData()
    if not DoesEntityExist(self.vehicle) then return end

    local vehicleModel = GetEntityModel(self.vehicle)
    local displayName = GetDisplayNameFromVehicleModel(vehicleModel)
    local netId = NetworkGetEntityIsNetworked(self.vehicle) and VehToNet(self.vehicle) or self.vehicle
    local plate = GetVehicleNumberPlateText(self.vehicle)

    return displayName, netId, plate
end

function VehMonitor:EnteringVehicle()
    local playerPed = cache.ped or PlayerPedId()
    self.seat = GetSeatPedIsTryingToEnter(playerPed)

    local _, netId, plate = self:GetVehicleData()

    self.enteringVehicle = true
    TriggerEvent("mnr_player:vehicle:Entering", {vehicle = self.vehicle, plate = plate, seat = self.seat, netID = netId})
    TriggerServerEvent("mnr_player:vehicle:Entering", {plate = plate, seat = self.seat, netID = netId})
end

function VehMonitor:ResetVehicleData()
    self.enteringVehicle = false
    self.vehicle = false
    self.seat = false
    self.inVehicle = false
end

function VehMonitor:EnterAborted()
    self:ResetVehicleData()

    TriggerEvent("mnr_player:vehicle:EnterAborted")
    TriggerServerEvent("mnr_player:vehicle:EnterAborted")
end

function VehMonitor:EnteredVehicle()
    self.enteringVehicle = false
    self.inVehicle = true

    self.seat = self:GetSeatPedIsIn()

    local displayName, netId, plate = self:GetVehicleData()

    TriggerEvent("mnr_player:vehicle:Entered", {vehicle = self.vehicle, plate = plate, seat = self.seat, gameName = displayName, netID = netId})
    TriggerServerEvent("mnr_player:vehicle:Entered", {plate = plate, seat = self.seat, gameName = displayName, netID = netId})
end

function VehMonitor:ExitVehicle()
    local playerPed = cache.ped or PlayerPedId()
    local currentVehicle = GetVehiclePedIsIn(playerPed, false)

    if currentVehicle ~= self.vehicle then
        local displayName, netId, plate = self:GetVehicleData()

        TriggerEvent("mnr_player:vehicle:Exit", {vehicle = self.vehicle, plate = plate, seat = self.seat, gameName = displayName, netID = netId})
        TriggerServerEvent("mnr_player:vehicle:Exit", {plate = plate, seat = self.seat, gameName = displayName, netID = netId})

        self:ResetVehicleData()
    end
end

function VehMonitor:TrackSeat()
    if not self.inVehicle then
        return
    end

    local newSeat = self:GetSeatPedIsIn()
    if newSeat ~= self.seat then
        self.seat = newSeat
        TriggerEvent("mnr_player:vehicle:SeatChanged", self.seat)
    end
end

function VehMonitor:VehicleUndriveable()
    if self.vehicle and DoesEntityExist(self.vehicle) then
        if GetEntityHealth(self.vehicle) <= 0 then
            if self.vehicleUndriveable then return end

            local displayName, netId, plate = self:GetVehicleData()

            self.vehicleUndriveable = true
            TriggerEvent("mnr_player:vehicle:Undriveable", {vehicle = self.vehicle, plate = plate, seat = self.seat, gameName = displayName, netID = netId})
            TriggerServerEvent("mnr_player:vehicle:Undriveable", {plate = plate, seat = self.seat, gameName = displayName, netID = netId})
        else
            self.vehicleUndriveable = false
        end
    end
end

function VehMonitor:Update()
    if not self.inVehicle then
        local playerPed = cache.ped or PlayerPedId()
        local tempVehicle = GetVehiclePedIsTryingToEnter(playerPed)

        if DoesEntityExist(tempVehicle) and not self.enteringVehicle then
            self.vehicle = tempVehicle
            self:EnteringVehicle()
        elseif not DoesEntityExist(tempVehicle) and not IsPedInAnyVehicle(playerPed, true) and self.enteringVehicle then
            self:EnterAborted()
        elseif IsPedInAnyVehicle(playerPed, false) then
            self.vehicle = GetVehiclePedIsIn(playerPed, false)
            self:EnteredVehicle()
        end
    else
        self:VehicleUndriveable()
        self:ExitVehicle()
        self:TrackSeat()
    end
end