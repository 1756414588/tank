--
-- Author: Xiaohang
-- Date: 2016-05-04 11:55:13
--
local s_military = require("app.data.s_military")
local s_military_material = require("app.data.s_military_material")
local s_military_develop_tree = require("app.data.s_military_develop_tree")
OrdnanceMO = {}
local ROME = {"Ⅰ","Ⅱ","Ⅲ","Ⅳ","Ⅴ","Ⅵ","Ⅶ","Ⅷ","Ⅸ","Ⅹ"}
local db_military_ = nil
local db_military_material_ = nil
local db_military_develop_tree_ = nil

OrdnanceMO.tankAllScience_ = nil

function OrdnanceMO.init()
	db_military_ = {}
	local records = DataBase.query(s_military)
	for index = 1, #records do
		local data = records[index]
		db_military_[data.tankId] = data
	end

	db_military_develop_tree_ = {}
	local records = DataBase.query(s_military_develop_tree)
	for index = 1, #records do
		local data = records[index]
		if not db_military_develop_tree_[data.id] then
			db_military_develop_tree_[data.id] = {}
		end
		db_military_develop_tree_[data.id][data.level] = data
	end

	db_military_material_ = {}
	local records = DataBase.query(s_military_material)
	for index = 1, #records do
		local data = records[index]
		db_military_material_[data.id] = data
	end
end

--获取军工科技显示列表
function OrdnanceMO.getList()
	local list = {}
	for k,v in pairs(db_military_) do
		local to = TankMO.queryTankById(v.tankId)
		local kind = 0
		if to.canBuild == 0 then
			kind = to.type
		else
			kind = to.type + 4
		end
		if not list[kind] then
			list[kind] = {id=to.tankId,list={}}
		end
		table.insert(list[kind].list, v)
	end
	return list
end

function OrdnanceMO.queryTankById(tankId)
	if not tankId or tankId <= 0 then
		gprint("[OrdnanceMO] queryTankById id is Error:", tankId)
	end
	return db_military_[tankId]
end

function OrdnanceMO.queryScienceById(scienceId,level)
	level = level or 1
	return db_military_develop_tree_[scienceId][level]
end

function OrdnanceMO.queryMaterialById(id)
	return db_military_material_[id]
end


