local s_scout_pic = require("app.data.s_scoutPicId")
local s_scout_genus = require("app.data.s_scoutGenus")
local s_scout_species = require("app.data.s_scoutSpecies")

PictureValidateMO = {}

--图片对应的文件名称以文件id为索引
local db_scout_pic = nil
--图片对应的大类以类的id为索引
local db_scout_genus = nil
--图片对应的小类以类的id为索引
local db_scout_species = nil

function PictureValidateMO.init()
	db_scout_pic = {}
	local records = DataBase.query(s_scout_pic)
	for index = 1, #records do
		local data = records[index]
		db_scout_pic[data.keyId] = data
	end

	db_scout_genus = {}
	local records = DataBase.query(s_scout_genus)
	for index = 1, #records do
		local data = records[index]
		db_scout_genus[data.genusId] = data
	end

	db_scout_species = {}
	local records = DataBase.query(s_scout_species)
	for index = 1, #records do
		local data = records[index]
		db_scout_species[data.speciesId] = data
	end
end

function PictureValidateMO.getPicById(id)
	return db_scout_pic[id].filename
end

function PictureValidateMO.getGenusById(id)
	return db_scout_genus[id].genusName
end

function PictureValidateMO.getSpeciesById(id)
	return db_scout_species[id].speciesName
end

--将服务端发来的图片id数组转化为图片名称
function PictureValidateMO.getPicNameById(t)
	gdump(t,"传过来的信息")
	local pictures = {}
	for index=1, #t do
		if t[index] >=15 and t[index] <= 24 then
			local p = PictureValidateMO.getPicById(t[index])
			p = "image/express/"..p
			table.insert(pictures,p)
		elseif t[index] >= 36 and t[index] <= 44 then
			local p = PictureValidateMO.getPicById(t[index])
			p = "image/energy/"..p
			table.insert(pictures,p)
		else
			local p = PictureValidateMO.getPicById(t[index])
			p = "image/item/"..p
			table.insert(pictures,p)
		end
	end
	gdump(pictures,"要显示的图片")
	return pictures
end