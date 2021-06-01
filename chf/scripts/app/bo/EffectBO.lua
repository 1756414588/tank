
EffectBO = {}

function EffectBO.update(data)
	-- gdump(data, "[EffectBO] get effect")

	EffectMO.effects_ = {}

	if not data then return end

	local effects = PbProtocol.decodeArray(data["effect"])
	gdump(effects, "[EffectBO] get effect")

	EffectBO.updateEffects(effects)

	local function onTick(dt)
		for effectId, effect in pairs(EffectMO.effects_) do
			if effect.endTime > 0 then
				effect.leftTime = effect.leftTime - dt
				if effect.endTime <= 0 then
					gprint("effect 结束了")
				end
			end
		end
	end

	if not EffectMO.timeHandler_ then
		EffectMO.timeHandler_ = ManagerTimer.addTickListener(onTick)
	end
end

function EffectBO.updateEffects(effects)
	for index = 1, #effects do
		local effect = effects[index]
		EffectBO.updateEffect(effect)
	end
	Notify.notify(LOCAL_EFFECT_EVENT)
end

-- 注意:此方法不发送LOCAL_EFFECT_EVENT事件
function EffectBO.updateEffect(effect)
	if not effect then return end

	local leftTime = effect.endTime - ManagerTimer.getTime() + 0.99
	EffectMO.effects_[effect.id] = {effectId = effect.id, endTime = effect.endTime, leftTime = leftTime}

	if (effect.id >= EFFECT_ID_BATTLE_BASE and effect.id <= EFFECT_ID_STONE_STYLE) or 
		(effect.id >= EFFECT_ID_SKIN_ELITE and effect.id <= EFFECT_ID_SKIN_AIR_FORTRESS) or
		effect.id == EFFECT_ID_SKIN_GOST or effect.id == EFFECT_ID_SKIN_MECHANICS then  -- 这个effect只能存在一个
		-- 老皮肤特效
		for index = EFFECT_ID_BATTLE_BASE, EFFECT_ID_STONE_STYLE do
			if index ~= effect.id then
				EffectMO.effects_[index] = nil
			end
		end
		-- 新皮肤特效
		for index = EFFECT_ID_SKIN_ELITE, EFFECT_ID_SKIN_AIR_FORTRESS do
			if index ~= effect.id then
				EffectMO.effects_[index] = nil
			end
		end
		if EFFECT_ID_SKIN_MECHANICS ~= effect.id then
			EffectMO.effects_[EFFECT_ID_SKIN_MECHANICS] = nil
		end

		if index == EFFECT_ID_SKIN_GOST then
			EffectMO.effects_[EFFECT_ID_SKIN_GOST] = nil
		end
	elseif effect.id == EFFECT_ID_HURT_ADD then  -- 不能和高级效果并存
		local valid, _ = EffectBO.getEffectValid(EFFECT_ID_HURT_ADD_SENIOR)
		if valid then EffectMO.effects_[effect.id] = nil end
	elseif effect.id == EFFECT_ID_HURT_ADD_SENIOR then
		EffectMO.effects_[EFFECT_ID_HURT_ADD] = nil
	elseif effect.id == EFFECT_ID_HURT_DECAY then  -- 不能和高级效果并存
		local valid, _ = EffectBO.getEffectValid(EFFECT_ID_HURT_DECAY_SENIOR)
		if valid then EffectMO.effects_[effect.id] = nil end
	elseif effect.id == EFFECT_ID_HURT_DECAY_SENIOR then
		EffectMO.effects_[EFFECT_ID_HURT_DECAY] = nil
	elseif effect.id == EFFECT_ID_RAPID_MARCH then  -- 不能和高级效果并存
		local valid, _ = EffectBO.getEffectValid(EFFECT_ID_RAPID_MARCH_SENIOR)
		if valid then EffectMO.effects_[effect.id] = nil end
	elseif effect.id == EFFECT_ID_RAPID_MARCH_SENIOR then
		EffectMO.effects_[EFFECT_ID_RAPID_MARCH] = nil
	end
end

function EffectBO.getEffectValid(effectId)
	-- -- 资源增益
	-- if effectId == EFFECT_ID_STONE or effectId == EFFECT_ID_IRON or effectId == EFFECT_ID_OIL or effectId == EFFECT_ID_COPPER or effectId == EFFECT_ID_SILICON then
	-- 	local res = false
	-- 	local leftTime = 0

	-- 	local effect = EffectMO.getEffectById(effectId)
	-- 	if effect and effect.leftTime > 0 then
	-- 		res = true
	-- 		leftTime = effect.leftTime
	-- 	end

	-- 	-- 还需要累加处理使用了全面开采
	-- 	local effect = EffectMO.getEffectById(EFFECT_ID_RESOURCE_ALL)
	-- 	if effect and effect.leftTime > 0 then
	-- 		res = true
	-- 		if leftTime == 0 then leftTime = effect.leftTime
	-- 		else leftTime = math.min(leftTime, effect.leftTime) end
	-- 	end

	-- 	return res, leftTime
	-- else
		local effect = EffectMO.getEffectById(effectId)
		if effect and effect.leftTime > 0 then
			return true, effect.leftTime
		else
			return false, 0
		end
	-- end