function OrdnanceMO.getImgById(scienceId,tankId,isGray)
	local so = OrdnanceMO.queryScienceById(scienceId)
	local frame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png")
	local node = display.newNode():size(frame:width(),frame:height())
	local ao = AttributeMO.queryAttributeById(so.attrId)
	if so.attrId <= 22 then
		if isGray then
			display.newGraySprite("image/item/attr_" .. ao.attrName .. ".jpg"):addTo(node):center()
		else
			display.newSprite("image/item/attr_" .. ao.attrName .. ".jpg"):addTo(node):center()
		end
	else
		--坦克信息
		local tankDB = TankMO.queryTankById(tankId)
		if isGray then
			display.newGraySprite("image/tank/tank_" .. tankId .. ".png"):addTo(node):center():scale(0.7)
		else
			display.newSprite("image/tank/tank_" .. tankId .. ".png"):addTo(node):center():scale(0.7)
		end
		display.newSprite("image/item/attr_" .. ao.attrName .. ".png"):addTo(node,3):pos(15,80)
	end
	display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node):center()
	node:setAnchorPoint(cc.p(0.5,0.5))

	local data = OrdnanceBO.queryScienceById(scienceId)
	local t = display.newSprite(IMAGE_COMMON.."info_bg_54.png"):addTo(node):pos(node:width()/2, 15)
	UiUtil.label(data.level .."/" ..#db_military_develop_tree_[scienceId]):addTo(t):center()
	if so.attrId <= 22 and ROME[data.level] then
		UiUtil.label(ROME[data.level],26,COLOR[12]):addTo(node,10):pos(22,80)
	end
	return node
end

function OrdnanceMO.getNameById(scienceId)
	local so = OrdnanceMO.queryScienceById(scienceId)
	local ao = AttributeBO.getAttributeData(so.attrId,0)
	local name = ""
	local to = TankMO.queryTankById(so.tankId)
	return to.name ..ao.name
end

function OrdnanceMO.getAttr(scienceId,lv)
	local so = OrdnanceMO.queryScienceById(scienceId,lv == 0 and 1 or lv)
	if not so then
		so = OrdnanceMO.queryScienceById(scienceId,lv-1)
	end
	local re = json.decode(so.effect)
	local name = {}
	for k,v in ipairs(re) do
		local value = AttributeBO.getAttributeData(v[1],0).name
		if v[1] == 26 then --效率改装
			value = value .."-" ..(lv == 0 and 0 or v[3]) .."S"
		elseif v[1] == 28 then
		else
			value = value .."+" ..AttributeBO.getAttributeData(v[1],lv == 0 and 0 or v[2]).strValue
		end
		table.insert(name,value)
	end
	return name
end

function OrdnanceMO.getTankScience(tankId,attr)
	if not OrdnanceMO.tankScience_ then
		OrdnanceMO.tankScience_ = {}
		OrdnanceMO.tankAttr_ = {}
		for k,v in pairs(db_military_develop_tree_) do
			if not OrdnanceMO.tankAttr_[v[1].tankId] then
				OrdnanceMO.tankAttr_[v[1].tankId] = {}
			end
			OrdnanceMO.tankAttr_[v[1].tankId][v[1].attrId] = v[1].id
			local re = json.decode(v[1].require)
			if re[1][1] then --有数据
				for m,n in ipairs(re) do
					local mo = OrdnanceMO.queryScienceById(n[1])
					if mo.attrId ~= 28 then
						if not OrdnanceMO.tankScience_[v[1].tankId] then
							OrdnanceMO.tankScience_[v[1].tankId] = {}
						end
						local temp = {p=k,id=n[1]}
						table.insert(OrdnanceMO.tankScience_[v[1].tankId], temp)
					end
				end
			end
		end
	end
	if not attr then
		return OrdnanceMO.tankScience_[tankId]
	else
		return OrdnanceMO.tankAttr_[tankId]
	end
end


function OrdnanceMO.getTankAllScience(tankId)
	-- body
	if not OrdnanceMO.tankAllScience_ then
		OrdnanceMO.tankAllScience_ = {}
		for k,v in pairs(db_military_develop_tree_) do
			local tId = v[1].tankId
			if OrdnanceMO.tankAllScience_[tId] == nil then
				OrdnanceMO.tankAllScience_[tId] = {}
			end
			table.insert(OrdnanceMO.tankAllScience_[tId], {id=v[1].id})
		end
	end

	return OrdnanceMO.tankAllScience_[tankId]
end

function OrdnanceMO.checkUnOpen(scienceId)
	local data = OrdnanceBO.queryScienceById(scienceId)
	local so = OrdnanceMO.queryScienceById(scienceId,data.level+1)
	local max = nil
	if not so then
		max = true
		so = OrdnanceMO.queryScienceById(scienceId,data.level)
	end
	local re = json.decode(so.require)
	local name = {}
	local unOpen = false
	for k,v in ipairs(re) do
		if v[1] and v[1] > 0 then
			local temp = {}
			temp.name = OrdnanceMO.getNameById(v[1]) .."Lv."..v[2]
			local t = OrdnanceBO.queryScienceById(v[1])
			temp.unOpen = t.level < v[2]
			table.insert(name, temp)
			if not unOpen and t.level < v[2] then
				unOpen = true
			end
		end
	end
	if #name == 0 then
		table.insert(name,{name=CommonText[108]})
	end
	return unOpen,name,max
end

--获取可生产的tank列表
function OrdnanceMO.getProduceList()
	local list = {}
	for k,v in pairs(db_military_) do
		if v.militaryRefitBaseTankId > 0 then
			list[v.militaryRefitBaseTankId] = v.tankId
		end
	end
	return list
end