
SkillBO = {}

function SkillBO.update(data)
	-- gdump(data, "[SkillBO] update GetSkill")

	SkillMO.skill_ = {}
	
	if not data then return end

	local skills = PbProtocol.decodeArray(data["skill"])
	for index = 1, #skills do
		local s = skills[index]
		SkillMO.skill_[s.id] = {skillId = s.id, level = s.lv}
	end

	SkillMO.dirtySkillData_ = false
end

function SkillBO.getSkillAttrData(skillId)
	local skillDB = SkillMO.querySkillById(skillId)
	local level = SkillMO.getSkillLevelById(skillId)

	local value = skillDB.attrValue * level

	return AttributeBO.getAttributeData(skillDB.attr, value)
end

function SkillBO.getTankTypeSkillAttrData(tankType)
	local ret = {}
	local skillNum = SkillMO.queryMaxSkill()
	for index = 1, skillNum do
		local skillDB = SkillMO.querySkillById(index)
		if skillDB.target == 0 or (tankType == skillDB.target) then
			local attr = SkillBO.getSkillAttrData(index)
			if not ret[attr.index] then ret[attr.index] = attr
			else ret[attr.index].value = ret[attr.index].value + attr.value end
		end
	end
	return ret
end

function SkillBO.asynGetSkill(doneCallback)
	local function parseGetSkill(name, data)
		SkillBO.update(data)
		if doneCallback then doneCallback() end
	end

	SkillMO.dirtySkillData_ = true

	SocketWrapper.wrapSend(parseGetSkill, NetRequest.new("GetSkill")) 
end

function SkillBO.asynUpSkill(doneCallback, skillId)
	local function parseUpSkill(name, data)
		gdump(data, "[SkillBO] up skill")

		if not SkillMO.skill_[skillId] then SkillMO.skill_[skillId] = {} end
		SkillMO.skill_[skillId].skillId = skillId
		SkillMO.skill_[skillId].level = data.lv

		-- 技能书
		UserMO.updateResource(ITEM_KIND_PROP, data.bookCount, PROP_ID_SKILL_BOOK)

		UserBO.triggerFightCheck()
		if doneCallback then doneCallback() end
		--引导触发
		NewerBO.showNewerGuide()
		-- 埋点
		Statistics.postPoint(STATIS_POINT_COMMANDER)
	end

	SocketWrapper.wrapSend(parseUpSkill, NetRequest.new("UpSkill", {id = skillId}))
end

function SkillBO.asynResetSkill(doneCallback)
	local function parseResetSkill(name, data)
		gdump(data, "[SkillBO] reset skill")

		local maxSkillId = SkillMO.queryMaxSkill()
		for index = 1, maxSkillId do
			if SkillMO.skill_[index] then
				SkillMO.skill_[index].level = 0
			end
		end

		UserMO.updateResource(ITEM_KIND_PROP, data.book, PROP_ID_SKILL_BOOK)

		--TK统计
		TKGameBO.onUseCoinTk(data.gold,TKText[24],TKGAME_USERES_TYPE_UPDATE)
		UserMO.updateResource(ITEM_KIND_COIN, data.gold)

		UserBO.triggerFightCheck()
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseResetSkill, NetRequest.new("ResetSkill"))
end
