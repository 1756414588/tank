--
-- Author: Your Name
-- Date: 2017-04-27 16:27:20
--


MaterialMO = {}

local s_matrial = require("app.data.s_lord_equip_material")

local s_matrial_  = nil

MaterialMO.buyCount_ = nil
MaterialMO.refreshHandler_ = nil

function MaterialMO.init()
	if not s_matrial_ then
		s_matrial_ = {}
		local records = DataBase.query(s_matrial)
		for index = 1, #records do
			local awards = records[index]
			if not s_matrial_[awards.tag] then s_matrial_[awards.tag] = {} end
			if not s_matrial_[awards.tag][awards.quality] then s_matrial_[awards.tag][awards.quality] = {} end
			table.insert(s_matrial_[awards.tag][awards.quality],awards)
		end
	end
end

--通过品质和ID索取到信息(id为1是材料。为2是图纸)
function MaterialMO.queryPaperByQuality(tag,quality)
	if not s_matrial_[tag] then return nil end
	return s_matrial_[tag][quality]
end

--通过品质从当前拥有的所有图纸中索取对应品质的ID
function MaterialMO.getPaperByQuality(quality)
	if not quality then return end
	local myPaper = WeaponryMO.getAllChipsByType(2)
	local paperInfo = {}
	local paper = {}
	for k,v in pairs(myPaper) do
		local wb = WeaponryMO.queryPaperById(v.propId)
		wb = clone(wb)
		wb.count = v.count
		if wb.quality == quality then
			paper[#paper + 1] = wb
		end
	end
	return paper
end