end

function EffectBO.setEffectInvalid(effectId)
	local effect = EffectMO.getEffectById(effectId)
	if effect then
		EffectMO.effects_[effectId] = nil
	end
	Notify.notify(LOCAL_EFFECT_EVENT)
end

-- 宝石等资源是否处于增益中
function EffectBO.getResEffectValid(kind, id)
	local effectId = 0
	if kind == ITEM_KIND_RESOURCE then
		if id == RESOURCE_ID_STONE then effectId = EFFECT_ID_STONE
		elseif id == RESOURCE_ID_IRON then effectId = EFFECT_ID_IRON
		elseif id == RESOURCE_ID_OIL then effectId = EFFECT_ID_OIL
		elseif id == RESOURCE_ID_COPPER then effectId = EFFECT_ID_COPPER
		elseif id == RESOURCE_ID_SILICON then effectId = EFFECT_ID_SILICON
		end
	end

	return EffectBO.getEffectValid(effectId)
end

-- 皮肤特效
function EffectBO.getBattleBaseAttrData()
	-- local ids = {5, 7, 9, 11}
	-- ATTRIBUTE_INDEX_HIT = 命中
	-- ATTRIBUTE_INDEX_DODGE = 闪避
	-- ATTRIBUTE_INDEX_CRIT = 暴击
	-- ATTRIBUTE_INDEX_CRIT_DEF = 抗暴
	local attrValue = {[ATTRIBUTE_INDEX_HIT] = {}, [ATTRIBUTE_INDEX_DODGE] = {}, [ATTRIBUTE_INDEX_CRIT] = {}, [ATTRIBUTE_INDEX_CRIT_DEF] = {}}

	-- 战争基地
	local battle_base, _ = EffectBO.getEffectValid(EFFECT_ID_BATTLE_BASE)

	-- 至尊基地
	local skin_extreme, _2 = EffectBO.getEffectValid(EFFECT_ID_SKIN_EXTREME)

	for index, _ in pairs(attrValue) do
		local attrId = index
		local attrData = nil

		if battle_base then
			if index == ATTRIBUTE_INDEX_HIT then
				attrData = AttributeBO.getAttributeData(attrId, EFFECT_BATTLE_HIT_ADDITION * 1000)
			elseif index == ATTRIBUTE_INDEX_DODGE or index == ATTRIBUTE_INDEX_CRIT or index == ATTRIBUTE_INDEX_CRIT_DEF then
				attrData = AttributeBO.getAttributeData(attrId, EFFECT_BATTLE_DODGE_ADDITION * 1000)
			end
		elseif skin_extreme then
			if index == ATTRIBUTE_INDEX_HIT or index == ATTRIBUTE_INDEX_CRIT_DEF then
				attrData = AttributeBO.getAttributeData(attrId, EFFECT_SKIN_ADDITION_VALUE2 * 1000)
			elseif index == ATTRIBUTE_INDEX_DODGE or index == ATTRIBUTE_INDEX_CRIT then
				attrData = AttributeBO.getAttributeData(attrId, EFFECT_SKIN_ADDITION_VALUE1 * 1000)
			end
		else
			attrData = AttributeBO.getAttributeData(attrId, 0)
		end
		attrValue[attrData.index] = attrData
	end

	-- gdump(attrValue, "EffectBO.getBattleBaseAttrData")
	return attrValue
end

-- 获得可以在界面上显示的增益
function EffectBO.getShowEffects()
	local ret = {}
	for k,v in ipairs(EffectMO.getAllEffect()) do
		local effect = EffectMO.queryEffectById(v.effectId)
		if effect.mark == 1 then
			if v.effectId == EFFECT_ID_HURT_ADD then
				local valid, _ = EffectBO.getEffectValid(EFFECT_ID_HURT_ADD_SENIOR)  -- 如果高级的开启了，则不显示
				if not valid then
					ret[#ret + 1] = effect
				end
			elseif v.effectId == EFFECT_ID_HURT_DECAY then
				local valid, _ = EffectBO.getEffectValid(EFFECT_ID_HURT_DECAY_SENIOR)
				if not valid then
					ret[#ret + 1] = effect
				end
			elseif v.effectId == EFFECT_ID_RAPID_MARCH then
				local valid, _ = EffectBO.getEffectValid(EFFECT_ID_RAPID_MARCH_SENIOR)
				if not valid then
					ret[#ret + 1] = effect
				end
			else
				ret[#ret + 1] = effect
			end
		elseif effect.mark == 2 then  -- 需要判断当前是否有效
			local ef = EffectMO.getEffectById(v.effectId)
			if ef and ef.leftTime > 0 then
				ret[#ret + 1] = effect
				-- table.insert(ret, 1, effect)
			end
		end
	end
	local function sortEffect(effectA, effectB)
		if effectA.sort < effectB.sort then return true
		else return false end
	end

	table.sort(ret, sortEffect)
	return ret
end
