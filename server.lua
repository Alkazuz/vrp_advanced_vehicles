-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
---------------------------------------------

vRPN = {}
Tunnel.bindInterface("vrp_advancedvehicles",vRPN)
Proxy.addInterface("vrp_advancedvehicles",vRPN)

Citizen.CreateThread(function()
	Wait(5000)
	if Config.createTable == true then
		MySQL.Async.execute([[
			CREATE TABLE IF NOT EXISTS `advanced_vehicles` (
				`vehicle` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`user_id` VARCHAR(55) NOT NULL,
				`km` DOUBLE UNSIGNED NOT NULL DEFAULT '0',
				`vehicle_handling` LONGTEXT NOT NULL DEFAULT '{}' COLLATE 'utf8mb4_general_ci',
				`nitroAmount` INT(11) NOT NULL DEFAULT '0',
				`nitroRecharges` INT(11) NOT NULL DEFAULT '0',
				PRIMARY KEY (`vehicle`, `user_id`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB;

			CREATE TABLE IF NOT EXISTS `advanced_vehicles_inspection` (
				`vehicle` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`user_id` VARCHAR(55) NOT NULL,
				`item` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`km` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`value` DOUBLE UNSIGNED NOT NULL DEFAULT '0',
				`timer` INT(10) UNSIGNED NOT NULL DEFAULT unix_timestamp(),
				PRIMARY KEY (`vehicle`, `user_id`, `item`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB;

			CREATE TABLE IF NOT EXISTS `advanced_vehicles_services` (
				`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
				`vehicle` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`user_id` VARCHAR(55) NOT NULL,
				`item` VARCHAR(50) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
				`name` VARCHAR(50) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
				`km` INT(11) UNSIGNED NOT NULL DEFAULT '0',
				`img` VARCHAR(255) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
				`timer` INT(10) UNSIGNED NOT NULL DEFAULT unix_timestamp(),
				PRIMARY KEY (`id`) USING BTREE,
				INDEX `vehicle` (`vehicle`) USING BTREE,
				INDEX `user_id` (`user_id`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB;
			
			CREATE TABLE IF NOT EXISTS `advanced_vehicles_upgrades` (
				`vehicle` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`user_id` VARCHAR(55) NOT NULL,
				`class` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`item` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				PRIMARY KEY (`vehicle`, `user_id`, `class`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB;
		]])
	end
end)

function vRPN.PlayerInfo()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local cash = vRP.getMoney(user_id)
		local banco = vRP.getBankMoney(user_id)
		local job = vRPN.getUserGroupByType(user_id,"job")
		if identity then
			return vRP.format(parseInt(cash)), vRP.format(parseInt(banco)), job
		end
	end
end

local vehiclesHandlingsOriginal = {}

RegisterServerEvent('vrp_advanced_vehicles:getVehicleData')
AddEventHandler('vrp_advanced_vehicles:getVehicleData', function(vehicleDataClient)
	local source = source
	local vehicle,vnetid,placa,vname,lock,banned = vRPclient.vehList(source,7)
	if vehicle and placa then
		if vehicleDataClient.plate == placa then
			local owner_id = vRP.getUserByRegistration(placa)
			local vehicleData = getVehicleData(vehicleDataClient,owner_id)
			TriggerClientEvent('vrp_advanced_vehicles:LixeiroCB', source, {[1] = vehicleData})
			return
		end
	end
	TriggerClientEvent('vrp_advanced_vehicles:LixeiroCB', source, false)
	--[[MySQL.Async.fetchAll("SELECT owner as user_id FROM getVehicleData WHERE ipva = @vehicle_plate", {['@vehicle_plate'] = vehicleDataClient.plate}, function(vehiclequery)
		if vehiclequery[1] then
			local owner_id = vRP.getUserByRegistration(placa)
			local vehicleData = getVehicleData(vehicleDataClient,owner_id)
			TriggerClientEvent('vrp_advanced_vehicles:LixeiroCB', source, {[1] = vehicleData})
		else
			TriggerClientEvent('vrp_advanced_vehicles:LixeiroCB', source, false)
		end
	end)]]
end)

RegisterServerEvent('vrp_advanced_vehicles:setVehicleData')
AddEventHandler('vrp_advanced_vehicles:setVehicleData', function(vehicleData,vehicleHandling)
	local source = source
	--[[local vehicle,vnetid,placa,vname,lock,banned = vRPclient.vehList(source,7)
	if vehicle and placa then
		if vehicleData.plate == placa then
			local owner_id = vRP.getUserByRegistration(placa)
			vehicleData.km = string.format("%.2f",(vehicleData.km/1000))
			local sql = "UPDATE `advanced_vehicles` SET km = @km, vehicle_handling = @vehicleHandling, nitroAmount = @nitroAmount, nitroRecharges = @nitroRecharges WHERE vehicle = @vehicle AND user_id = @user_id AND plate = @plate";
			MySQL.Sync.execute(sql, {['@km'] = vehicleData.km, ['@vehicleHandling'] = json.encode(vehicleHandling), ['@nitroAmount'] = vehicleData.nitroAmount, ['@nitroRecharges'] = vehicleData.nitroRecharges, ['@vehicle'] = vehicleData.name, ['@user_id'] = owner_id, ['@plate'] = vehicleData.plate});
		end
	end
	MySQL.Async.fetchAll("SELECT user_id FROM vrp_user_indetities WHERE registration = @vehicle_plate", {['@vehicle_plate'] = vehicleData.plate}, function(vehiclequery)
	for i=1,#vehiclequery do
		if vehiclequery[i] and vehicleData.name ==  then
			local owner_id = vRP.getUserByRegistration(placa)
			vehicleData.km = string.format("%.2f",(vehicleData.km/1000))
			local sql = "UPDATE `advanced_vehicles` SET km = @km, vehicle_handling = @vehicleHandling, nitroAmount = @nitroAmount, nitroRecharges = @nitroRecharges WHERE vehicle = @vehicle AND user_id = @user_id AND plate = @plate";
			MySQL.Sync.execute(sql, {['@km'] = vehicleData.km, ['@vehicleHandling'] = json.encode(vehicleHandling), ['@nitroAmount'] = vehicleData.nitroAmount, ['@nitroRecharges'] = vehicleData.nitroRecharges, ['@vehicle'] = vehicleData.name, ['@user_id'] = owner_id, ['@plate'] = vehicleData.plate});
		end
	end--]]
	local owner_id = vRP.getUserByRegistration(vehicleData.plate)
	vehicleData.km = string.format("%.2f",(vehicleData.km/1000))
	local sql = "UPDATE `advanced_vehicles` SET km = @km, vehicle_handling = @vehicleHandling, nitroAmount = @nitroAmount, nitroRecharges = @nitroRecharges WHERE vehicle = @vehicle AND user_id = @user_id AND plate = @plate";
	MySQL.Sync.execute(sql, {['@km'] = vehicleData.km, ['@vehicleHandling'] = json.encode(vehicleHandling), ['@nitroAmount'] = vehicleData.nitroAmount, ['@nitroRecharges'] = vehicleData.nitroRecharges, ['@vehicle'] = vehicleData.name, ['@user_id'] = owner_id, ['@plate'] = vehicleData.plate});
end)

RegisterServerEvent('vrp_advanced_vehicles:setGlobalVehicleHandling')
AddEventHandler('vrp_advanced_vehicles:setGlobalVehicleHandling', function(name,handlings)
	if not vehiclesHandlingsOriginal[name] then vehiclesHandlingsOriginal[name] = {} end
	vehiclesHandlingsOriginal[name] = handlings
	TriggerClientEvent('vrp_advanced_vehicles:setGlobalVehicleHandling', -1, vehiclesHandlingsOriginal)
end)

local cancelled = false
local cooldown = {}
RegisterServerEvent('vrp_advanced_vehicles:makeAction')
AddEventHandler('vrp_advanced_vehicles:makeAction', function(vehicleData,data,firstStep)
	local source = source
	if cooldown[source] == nil then
		cooldown[source] = true
		--MySQL.Async.fetchAll("SELECT owner as user_id FROM owned_vehicles WHERE plate = @vehicle_plate", {['@vehicle_plate'] = vehicleData.plate}, function(vehiclequery)
		local owner_id = vRP.getUserByRegistration(vehicleData.plate)
		if owner_id then
			if data.action == 'Repair' then
				local maintenance = {}
				if Config.maintenance[vehicleData.name] then
					maintenance = Config.maintenance[vehicleData.name][data.idname]
				else
					maintenance = Config.maintenance['default'][data.idname]
				end
				if vRP.getInventoryItemAmount(owner_id, maintenance.repair_item.name) >= maintenance.repair_item.amount then
					if firstStep then
						TriggerClientEvent('vrp_advanced_vehicles:useTheJackFunction',source,data,firstStep)
					else
						TriggerClientEvent("progress",source,maintenance.repair_item.time*1000,Lang[Config.lang]['service_progress'])
						cancelled = false
						Citizen.Wait(maintenance.repair_item.time*1000)

						if cancelled == false and vRP.getInventoryItemAmount(owner_id, maintenance.repair_item.name) >= maintenance.repair_item.amount then
							--xPlayer.removeInventoryItem(maintenance.repair_item.name,maintenance.repair_item.amount)
							vRP.removeInventoryItem(user_id, maintenance.repair_item.name, maintenance.repair_item.amount, true)
							local sql = "INSERT INTO `advanced_vehicles_services` (vehicle,user_id,plate,item,name,km,img,timer) VALUES (@vehicle,@user_id,@plate,@item,@name,@km,@img,@timer)";
							MySQL.Sync.execute(sql, {['@user_id'] = owner_id, ['@vehicle'] = vehicleData.name, ['@plate'] = vehicleData.plate, ['@item'] = data.idname, ['@name'] = data.name, ['@km'] = math.floor(vehicleData.km/1000), ['@img'] = data.img, ['@timer'] = os.time()});
							local sql = "REPLACE INTO `advanced_vehicles_inspection` (vehicle,user_id,plate,item,km,value,timer) VALUES (@vehicle,@user_id,@plate,@item,@km,@value,@timer)";
							MySQL.Sync.execute(sql, {['@user_id'] = owner_id, ['@vehicle'] = vehicleData.name, ['@plate'] = vehicleData.plate, ['@item'] = data.idname, ['@km'] = math.floor(vehicleData.km/1000), ['@value'] = 100, ['@timer'] = os.time()});

							TriggerClientEvent('vrp_advanced_vehicles:useTheJackFunction',source,data,firstStep)
							TriggerClientEvent("vrp_advanced_vehicles:Notify",source,"sucesso",Lang[Config.lang]['service_done'])
						else
							TriggerClientEvent('vrp_advanced_vehicles:useTheJackFunction',source,data,firstStep)
							TriggerClientEvent("vrp_advanced_vehicles:Notify",source,"negado",Lang[Config.lang]['service_cancel'])
						end
					end
				else
					itemlabel = vRP.itemNameList(maintenance.repair_item.name)
					TriggerClientEvent('vrp_advanced_vehicles:Notify', source, "negado", Lang[Config.lang]['not_enough_items']:format(maintenance.repair_item.amount,itemlabel))
				end
			elseif data.action == 'Inspection' then
				if Config.itemToInspect == false or vRP.getInventoryItemAmount(owner_id, Config.itemToInspect) >= 1 then
					local maintenance = {}
					if Config.maintenance[vehicleData.name] then
						maintenance = Config.maintenance[vehicleData.name][data.idname]
					else
						maintenance = Config.maintenance['default'][data.idname]
					end
					if firstStep then
						TriggerClientEvent('vrp_advanced_vehicles:useTheJackFunction',source,data,firstStep)
					else
						TriggerClientEvent("progress",source,maintenance.repair_item.time*1000,Lang[Config.lang]['inpect_progress'])
						cancelled = false
						Citizen.Wait(maintenance.repair_item.time*1000)

						if cancelled == false then
							local percentage = 0
							km_to_next_service = math.ceil(((vehicleData.km - ((maintenance.lifespan*1000) + ((vehicleData.services[data.idname][1] or 0)*1000)))/1000)*-1)
							if km_to_next_service > 0 then
								percentage = (km_to_next_service*100)/maintenance.lifespan
							end
							percentage = string.format("%.2f",percentage)

							local sql = "REPLACE INTO `advanced_vehicles_inspection` (vehicle,user_id,plate,item,km,value,timer) VALUES (@vehicle,@user_id,@plate,@item,@km,@value,@timer)";
							MySQL.Sync.execute(sql, {['@user_id'] = owner_id, ['@vehicle'] = vehicleData.name, ['@plate'] = vehicleData.plate, ['@item'] = data.idname, ['@km'] = math.floor(vehicleData.km/1000), ['@value'] = percentage, ['@timer'] = os.time()});

							TriggerClientEvent('vrp_advanced_vehicles:useTheJackFunction',source,data,firstStep)
							TriggerClientEvent("vrp_advanced_vehicles:Notify",source,"sucesso",Lang[Config.lang]['inpect_done'])
						else
							TriggerClientEvent('vrp_advanced_vehicles:useTheJackFunction',source,data,firstStep)
							TriggerClientEvent("vrp_advanced_vehicles:Notify",source,"negado",Lang[Config.lang]['inpect_cancel'])
						end
					end
				else
					TriggerClientEvent('vrp_advanced_vehicles:Notify', source, "negado", Lang[Config.lang]['no_scanner'])
				end
			elseif data.action == 'Upgrade' then
				local upgrades = {}
				if Config.upgrades[vehicleData.name] then
					upgrades = Config.upgrades[vehicleData.name][data.idname]
				else
					upgrades = Config.upgrades['default'][data.idname]
				end
				if vRP.getInventoryItemAmount(owner_id, upgrades.item.name) >= upgrades.item.amount then
					if firstStep then
						TriggerClientEvent('vrp_advanced_vehicles:useTheJackFunction',source,data,firstStep)
					else
						TriggerClientEvent("progress",source,upgrades.item.time*1000,Lang[Config.lang]['upgrade_progress'])
						cancelled = false
						Citizen.Wait(upgrades.item.time*1000)

						if cancelled == false and vRP.getInventoryItemAmount(owner_id, upgrades.item.name) >= upgrades.item.amount then
							vRP.removeInventoryItem(user_id, upgrades.item.name, upgrades.item.amount, true)
							if upgrades.improvements.type == 'nitrous' then
								local sql = "UPDATE `advanced_vehicles` SET `nitroAmount` = @nitroAmount, `nitroRecharges` = @nitroRecharges WHERE  `vehicle` = @vehicle AND `user_id` = @user_id AND `plate` = @plate;";
								MySQL.Sync.execute(sql, {['@user_id'] = owner_id, ['@vehicle'] = vehicleData.name, ['@plate'] = vehicleData.plate, ['@nitroAmount'] = Config.NitroAmount, ['@nitroRecharges'] = Config.NitroRechargeAmount});
							else
								TriggerClientEvent("vrp_advanced_vehicles:upgradeCar",source,upgrades.improvements,data.idname)
							end
						

							local sql = "REPLACE INTO `advanced_vehicles_upgrades` (vehicle,user_id,plate,class,item) VALUES (@vehicle,@user_id,@plate,@class,@item)";
							MySQL.Sync.execute(sql, {['@user_id'] = owner_id, ['@vehicle'] = vehicleData.name, ['@plate'] = vehicleData.plate, ['@class'] = upgrades.class, ['@item'] = data.idname});

							TriggerClientEvent('vrp_advanced_vehicles:useTheJackFunction',source,data,firstStep)
							TriggerClientEvent("vrp_advanced_vehicles:Notify",source,"sucesso",Lang[Config.lang]['upgrade_done'])
							
						else
							TriggerClientEvent('vrp_advanced_vehicles:useTheJackFunction',source,data,firstStep)
							TriggerClientEvent("vrp_advanced_vehicles:Notify",source,"negado",Lang[Config.lang]['upgrade_cancel'])
						end
					end
				else
					itemlabel = vRP.itemNameList(upgrades.item.name)
					TriggerClientEvent('vrp_advanced_vehicles:Notify', source, "negado", Lang[Config.lang]['not_enough_items']:format(upgrades.item.amount,itemlabel))
				end
			elseif data.action == 'Downgrade' then
				local upgrades = {}
				if Config.upgrades[vehicleData.name] then
					upgrades = Config.upgrades[vehicleData.name][data.idname]
				else
					upgrades = Config.upgrades['default'][data.idname]
				end
				local sql = "SELECT item FROM `advanced_vehicles_upgrades` WHERE vehicle = @vehicle AND user_id = @user_id AND class = @class AND plate = @plate";
				local query = MySQL.Sync.fetchAll(sql, {['@user_id'] = owner_id, ['@vehicle'] = vehicleData.name, ['@plate'] = vehicleData.plate, ['@class'] = upgrades.class});
				if query[1] and query[1].item == data.idname then
					if firstStep then
						TriggerClientEvent('vrp_advanced_vehicles:useTheJackFunction',source,data,firstStep)
					else
						TriggerClientEvent("progress",source,upgrades.item.time*1000,Lang[Config.lang]['downgrade_progress'])
						cancelled = false
						Citizen.Wait(upgrades.item.time*1000)

						local sql = "SELECT item FROM `advanced_vehicles_upgrades` WHERE vehicle = @vehicle AND user_id = @user_id AND class = @class AND plate = @plate";
						local query = MySQL.Sync.fetchAll(sql, {['@user_id'] = owner_id, ['@vehicle'] = vehicleData.name, ['@plate'] = vehicleData.plate, ['@class'] = upgrades.class});
						if query[1] and query[1].item == data.idname then
							if cancelled == false then
								if upgrades.improvements.type == 'nitrous' then
									local sql = "SELECT nitroAmount, nitroRecharges FROM `advanced_vehicles` WHERE vehicle = @vehicle AND user_id = @user_id AND plate = @plate";
									local query = MySQL.Sync.fetchAll(sql, {['@user_id'] = owner_id, ['@vehicle'] = vehicleData.name, ['@plate'] = vehicleDataClient.plate});
									if query[1] and query[1].nitroAmount >= Config.NitroAmount and query[1].nitroRecharges >= Config.NitroRechargeAmount then
										local sql = "UPDATE `advanced_vehicles` SET nitroAmount = @nitroAmount, nitroRecharges = @nitroRecharges WHERE vehicle = @vehicle AND user_id = @user_id AND plate = @plate";
										MySQL.Sync.execute(sql, {['@nitroAmount'] = 0, ['@nitroRecharges'] = 0, ['@vehicle'] = vehicleData.name, ['@plate'] = vehicleData.plate, ['@user_id'] = owner_id});
									else
										TriggerClientEvent("vrp_advanced_vehicles:Notify",source,"negado",Lang[Config.lang]['downgrade_used_nitro'])
										TriggerClientEvent('vrp_advanced_vehicles:useTheJackFunction',source,data,firstStep)
										return
									end
								end

								TriggerClientEvent("vrp_advanced_vehicles:removeUpgrade",source,upgrades.improvements)

								local sql = "DELETE FROM `advanced_vehicles_upgrades` WHERE vehicle = @vehicle AND user_id = @user_id AND class = @class AND plate = @plate";
								MySQL.Sync.execute(sql, {['@user_id'] = owner_id, ['@vehicle'] = vehicleData.name, ['@plate'] = vehicleData.plate, ['@class'] = upgrades.class});

								vRP.giveInventoryItem(user_id, upgrades.item.name, upgrades.item.amount)
								--xPlayer.addInventoryItem(upgrades.item.name, upgrades.item.amount)
								TriggerClientEvent('vrp_advanced_vehicles:useTheJackFunction',source,data,firstStep)
								TriggerClientEvent("vrp_advanced_vehicles:Notify",source,"sucesso",Lang[Config.lang]['downgrade_done'])
							else
								TriggerClientEvent('vrp_advanced_vehicles:useTheJackFunction',source,data,firstStep)
								TriggerClientEvent("vrp_advanced_vehicles:Notify",source,"negado",Lang[Config.lang]['downgrade_canceled'])
							end
						else
							TriggerClientEvent('vrp_advanced_vehicles:Notify', source, "negado", Lang[Config.lang]['downgrade_error'])
						end
					end
				else
					TriggerClientEvent('vrp_advanced_vehicles:Notify', source, "negado", Lang[Config.lang]['downgrade_error'])
				end
			elseif Config.repair[data.repair] then
				local missingItems = false
					local items = ""
					
					for k,v in pairs(Config.repair[data.repair].items) do
						if vRP.getInventoryItemAmount(user_id, upgrades.item.name) < v then
						--if vRP.getInventoryItemAmount(owner_id, k).count < v then
							missingItems = true
							if items == "" then
								items = v.."x "..vRP.itemNameList[k]
							else
								items = items..", "..v.."x "..vRP.itemNameList[k]
							end
						end
					end
					
					if not missingItems then
						if firstStep then
							TriggerClientEvent('vrp_advanced_vehicles:useTheJackFunction',source,data,firstStep)
						else
							for k,v in pairs(Config.repair[data.repair].items) do
								vRP.removeInventoryItem(user_id, k, v, true)
							end
							TriggerClientEvent("progress",source,Config.repair[data.repair].time*1000,Lang[Config.lang]['repair_progress'])
							cancelled = false
		
							Citizen.Wait(Config.repair[data.repair].time*1000)
							if cancelled == false then
								TriggerClientEvent("vrp_advanced_vehicles:repairCar",source,data.repair)
								TriggerClientEvent("vrp_advanced_vehicles:Notify",source,"sucesso",Lang[Config.lang]['repair_done'])
							else
								TriggerClientEvent("vrp_advanced_vehicles:Notify",source,"negado",Lang[Config.lang]['repair_cancel'])
							end
							TriggerClientEvent('vrp_advanced_vehicles:useTheJackFunction',source,data,firstStep)
						end
					else
						TriggerClientEvent('vrp_advanced_vehicles:Notify', source, "negado", Lang[Config.lang]['not_enough_items_2']:format(items))
					end
			else
			print('Undefined action '..data.action )
			end
		end
		cooldown[source] = nil
	end
end)

RegisterServerEvent('vrp_advanced_vehicles:removeNitroUpgrade')
AddEventHandler('vrp_advanced_vehicles:removeNitroUpgrade', function(vehicleData)
	local source = source
	local owner_id = vRP.getUserByRegistration(vehicleData.plate)
	local upgrades = {}
	if Config.upgrades[vehicleData.name] then
		upgrades = Config.upgrades[vehicleData.name]
	else
		upgrades = Config.upgrades['default']
	end
	for k,v in pairs(upgrades) do 
		if v.improvements.type == 'nitrous' then
			local sql = "DELETE FROM `advanced_vehicles_upgrades` WHERE vehicle = @vehicle AND user_id = @user_id AND class = @class AND plate = @plate";
			MySQL.Sync.execute(sql, {['@user_id'] = owner_id, ['@vehicle'] = vehicleData.name, ['@plate'] = vehicleData.plate, ['@class'] = v.class});
			local sql = "UPDATE `advanced_vehicles` SET nitroAmount = @nitroAmount, nitroRecharges = @nitroRecharges WHERE vehicle = @vehicle AND user_id = @user_id AND plate = @plate";
			MySQL.Sync.execute(sql, {['@nitroAmount'] = 0, ['@nitroRecharges'] = 0, ['@vehicle'] = vehicleData.name, ['@plate'] = vehicleData.plate, ['@user_id'] = owner_id});

			local vehicleData = getVehicleData(vehicleData,owner_id)
			TriggerClientEvent('vrp_advanced_vehicles:LixeiroCB', source, {[1] = vehicleData})
		end
	end
end)

function getVehicleData(vehicleDataClient,user_id)
	local services = {}
	local query_services = {}
	local inspection = {}
	local upgrades = {}
	local sql = "SELECT km, vehicle_handling, nitroAmount, nitroRecharges FROM `advanced_vehicles` WHERE vehicle = @vehicle AND user_id = @user_id AND plate = @plate";
	local query = MySQL.Sync.fetchAll(sql, {['@vehicle'] = vehicleDataClient.name, ['@plate'] = vehicleDataClient.plate, ['@user_id'] = user_id});

	if not query or not query[1] then
		local sql = "INSERT INTO `advanced_vehicles` (user_id,vehicle,plate) VALUES (@user_id,@vehicle,@plate)";
		MySQL.Sync.execute(sql, {['@vehicle'] = vehicleDataClient.name, ['@user_id'] = user_id, ['@plate'] = vehicleDataClient.plate});

		local sql = "SELECT km, vehicle_handling, nitroAmount, nitroRecharges FROM `advanced_vehicles` WHERE vehicle = @vehicle AND user_id = @user_id AND plate = @plate";
		query = MySQL.Sync.fetchAll(sql, {['@vehicle'] = vehicleDataClient.name, ['@plate'] = vehicleDataClient.plate, ['@user_id'] = user_id});
	else
		local sql = "SELECT item, name, km, timer, img FROM `advanced_vehicles_services` WHERE vehicle = @vehicle AND user_id = @user_id AND plate = @plate ORDER BY timer DESC";
		query_services = MySQL.Sync.fetchAll(sql, {['@vehicle'] = vehicleDataClient.name, ['@plate'] = vehicleDataClient.plate, ['@user_id'] = user_id});
		local cont = {}
		for k,v in pairs(query_services) do
			if not services[v.item] then services[v.item] = {} end
			services[v.item][cont[v.item] or 1] = v.km
			cont[v.item] = (cont[v.item] or 1) + 1
		end

		local sql = "SELECT item, km, value, timer FROM `advanced_vehicles_inspection` WHERE vehicle = @vehicle AND user_id = @user_id AND plate = @plate";
		local query_inspection = MySQL.Sync.fetchAll(sql, {['@vehicle'] = vehicleDataClient.name, ['@plate'] = vehicleDataClient.plate, ['@user_id'] = user_id});
		for k,v in pairs(query_inspection) do
			inspection[v.item] = v
		end

		local sql = "SELECT item FROM `advanced_vehicles_upgrades` WHERE vehicle = @vehicle AND user_id = @user_id AND plate = @plate";
		local query_upgrades = MySQL.Sync.fetchAll(sql, {['@vehicle'] = vehicleDataClient.name, ['@plate'] = vehicleDataClient.plate, ['@user_id'] = user_id});
		for k,v in pairs(query_upgrades) do
			upgrades[v.item] = v
		end
	end

	vehicleData = query[1]
	vehicleData.services = services
	vehicleData.servicesNUI = query_services
	vehicleData.inspectionNUI = inspection
	vehicleData.upgradesNUI = upgrades
	vehicleData.plate = vehicleDataClient.plate
	vehicleData.name = vehicleDataClient.name
	vehicleData.veh = vehicleDataClient.veh
	vehicleData.km = vehicleData.km*1000
	vehicleData.loaded = true
	return vehicleData
end

RegisterNetEvent('vrp_advanced_vehicles:__sync')
AddEventHandler('vrp_advanced_vehicles:__sync', function (boostEnabled, purgeEnabled, lastVehicle)
  -- Fix for source reference being lost during loop below.
  local source = source

  for _, player in ipairs(GetPlayers()) do
    if player ~= tostring(source) then
      TriggerClientEvent('vrp_advanced_vehicles:__update', player, source, boostEnabled, purgeEnabled, lastVehicle)
    end
  end
end)

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
    end))
end

function print_table(node)
	if type(node) == 'table' then
		-- to make output beautiful
		local function tab(amt)
			local str = ""
			for i=1,amt do
				str = str .. "\t"
			end
			return str
		end

		local cache, stack, output = {},{},{}
		local depth = 1
		local output_str = "{\n"

		while true do
			local size = 0
			for k,v in pairs(node) do
				size = size + 1
			end

			local cur_index = 1
			for k,v in pairs(node) do
				if (cache[node] == nil) or (cur_index >= cache[node]) then
				
					if (string.find(output_str,"}",output_str:len())) then
						output_str = output_str .. ",\n"
					elseif not (string.find(output_str,"\n",output_str:len())) then
						output_str = output_str .. "\n"
					end

					-- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
					table.insert(output,output_str)
					output_str = ""
				
					local key
					if (type(k) == "number" or type(k) == "boolean") then
						key = "["..tostring(k).."]"
					else
						key = "['"..tostring(k).."']"
					end

					if (type(v) == "number" or type(v) == "boolean") then
						output_str = output_str .. tab(depth) .. key .. " = "..tostring(v)
					elseif (type(v) == "table") then
						output_str = output_str .. tab(depth) .. key .. " = {\n"
						table.insert(stack,node)
						table.insert(stack,v)
						cache[node] = cur_index+1
						break
					else
						output_str = output_str .. tab(depth) .. key .. " = '"..tostring(v).."'"
					end

					if (cur_index == size) then
						output_str = output_str .. "\n" .. tab(depth-1) .. "}"
					else
						output_str = output_str .. ","
					end
				else
					-- close the table
					if (cur_index == size) then
						output_str = output_str .. "\n" .. tab(depth-1) .. "}"
					end
				end

				cur_index = cur_index + 1
			end

			if (#stack > 0) then
				node = stack[#stack]
				stack[#stack] = nil
				depth = cache[node] == nil and depth + 1 or depth - 1
			else
				break
			end
		end

		-- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
		table.insert(output,output_str)
		output_str = table.concat(output)

		print(output_str)
	else
		print(node)
	end
end