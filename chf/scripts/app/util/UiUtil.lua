
UiUtil = {}

function armature_callback(armature, movementHandler)
	if not armature then return end

	armature:connectMovementEventSignal(function(movementType, movementID)
			if movementHandler then movementHandler(movementType, movementID, armature) end
		end)
end

--四舍五入
function Rounding(isEnable, num)
	if isEnable then
		return num + 0.5
	end
	return num
end

-- 如果数量超过千，则简化为小数点后一位并带K后缀形式 
-- detailed 显示明细 直接返回原值
-- rounding 是否对舍弃位四舍五入
--[[
function UiUtil.strNumSimplify(number, hasFloat, detailed, rounding)
	if hasFloat == nil then hasFloat = true end
	rounding = rounding or false

	number = number or 0
	if detailed then return number .. "" end
	-- if true then return number .. "" end
	if hasFloat then
		if number     > 999999999999999 then return string.format("%.1fP", math.floor(Rounding(rounding, number / 100000000000000)) / 10)
		elseif number > 999999999999 then return string.format("%.1fT", math.floor(Rounding(rounding, number / 100000000000)) / 10)
		elseif number > 999999999 then return string.format("%.1fG", math.floor(Rounding(rounding, number / 100000000)) / 10)
		elseif number > 999999 then return string.format("%.1fM", math.floor(Rounding(rounding, number / 100000)) / 10)
		elseif number > 999 then return string.format("%.1fK", math.floor(Rounding(rounding, number / 100)) / 10)
		else return number .. "" end
		-- if number     > 999999999999999 then return string.format("%.1fT", number / 1000000000000000)
		-- elseif number > 999999999999 then return string.format("%.1fT", number / 1000000000000)
		-- elseif number > 999999999 then return string.format("%.1fG", number / 1000000000)
		-- elseif number > 999999 then return string.format("%.1fM", number / 1000000)
		-- elseif number > 999 then return string.format("%.1fK", number / 1000)
		-- else return number .. "" end
	else
		if number     > 999999999999999 then return string.format("%dP", math.floor(Rounding(rounding, number / 1000000000000000)))
		elseif number > 999999999999 then return string.format("%dT", math.floor(Rounding(rounding, number / 1000000000000)))
		elseif number > 999999999 then return string.format("%dG", math.floor(Rounding(rounding, number / 1000000000)))
		elseif number > 999999 then return string.format("%dM", math.floor(Rounding(rounding, number / 1000000)))
		elseif number > 999 then return string.format("%dK", math.floor(Rounding(rounding, number / 1000)))
		else return number .. "" end
	end
end
]]--

function UiUtil.strNumSimplify(number, hasFloat, detailed, rounding)
	if hasFloat == nil then hasFloat = true end
	rounding = rounding or false
	number = number or 0
	if detailed then return number .. "" end
	if hasFloat then
		if number > 9999999 then
			if number < 100000000 then
				return string.format("%.2f亿", math.floor(Rounding(rounding, number / 1000000)) / 100)
			end
			return string.format("%.1f亿", math.floor(Rounding(rounding, number / 10000000)) / 10)
		elseif number > 9999 then
			return string.format("%.1f万", math.floor(Rounding(rounding, number / 1000)) / 10)
		else
			return number .. ""
		end
	else
		if number > 99999999 then
			return string.format("%d亿", math.floor(Rounding(rounding, number / 10000000)) / 10)
		elseif number > 9999  then
			return string.format("%d万", math.floor(Rounding(rounding, number / 1000)) / 10)
		else
			return number .. ""
		end
	end
end


--按照M为单位显示
function UiUtil.strNumSimplifySign(number)
	if number < 10000000 then
		return number
	else
		if number > 9999999 then
			if number < 100000000 then
				return string.format("%.2f亿", math.floor(Rounding(rounding, number / 1000000)) / 100)
			end
			return string.format("%.1f亿", math.floor(Rounding(rounding, number / 10000000)) / 10)
		elseif number > 9999 then
			return string.format("%.1f万", math.floor(Rounding(rounding, number / 1000)) / 10)
		else
			return number .. ""
		end
		-- return string.format("%.1fM", math.floor(number / 100000) / 10)
	end
end

-- 将建筑建造时间seconds秒转换为时分秒格式
-- format；格式,如"dh"表示只显示天和小时，如果为空，则都显示；如果"ds"只会显示天，其他的都不会显示;为""，表示不显示d,h,s等字母
-- ischinese：中文格式
function UiUtil.strBuildTime(seconds, format, ischinese)
	format = format or "dhms"
	format = string.lower(format)

	local isDay = false
	if string.find(format, "d") then isDay = true end

	local isHour = false
	if string.find(format, "h") then isHour = true end

	local isMin = false
	if string.find(format, "m") then isMin = true end

	local isSec = false
	if string.find(format, "s") then isSec = true end

	if seconds >= 86400 then --大于一天。不显示
		isSec = false
	end

	if format == "" then
		local time = ManagerTimer.time(seconds)
		if time.day > 0 then return string.format("%d:%02d:%02d:%02d", time.day, time.hour, time.minute, time.second)
		elseif time.hour > 0 then return string.format("%02d:%02d:%02d", time.hour, time.minute, time.second)
		else return string.format("%02d:%02d", time.minute, time.second)
		end
	elseif ischinese then
		if not isSec then -- 不显示秒
			local time = ManagerTimer.time(seconds)
			if time.day > 0 then return string.format("%d%s%02d%s%02d%s", time.day, CommonText[159][4], time.hour, CommonText[159][3], time.minute, CommonText[159][2])
			elseif time.hour > 0 then return string.format("%02d%s%02d%s", time.hour, CommonText[159][3], time.minute, CommonText[159][2])
			else return string.format("%02d%s%02d%s", time.minute, CommonText[159][2], time.second, CommonText[159][1])
			end
		else
			local time = ManagerTimer.time(seconds)
			if time.day > 0 then return string.format("%d%s%02d%s%02d%s%02d%s", time.day, CommonText[159][4], time.hour, CommonText[159][3], time.minute, CommonText[159][2], time.second, CommonText[159][1])
			elseif time.hour > 0 then return string.format("%02d%s%02d%s%02d%s", time.hour, CommonText[159][3], time.minute, CommonText[159][2], time.second, CommonText[159][1])
			else return string.format("%02d%s%02d%s", time.minute, CommonText[159][2], time.second, CommonText[159][1])
			end
		end
	else 
		if not isSec then -- 不显示秒
			local time = ManagerTimer.time(seconds)
			if time.day > 0 then return string.format("%dd%02dh%02dm", time.day, time.hour, time.minute)
			elseif time.hour > 0 then return string.format("%02dh%02dm", time.hour, time.minute)
			else return string.format("%02dm%02ds", time.minute, time.second)
			end
		else
			local time = ManagerTimer.time(seconds)
			if time.day > 0 then return string.format("%dd%02dh%02dm%02ds", time.day, time.hour, time.minute, time.second)
			elseif time.hour > 0 then return string.format("%02dh%02dm%02ds", time.hour, time.minute, time.second)
			else return string.format("%02dm%02ds", time.minute, time.second)
			end
		end
	end
end

function UiUtil.createItemSprite(kind, id, param)
	armature_add(IMAGE_ANIMATION .. "hero/fengxingzhetouxiang.pvr.ccz", IMAGE_ANIMATION .. "hero/fengxingzhetouxiang.plist", IMAGE_ANIMATION .. "hero/fengxingzhetouxiang.xml")
	armature_add(IMAGE_ANIMATION .. "hero/youyingtouxiang.pvr.ccz", IMAGE_ANIMATION .. "hero/youyingtouxiang.plist", IMAGE_ANIMATION .. "hero/youyingtouxiang.xml")
	armature_add(IMAGE_ANIMATION .. "hero/diaogetouxiang.pvr.ccz", IMAGE_ANIMATION .. "hero/diaogetouxiang.plist", IMAGE_ANIMATION .. "hero/diaogetouxiang.xml")
	armature_add(IMAGE_ANIMATION .. "hero/aogusitetouxiang.pvr.ccz", IMAGE_ANIMATION .. "hero/aogusitetouxiang.plist", IMAGE_ANIMATION .. "hero/aogusitetouxiang.xml")

	-- armature_add(IMAGE_ANIMATION .. "hero/aogusitetouxiang.pvr.ccz", IMAGE_ANIMATION .. "hero/aogusitetouxiang.plist", IMAGE_ANIMATION .. "hero/aogusitetouxiang.xml")
	armature_add(IMAGE_ANIMATION .. "hero/anxingtouxiang.pvr.ccz", IMAGE_ANIMATION .. "hero/anxingtouxiang.plist", IMAGE_ANIMATION .. "hero/anxingtouxiang.xml")
	armature_add(IMAGE_ANIMATION .. "hero/leiditouxiang.pvr.ccz", IMAGE_ANIMATION .. "hero/leiditouxiang.plist", IMAGE_ANIMATION .. "hero/leiditouxiang.xml")
	-- armature_add(IMAGE_ANIMATION .. "hero/beiertouxiang.pvr.ccz", IMAGE_ANIMATION .. "hero/beiertouxiang.plist", IMAGE_ANIMATION .. "hero/beiertouxiang.xml")
	-- armature_add(IMAGE_ANIMATION .. "hero/tiepangtouxiang.pvr.ccz", IMAGE_ANIMATION .. "hero/tiepangtouxiang.plist", IMAGE_ANIMATION .. "hero/tiepangtouxiang.xml")

	param = param or {}
	local view = nil
	if kind == ITEM_KIND_COIN then
		view = display.newSprite(IMAGE_COMMON .. "icon_coin.png")
	elseif kind == ITEM_KIND_RESOURCE then
		if id == RESOURCE_ID_IRON then
			view = display.newSprite(IMAGE_COMMON .. "icon_iron.png")
			view:setScale(0.35)
		elseif id == RESOURCE_ID_OIL then
			view = display.newSprite(IMAGE_COMMON .. "icon_oil.png")
			view:setScale(0.35)
		elseif id == RESOURCE_ID_COPPER then
			view = display.newSprite(IMAGE_COMMON .. "icon_copper.png")
			view:setScale(0.35)
		elseif id == RESOURCE_ID_SILICON then
			view = display.newSprite(IMAGE_COMMON .. "icon_silicon.png")
			view:setScale(0.35)
		elseif id == RESOURCE_ID_STONE then
			view = display.newSprite(IMAGE_COMMON .. "icon_gem.png")
			view:setScale(0.35)
		end
	elseif kind == ITEM_KIND_TANK then
		-- local tankDB = TankMO.queryTankById(id)
		local sprite
		if id >= 200 and id <= 207 then
			sprite = display.newSprite("image/tank/tank_1.png") ---特殊处理飞艇显示BUG
		else
			sprite = display.newSprite("image/tank/tank_" .. id .. ".png")
		end
		sprite:setScale(0.75)
		view = sprite
	elseif kind == ITEM_KIND_PROP then
		view = display.newSprite(IMAGE_COMMON .. "icon_gem.png")
	-- elseif kind == ITEM_KIND_SCIENCE then
	-- 	view = display.newSprite(IMAGE_COMMON .. "btn_box_normal.png")
	elseif kind == ITEM_KIND_HERO then
		if id == 0 then
			view = display.newSprite(IMAGE_COMMON .. "info_bg_31.png")
		else
			local asset = HeroMO.queryHero(id).asset
			view = display.newSprite("image/item/" .. asset .. ".jpg")
		end
	elseif kind == ITEM_KIND_AWAKE_HERO then
		if id == 0 then
			view = display.newSprite(IMAGE_COMMON .. "info_bg_31.png")
		else
			local hero = HeroMO.queryHero(id)
			if hero.awakenSkillArr then
				-- 觉醒完成
				local asset = hero.map
				-- view = display.newSprite("image/item/" .. asset .. ".jpg")
				if asset == "tiepang" or asset == "beier" then
					asset = "youying"
				end
				view = armature_create(asset.."touxiang")
				view:getAnimation():playWithIndex(0)
			else
				-- 开启觉醒
				local asset = hero.asset
				view = display.newSprite("image/item/" .. asset .. ".jpg")
			end
		end
	elseif kind == ITEM_KIND_WEAPONRY_ICON then
		view = display.newSprite(IMAGE_COMMON .. "info_bg_31.png")
		
	elseif kind == ITEM_KIND_PORTRAIT then
		if id < 0 then id = 0 end
		if id == 0 then
			view = display.newSprite("image/common/info_bg_31.png")
		else
			local _portrait = PendantMO.queryPortrait(id)
			if _portrait.isdynamic > 0 then
				-- animation\hero
				view = armature_create(_portrait.asset .."touxiang")
				view:getAnimation():playWithIndex(0)
			else
				view = display.newSprite("image/item/h_" .. id .. ".jpg")
			end
		end
	elseif kind == ITEM_KIND_BUILD then
		if not id or id == 0 then
			view = display.newSprite("image/build/main_empty.png")
		else
			local buildDB = BuildMO.queryBuildById(id)
			if id == BUILD_ID_COMMAND then
				local idx = 0
				local lv = BuildMO.getBuildLevel(id)
				if lv < 13 then idx = 1
				elseif lv < 25 then idx = 2
				elseif lv < 37 then idx = 3
				elseif lv < 49 then idx = 4
				elseif lv < 61 then idx = 5
				else idx = 6 end
				view = display.newSprite("image/build/main_" .. buildDB.asset .. "_" .. idx .. ".png")
			else
				view = display.newSprite("image/build/main_" .. buildDB.asset .. ".png")
			end
		end
	elseif kind == ITEM_KIND_PARTY_BUILD then
		if not id or id == 0 then
			view = display.newSprite("image/build/main_empty.png")
		else
			view = display.newSprite("image/build/main_" .. HomePartyMapConfig[id].asset .. ".png")
		end
	elseif kind == ITEM_KIND_VIP then
		return display.newSprite("image/common/vip/vip_" .. id .. ".png")
	elseif kind == ITEM_KIND_SEX then
		return display.newSprite("image/common/icon_sex_" .. id .. ".png")
	elseif kind == ITEM_KIND_WORLD_RES then  -- 世界资源
 		cc.SpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("image/world/world.plist", "image/world/world.png")
		if not param.level then param.level = 0 end
		if id == WORLD_ID_BUILD then
			return display.newSprite("#w_b_" .. param.level .. ".png")
		else
			local index = 0
			if param.level <= 20 then index = 1
			elseif param.level <= 40 then index = 2
			else index = 3
			end
			return display.newSprite("#w_r_" .. id .. "_" .. index .. ".png")
		end
	elseif kind == ITEM_KIND_HUANGBAO then
		return display.newSprite("image/common/icon_huangbao.png")
	elseif kind == ITEM_KIND_HUNTER_COIN then
		return display.newSprite("image/common/bounty_coin.png")
	elseif kind == ITEM_KIND_MILITARY_MINE then -- 军事矿
 		cc.SpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("image/world/world.plist", "image/world/world.png")
		local sprite = display.newSprite("#w_r_" .. id .. "_3.png")
		sprite:setCascadeColorEnabled(true)
		if id == 1 then  -- 铁
			local build = UiUtil.createItemSprite(ITEM_KIND_BUILD, BUILD_ID_IRON):addTo(sprite)
			build:setScale(0.38)
			build:setPosition(sprite:getContentSize().width / 2, 8)
			sprite.build = build
		elseif id == 2 then  -- 石油
			local build = UiUtil.createItemSprite(ITEM_KIND_BUILD, BUILD_ID_OIL):addTo(sprite)
			build:setScale(0.38)
			build:setPosition(sprite:getContentSize().width / 2, 8)
			sprite.build = build
		elseif id == 3 then  -- 铜
			local build = UiUtil.createItemSprite(ITEM_KIND_BUILD, BUILD_ID_COPPER):addTo(sprite)
			build:setScale(0.38)
			build:setPosition(sprite:getContentSize().width / 2, 8)
			sprite.build = build
		elseif id == 4 then  -- 硅
			local build = UiUtil.createItemSprite(ITEM_KIND_BUILD, BUILD_ID_SILICON):addTo(sprite)
			build:setScale(0.38)
			build:setPosition(sprite:getContentSize().width / 2, 8)
			sprite.build = build
		elseif id == 5 then  -- 宝石
			local build = UiUtil.createItemSprite(ITEM_KIND_BUILD, BUILD_ID_STONE):addTo(sprite)
			build:setScale(0.38)
			build:setPosition(sprite:getContentSize().width / 2, 8)
			sprite.build = build
		end
		return sprite
	elseif kind == ITEM_KIND_LABORATORY_RES then
		local info = LaboratoryMO.queryLaboratoryForItemById(id)
		return display.newSprite(IMAGE_COMMON .. "laboratory/" .. info.picture .. ".jpg")
	end
	return view
end

-- param: 创建ItemView的参数
-- 当kind是ITEM_KIND_EQUIP时，id为0，表示没有装备，图标为灰的；param如果有equipLv字段则显示等级值，没有则不显示；如果是经验，只会显示经验值
-- 当kind是ITEM_KIND_PART时，id为0，表示没有配件，图标为灰的；param如果有upLv字段则显示强化等级值，没有则不显示；如果有refitLv则表示改装等级值，没有则不显示
-- 当kind是ITEM_KIND_CHIP时，param如果有count字段则显示碎片的数量
function UiUtil.createItemView(kind, id, param)
	-- armature_add(IMAGE_ANIMATION .. "hero/youtingtouxiang.pvr.ccz", IMAGE_ANIMATION .. "hero/youtingtouxiang.plist", IMAGE_ANIMATION .. "hero/youtingtouxiang.xml")
	-- armature_add(IMAGE_ANIMATION .. "hero/diaogetouxiang.pvr.ccz", IMAGE_ANIMATION .. "hero/diaogetouxiang.plist", IMAGE_ANIMATION .. "hero/diaogetouxiang.xml")

	param = param or {}

	local node = display.newNode()
	node.kind = kind
	node.id = id
	node.param = param

	local bg = nil
	
	if kind == ITEM_KIND_HERO then
		bg = display.newSprite(IMAGE_COMMON .. "btn_head_normal.png"):addTo(node)
	elseif kind == ITEM_KIND_PORTRAIT then
		bg = display.newSprite(IMAGE_COMMON .. "btn_head_normal.png"):addTo(node)
	elseif kind == ITEM_KIND_AWAKE_HERO then
		if HeroMO.queryHero(id).awakenSkillArr then
			bg = display.newSprite(IMAGE_COMMON .. "btn_awake_head_normal.png"):addTo(node)
		else
			bg = display.newSprite(IMAGE_COMMON .. "btn_head_normal.png"):addTo(node)
		end
	elseif kind == ITEM_KIND_EQUIP then
		if id ~= 0 then
			local equipDB = EquipMO.queryEquipById(id)
			if not equipDB then equipDB = {quality = 1} end
			bg = display.newSprite(IMAGE_COMMON .. "item_bg_" .. equipDB.quality .. ".png"):addTo(node)
		else
			bg = display.newSprite(IMAGE_COMMON .. "item_bg_0.png"):addTo(node)
		end
	elseif kind == ITEM_KIND_PART or kind == ITEM_KIND_CHIP or kind == ITEM_KIND_ENERGY_SPAR then
		if id ~= 0 then
			local part = PartMO.queryPartById(id)
			if not part then part = {quality = 1} end
			bg = display.newSprite(IMAGE_COMMON .. "item_bg_" .. (part.quality + 1) .. ".png"):addTo(node)
		else
			bg = display.newSprite(IMAGE_COMMON .. "item_bg_1.png"):addTo(node)
		end
	elseif kind == ITEM_KIND_TANK then  -- 坦克
		local tank = TankMO.queryTankById(id)
		bg = display.newSprite(IMAGE_COMMON .. "item_bg_".. tank.grade .. ".png"):addTo(node)
	elseif kind == ITEM_KIND_SCORE or kind == ITEM_KIND_HUANGBAO then
		bg = display.newSprite(IMAGE_COMMON .. "item_bg_5.png"):addTo(node)
	elseif kind == ITEM_KIND_MEDAL_ICON or kind == ITEM_KIND_MEDAL_CHIP then
		local md = MedalMO.queryById(id)
		bg = display.newSprite(IMAGE_COMMON .. "item_bg_" .. md.quality .. ".png"):addTo(node)
	elseif kind == ITEM_KIND_WEAPONRY_ICON then
		local md = WeaponryMO.queryById(id)
		bg = display.newSprite(IMAGE_COMMON .. "item_bg_" .. md.quality .. ".png"):addTo(node)
	elseif kind == ITEM_KIND_WEAPONRY_PAPER then
		local md = WeaponryMO.queryPaperById(id)
		bg = display.newSprite(IMAGE_COMMON .. "item_bg_" .. md.quality .. ".png"):addTo(node)
	elseif kind == ITEM_KIND_WEAPONRY_SKILL then
		bg = display.newSprite(IMAGE_COMMON .. "weap_bg.jpg"):addTo(node)
	-- elseif kind == ITEM_KIND_LABORATORY_RES then
	-- 	bg = display.newSprite(IMAGE_COMMON .. "item_bg_0.png"):addTo(node)
	elseif kind == ITEM_KIND_TACTIC or kind == ITEM_KIND_TACTIC_PIECE then --战术。战术碎片。战术材料
		local tactics = TacticsMO.queryTacticById(id)
		bg = display.newSprite("image/tactics/tactic_quility_"..tactics.quality..".png"):addTo(node)
	else
		bg = display.newSprite(IMAGE_COMMON .. "item_bg_0.png"):addTo(node)
	end
	bg:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)

	node:setContentSize(bg:getContentSize())
	node:setAnchorPoint(cc.p(0.5, 0.5))
	node.bg_ = bg
	local strLabel = nil
	local suffix = nil
	if kind == ITEM_KIND_EXP then
		local sprite = display.newSprite("image/item/exp.jpg"):addTo(node)
		sprite:setPosition(sprite:getContentSize().width / 2, sprite:getContentSize().height / 2)
		node.sprite_ = sprite
		
		if param.count and param.count > 0 then  -- 显示数量
			-- local resData = UserMO.getResourceData(kind, id)

			strLabel = ui.newTTFLabel({text = UiUtil.strNumSimplify(param.count), font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[1], algin = ui.TEXT_ALIGN_CENTER})

			suffix = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(node)
			suffix:setPreferredSize(cc.size(strLabel:getContentSize().width + 10, strLabel:getContentSize().height))
			suffix:setPosition(node:getContentSize().width - suffix:getContentSize().width / 2 - 6, 14)

			strLabel:addTo(suffix)
			strLabel:setPosition(suffix:getContentSize().width / 2, suffix:getContentSize().height / 2)
		end

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_COIN or kind == ITEM_KIND_EXPLOIT or kind == ITEM_KIND_FORMATION 
		or kind == ITEM_KIND_CROSSSCORE then
		local img = "t_money.jpg"
		if kind == ITEM_KIND_EXPLOIT then
			img = "t_exploit.jpg"
		elseif kind == ITEM_KIND_FORMATION then
			img = "t_formation.jpg"
		elseif kind == ITEM_KIND_CROSSSCORE then
			img = "cross_score.jpg"
		end
		local sprite = display.newSprite("image/item/" .. img):addTo(node)
		sprite:setPosition(sprite:getContentSize().width / 2, sprite:getContentSize().height / 2)
		node.sprite_ = sprite

		local name = ""
		if param.count and param.count > 0 then name = (kind == ITEM_KIND_FORMATION and UiUtil.strNumSimplify(param.count) or param.count) .. "" end  -- 显示数量

		if name ~= "" then  -- 需要显示数量
			strLabel = ui.newTTFLabel({text = name, font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[1], algin = ui.TEXT_ALIGN_CENTER})

			suffix = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(node)
			suffix:setPreferredSize(cc.size(strLabel:getContentSize().width + 10, strLabel:getContentSize().height))
			suffix:setPosition(node:getContentSize().width - suffix:getContentSize().width / 2 - 6, 14)

			strLabel:addTo(suffix)
			strLabel:setPosition(suffix:getContentSize().width / 2, suffix:getContentSize().height / 2)
		end

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_BUILD then
		local view = UiUtil.createItemSprite(ITEM_KIND_BUILD, id):addTo(node)
		view:setAnchorPoint(cc.p(0.5, 0))
		view:setScale(math.min((node:getContentSize().width / view:getContentSize().width + 50), node:getContentSize().height / (view:getContentSize().height + 50)))
		view:setPosition(node:getContentSize().width / 2, 10)
		node.sprite_ = view

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_RESOURCE then
		local view = UiUtil.createItemSprite(kind, id):addTo(node)
		view:setScale(1)
		view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.sprite_ = view
		local name = ""
		if param.count then name = UiUtil.strNumSimplify(param.count) .. "" end  -- 显示数量
		if name ~= "" then
			strLabel = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[1], algin = ui.TEXT_ALIGN_CENTER})
			strLabel:setString(name)

			suffix = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(node)
			suffix:setPreferredSize(cc.size(strLabel:getContentSize().width + 10, strLabel:getContentSize().height))
			suffix:setPosition(node:getContentSize().width - suffix:getContentSize().width / 2 - 6, 14)

			strLabel:addTo(suffix)
			strLabel:setPosition(suffix:getContentSize().width / 2, suffix:getContentSize().height / 2)
		end
		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_PROP or kind == ITEM_KIND_RED_PACKET then  -- 道具
		local propDB = PropMO.queryPropById(id)
		if not propDB then propDB = {color = 1} end

		local name = propDB.asset or "p_build_accel"
		local view = display.newSprite("image/item/" .. name .. ".jpg"):addTo(node)
		view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.sprite_ = view

		local name = ""
		if param.count then name = UiUtil.strNumSimplify(param.count) .. "" end  -- 显示数量
		if param.need then name = name .. "/" .. param.need end --显示合成需要的数量

		if not param.noSuffix and propDB.nameSuffix and propDB.nameSuffix ~= "" then  -- 有后缀名
			if name ~= "" then name = propDB.nameSuffix .. "*" .. name else name = propDB.nameSuffix end
		end

		if name ~= "" then
			strLabel = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[propDB.color], algin = ui.TEXT_ALIGN_CENTER})
			strLabel:setString(name)

			suffix = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(node)
			suffix:setPreferredSize(cc.size(strLabel:getContentSize().width + 10, strLabel:getContentSize().height))
			suffix:setPosition(node:getContentSize().width - suffix:getContentSize().width / 2 - 6, 14)

			strLabel:addTo(suffix)
			strLabel:setPosition(suffix:getContentSize().width / 2, suffix:getContentSize().height / 2)
		end

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_" .. propDB.color .. ".png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame

		if propDB.border then 
			if propDB.border == 1 then  -- 紫色
				armature_add("animation/effect/ui_item_light_purple.pvr.ccz", "animation/effect/ui_item_light_purple.plist", "animation/effect/ui_item_light_purple.xml")
				local armature = armature_create("ui_item_light_purple", view:getContentSize().width / 2 + 2, view:getContentSize().height / 2 + 4):addTo(node, 10)
				armature:getAnimation():playWithIndex(0)
				armature:setScale(0.73)
			elseif propDB.border == 2 then
				armature_add("animation/effect/ui_item_light_orange.pvr.ccz", "animation/effect/ui_item_light_orange.plist", "animation/effect/ui_item_light_orange.xml")
				local armature = armature_create("ui_item_light_orange", view:getContentSize().width / 2 + 6, view:getContentSize().height / 2):addTo(node, 10)
				armature:getAnimation():playWithIndex(0)
				armature:setScale(0.76)
			end
		end
	elseif kind == ITEM_KIND_SKIN then
		local propDB = PropMO.checkPropForSkin(id)

		-- local propDB = nil
		-- if skin then
		-- 	propDB = PropMO.queryPropById(skin.propid)
		-- else
		-- 	propDB = {color = 1, asset = "p_building_default"}
		-- end
		
		if propDB then
			local view = display.newSprite("image/item/" .. propDB.icon .. ".jpg"):addTo(node)
			view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
			node.sprite_ = view

			-- if param.count then
			-- 	strLabel = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[propDB.color], algin = ui.TEXT_ALIGN_CENTER})
			-- 	strLabel:setString(UiUtil.strNumSimplify(param.count))
			-- end

			local fame = display.newSprite(IMAGE_COMMON .. "item_fame_" .. propDB.quality .. ".png"):addTo(node, 6)
			fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
			node.fame_ = fame

			-- if propDB.border then 
			-- 	if propDB.border == 1 then  -- 紫色
			-- 		armature_add("animation/effect/ui_item_light_purple.pvr.ccz", "animation/effect/ui_item_light_purple.plist", "animation/effect/ui_item_light_purple.xml")
			-- 		local armature = armature_create("ui_item_light_purple", view:getContentSize().width / 2 + 2, view:getContentSize().height / 2 + 4):addTo(node, 10)
			-- 		armature:getAnimation():playWithIndex(0)
			-- 		armature:setScale(0.73)
			-- 	elseif propDB.border == 2 then
			-- 		armature_add("animation/effect/ui_item_light_orange.pvr.ccz", "animation/effect/ui_item_light_orange.plist", "animation/effect/ui_item_light_orange.xml")
			-- 		local armature = armature_create("ui_item_light_orange", view:getContentSize().width / 2 + 6, view:getContentSize().height / 2):addTo(node, 10)
			-- 		armature:getAnimation():playWithIndex(0)
			-- 		armature:setScale(0.76)
			-- 	end
			-- end
		end
	elseif kind == ITEM_KIND_EQUIP then
		if id == 0 then  -- 没有装备
			if param.pos and param.pos > 0 then
				local view = nil
				if param.pos == EQUIP_POS_ATK then view = display.newSprite("image/item/e_1.png"):addTo(node)
				elseif param.pos == EQUIP_POS_HP then view = display.newSprite("image/item/e_2.png"):addTo(node)
				elseif param.pos == EQUIP_POS_HIT then view = display.newSprite("image/item/e_3.png"):addTo(node)
				elseif param.pos == EQUIP_POS_DODGE then view = display.newSprite("image/item/e_4.png"):addTo(node)
				elseif param.pos == EQUIP_POS_CRIT then view = display.newSprite("image/item/e_5.png"):addTo(node)
				elseif param.pos == EQUIP_POS_CRIT_DEF then view = display.newSprite("image/item/e_6.png"):addTo(node)
				end

				if view then
					view:setOpacity(102) -- 40%
					view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
					node.sprite_ = view
				end
			end

			local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node, 6)
			fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
			node.fame_ = fame
		else  -- 有装备
			local equipDB = EquipMO.queryEquipById(id)
			if equipDB then
				if equipDB.equipId / 100 < 7 then
					local view = display.newSprite("image/item/" .. equipDB.asset .. ".png"):addTo(node)
					view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
					node.sprite_ = view
				else  -- 经验
					local view = display.newSprite("image/item/" .. equipDB.asset .. ".jpg"):addTo(node)
					view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
					node.sprite_ = view
				end

				if equipDB.border then
					if equipDB.border == 1 then  -- 紫色
						armature_add("animation/effect/ui_item_light_purple.pvr.ccz", "animation/effect/ui_item_light_purple.plist", "animation/effect/ui_item_light_purple.xml")
						local armature = armature_create("ui_item_light_purple", node:getContentSize().width / 2 - 2, node:getContentSize().height / 2 + 2):addTo(node, 10)
						armature:getAnimation():playWithIndex(0)
						armature:setScale(0.73)
					elseif equipDB.border == 2 then
						armature_add("animation/effect/ui_item_light_orange.pvr.ccz", "animation/effect/ui_item_light_orange.plist", "animation/effect/ui_item_light_orange.xml")
						local armature = armature_create("ui_item_light_orange", node:getContentSize().width / 2 + 2, node:getContentSize().height / 2 - 2):addTo(node, 10)
						armature:getAnimation():playWithIndex(0)
						armature:setScale(0.75)
					end
				end

				local fame = display.newSprite(IMAGE_COMMON .. "item_fame_" .. equipDB.quality .. ".png"):addTo(node, 6)
				fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
				node.fame_ = fame

				local equipPos = EquipMO.getPosByEquipId(id)
				local equip = EquipMO.queryEquipById(id)

				param.star =  param.star or 0
				if equipDB.quality >= 5 and equipPos ~= 0 then  --品质大于等于5则显示星级
					local posX = 5
					for index=1,5 do
						local starStr = "estar_bg.png"
						if param.star >= index then
							starStr = "estar.png"
						end
						local star = display.newSprite(IMAGE_COMMON .. starStr):addTo(node)
						star:setAnchorPoint(cc.p(0,0.5))
						star:setPosition(posX,node:getContentSize().height -15)
						posX = star:getPositionX() + star:getContentSize().width
					end
				end

				if equipPos ~= 0 and param.equipLv ~= nil then -- 显示等级值
					local lv = ui.newTTFLabel({text = "LV." .. param.equipLv, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[equip.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(node)
					lv:setAnchorPoint(cc.p(1, 0.5))
					lv:setPosition(node:getContentSize().width - 10, 20)
				elseif equipPos == 0 then
					strLabel = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[equip.quality], algin = ui.TEXT_ALIGN_CENTER})
					strLabel:setString(UiUtil.strNumSimplify(equip.a))

					suffix = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(node)
					suffix:setPreferredSize(cc.size(strLabel:getContentSize().width + 10, strLabel:getContentSize().height))
					suffix:setPosition(node:getContentSize().width - suffix:getContentSize().width / 2 - 6, 14)

					strLabel:addTo(suffix)
					strLabel:setPosition(suffix:getContentSize().width / 2, suffix:getContentSize().height / 2)
				end
			end
		end
	elseif kind == ITEM_KIND_WEAPONRY_ICON or kind == ITEM_KIND_WEAPONRY_PAPER or kind == ITEM_KIND_WEAPONRY_MATERIAL then
		--军备相关
		local md = nil
		local png = ".png"
		if kind == ITEM_KIND_WEAPONRY_ICON then
			png = ".png"
			md = WeaponryMO.queryById(id)
		elseif kind == ITEM_KIND_WEAPONRY_MATERIAL then 
			png = ".jpg"
			md = WeaponryMO.queryMatrialById(id%1000)
		elseif kind == ITEM_KIND_WEAPONRY_PAPER then 
			png = ".jpg"
			md = WeaponryMO.queryPaperById(id)
		end
		local view = display.newSprite("image/item/" .. md.icon .. png ):addTo(node):center()
		local name = nil

		local resData = UserMO.getResourceData(kind, id)
		local name = resData.name
		if param.count and param.count > 1 then name = name .."*" .. UiUtil.strNumSimplify(param.count) end
		
		if param.count and param.count > 0 then
			strLabel = ui.newTTFLabel({text = UiUtil.strNumSimplify(param.count), font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[resData.quality], algin = ui.TEXT_ALIGN_CENTER})
			suffix = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(node)
			suffix:setPreferredSize(cc.size(strLabel:getContentSize().width + 10, strLabel:getContentSize().height))
			suffix:setPosition(node:getContentSize().width - suffix:getContentSize().width / 2 - 6, 14)

			strLabel:addTo(suffix)
			strLabel:setPosition(suffix:getContentSize().width / 2, suffix:getContentSize().height / 2)
		end
		if name then
			-- strLabel = ui.newTTFLabel({text = name, font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[resData.quality], algin = ui.TEXT_ALIGN_CENTER})
			-- suffix = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(node)
			-- suffix:setPreferredSize(cc.size(strLabel:getContentSize().width + 10, strLabel:getContentSize().height))
			-- suffix:setPosition(node:getContentSize().width - suffix:getContentSize().width / 2 - 6, 14)

			-- strLabel:addTo(suffix)
			-- strLabel:setPosition(suffix:getContentSize().width / 2, suffix:getContentSize().height / 2)
		end

		local refitLv = 0 --param.data and param.data.refitLv or 0
		local strRefit = "" .. refitLv
		if refitLv > 0 then strRefit = "+" .. refitLv end
		if kind == ITEM_KIND_WEAPONRY_ICON then
			-- local value = ui.newTTFLabel({text = strRefit, font = G_FONT, size = FONT_SIZE_SMALL, color = cc.c3b(234, 209, 87), align = ui.TEXT_ALIGN_CENTER}):addTo(node)
			-- value:setAnchorPoint(cc.p(0, 0.5))
			-- value:setPosition(8, node:getContentSize().height - 15)
		end
		if refitLv > 0 then  -- 需要显示光效框
			local resName = {"", "ui_item_light_green", "ui_item_light_blue", "ui_item_light_purple", "ui_item_light_orange"}
			local resOffset = {cc.p(0, 0), cc.p(0, 2), cc.p(0, 2), cc.p(0, 2), cc.p(2, -2)}
			local resScale = {0, 0.73, 0.73, 0.73, 0.76}
			armature_add("animation/effect/" .. resName[resData.quality] .. ".pvr.ccz", "animation/effect/" .. resName[resData.quality] .. ".plist", "animation/effect/" .. resName[resData.quality] .. ".xml")
			local armature = armature_create(resName[resData.quality], node:getContentSize().width / 2 + resOffset[resData.quality].x, node:getContentSize().height / 2 + resOffset[resData.quality].y):addTo(node, 7)
			armature:setScale(resScale[resData.quality])
			armature:getAnimation():playWithIndex(0)
		end
		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_" .. md.quality .. ".png"):addTo(node, 6):center()
		node.fame_ = fame
	elseif kind == ITEM_KIND_MEDAL_ICON or kind == ITEM_KIND_MEDAL_CHIP then
		local md = MedalMO.queryById(id)
		local view = display.newSprite("image/item/" .. md.asset .. ".png"):addTo(node):center()
		local name = nil
		if kind == ITEM_KIND_MEDAL_CHIP then
			name = CommonText[163] -- 碎
			if param.count and param.count > 1 then name = name .."*" ..param.count end
			display.newSprite(IMAGE_COMMON.."chip.png"):addTo(node,10):pos(22,80)
		else -- 显示强化等级值
			name = "LV." .. (param.data and param.data.upLv or 0)
		end
		local resData = UserMO.getResourceData(kind, id)
		if name then
			strLabel = ui.newTTFLabel({text = name, font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[resData.quality], algin = ui.TEXT_ALIGN_CENTER})
			suffix = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(node)
			suffix:setPreferredSize(cc.size(strLabel:getContentSize().width + 10, strLabel:getContentSize().height))
			suffix:setPosition(node:getContentSize().width - suffix:getContentSize().width / 2 - 6, 14)

			strLabel:addTo(suffix)
			strLabel:setPosition(suffix:getContentSize().width / 2, suffix:getContentSize().height / 2)
		end

		local refitLv = param.data and param.data.refitLv or 0
		local strRefit = "" .. refitLv
		if refitLv > 0 then strRefit = "+" .. refitLv end
		if kind == ITEM_KIND_MEDAL_ICON then
			local value = ui.newTTFLabel({text = strRefit, font = G_FONT, size = FONT_SIZE_SMALL, color = cc.c3b(234, 209, 87), align = ui.TEXT_ALIGN_CENTER}):addTo(node)
			value:setAnchorPoint(cc.p(0, 0.5))
			value:setPosition(8, node:getContentSize().height - 15)
		end
		if refitLv > 0 then  -- 需要显示光效框
			local resName = {"", "ui_item_light_green", "ui_item_light_blue", "ui_item_light_purple", "ui_item_light_orange"}
			local resOffset = {cc.p(0, 0), cc.p(0, 2), cc.p(0, 2), cc.p(0, 2), cc.p(2, -2)}
			local resScale = {0, 0.73, 0.73, 0.73, 0.76}
			armature_add("animation/effect/" .. resName[resData.quality] .. ".pvr.ccz", "animation/effect/" .. resName[resData.quality] .. ".plist", "animation/effect/" .. resName[resData.quality] .. ".xml")
			local armature = armature_create(resName[resData.quality], node:getContentSize().width / 2 + resOffset[resData.quality].x, node:getContentSize().height / 2 + resOffset[resData.quality].y):addTo(node, 7)
			armature:setScale(resScale[resData.quality])
			armature:getAnimation():playWithIndex(0)
		end
		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_" .. md.quality .. ".png"):addTo(node, 6):center()
		node.fame_ = fame
	elseif kind == ITEM_KIND_PART then  -- 配件
		if id == 0 then  -- 没有装备配件
			if not param.openLv then param.openLv = 0 end
			if param.openLv > UserMO.level_ then -- 还没有开放
				local view = display.newSprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(node)  -- 锁
				view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
				node.sprite_ = view

				local label = ui.newTTFLabel({text = "LV." .. param.openLv, font = G_FONT, size = FONT_SIZE_TINY, x = node:getContentSize().width / 2, y = 16, align = ui.TEXT_ALIGN_CENTER}):addTo(node)

			elseif param.pos and param.pos > 0 then
				local resIndex = param.pos
				if resIndex == 7 then
					resIndex = resIndex + 1
				elseif resIndex == 8 then
					resIndex = resIndex - 1
				end
				if resIndex > 8 then
					resIndex = resIndex + 1
				end

				local view = display.newSprite("image/item/part_" .. resIndex .. "_1.png"):addTo(node)

				if view then
					view:setOpacity(102) -- 40%
					view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
					node.sprite_ = view
				end
			end

			local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node, 6)
			fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
			node.fame_ = fame
		else
			local part = PartMO.queryPartById(id)
			
			local view = display.newSprite("image/item/" .. part.asset .. ".png"):addTo(node)
			view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
			node.sprite_ = view

			local resData = UserMO.getResourceData(kind, id)

			if param.upLv ~= nil then -- 显示强化等级值
				strLabel = ui.newTTFLabel({text = "LV." .. param.upLv, font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[resData.quality], algin = ui.TEXT_ALIGN_CENTER})

				suffix = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(node)
				suffix:setPreferredSize(cc.size(strLabel:getContentSize().width + 10, strLabel:getContentSize().height))
				suffix:setPosition(node:getContentSize().width - suffix:getContentSize().width / 2 - 6, 14)

				strLabel:addTo(suffix)
				strLabel:setPosition(suffix:getContentSize().width / 2, suffix:getContentSize().height / 2)
			end

			if param.refitLv ~= nil then  -- 显示改装等级值
				local strRefit = "" .. param.refitLv
				if param.refitLv > 0 then strRefit = "+" .. param.refitLv end

				local value = ui.newTTFLabel({text = strRefit, font = G_FONT, size = FONT_SIZE_SMALL, color = cc.c3b(234, 209, 87), align = ui.TEXT_ALIGN_CENTER}):addTo(node)
				value:setAnchorPoint(cc.p(0, 0.5))
				value:setPosition(8, node:getContentSize().height - 15)

				if param.refitLv > 0 then  -- 需要显示光效框
					local resName = {"", "ui_item_light_green", "ui_item_light_blue", "ui_item_light_purple", "ui_item_light_orange"}
					local resOffset = {cc.p(0, 0), cc.p(0, 2), cc.p(0, 2), cc.p(0, 2), cc.p(2, -2)}
					local resScale = {0, 0.73, 0.73, 0.73, 0.76}
					armature_add("animation/effect/" .. resName[resData.quality] .. ".pvr.ccz", "animation/effect/" .. resName[resData.quality] .. ".plist", "animation/effect/" .. resName[resData.quality] .. ".xml")

					local armature = armature_create(resName[resData.quality], node:getContentSize().width / 2 + resOffset[resData.quality].x, node:getContentSize().height / 2 + resOffset[resData.quality].y):addTo(node, 7)
					armature:setScale(resScale[resData.quality])
					armature:getAnimation():playWithIndex(0)
				end
			end

			local fame = display.newSprite(IMAGE_COMMON .. "item_fame_" .. resData.quality .. ".png"):addTo(node, 6)
			fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
			node.fame_ = fame
		end
	elseif kind == ITEM_KIND_CHIP then
		if id ~= 0 then
			local part = PartMO.queryPartById(id)
			
			local str = ""
			local view = nil
			-- 万能碎片
			if id == PART_ID_ALL_PIECE then 
				view = display.newSprite("image/item/part_all_piece.jpg"):addTo(node)
				if param.count and param.count > 0 then str = CommonText[163] .."*" .. param.count end
			else
				str = CommonText[163] -- 碎
				if param.count and param.count > 1 then str = str .. "*" end
				view = display.newSprite("image/item/" .. part.asset .. ".png"):addTo(node)

				if param.count and param.count > 1 then str = str .. param.count end
			end
			view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
			node.sprite_ = view


			local resData = UserMO.getResourceData(kind, id)

			if str ~= "" then
				strLabel = ui.newTTFLabel({text = str, font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[resData.quality], algin = ui.TEXT_ALIGN_CENTER})

				suffix = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(node)
				suffix:setPreferredSize(cc.size(strLabel:getContentSize().width + 10, strLabel:getContentSize().height))
				suffix:setPosition(node:getContentSize().width - suffix:getContentSize().width / 2 - 6, 14)

				strLabel:addTo(suffix)
				strLabel:setPosition(suffix:getContentSize().width / 2, suffix:getContentSize().height / 2)
			end
			local fame = display.newSprite(IMAGE_COMMON .. "item_fame_" .. resData.quality .. ".png"):addTo(node, 6)
			fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
			node.fame_ = fame
			display.newSprite(IMAGE_COMMON.."chip.png"):addTo(node,10):pos(22,80)
		end
	elseif kind == ITEM_KIND_MATERIAL then  -- 配件材料
		local resData = UserMO.getResourceData(kind, id)

		local view = display.newSprite("image/item/material_" .. id .. ".jpg"):addTo(node)
		view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.sprite_ = view

		if param.count and param.count > 0 then  -- 显示数量
			local resData = UserMO.getResourceData(kind, id)

			strLabel = ui.newTTFLabel({text = UiUtil.strNumSimplify(param.count), font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[resData.quality], algin = ui.TEXT_ALIGN_CENTER})

			suffix = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(node)
			suffix:setPreferredSize(cc.size(strLabel:getContentSize().width + 10, strLabel:getContentSize().height))
			suffix:setPosition(node:getContentSize().width - suffix:getContentSize().width / 2 - 6, 14)

			strLabel:addTo(suffix)
			strLabel:setPosition(suffix:getContentSize().width / 2, suffix:getContentSize().height / 2)
		end

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_" .. resData.quality .. ".png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_SCIENCE then
		local scienceDB = ScienceMO.queryScience(id)
		-- gdump(id,"id=============================")
		local name = scienceDB.asset
		if not name then print("不存在的科技图片:"..id) end
		local view = display.newSprite("image/item/" .. name .. ".jpg"):addTo(node)
		view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.sprite_ = view

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_HERO then
		local view = UiUtil.createItemSprite(kind, id):addTo(bg)
		view:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)
		node.sprite_ = view

		if id > 0 then
			local hero = HeroMO.queryHero(id)
			local starBg = display.newSprite(IMAGE_COMMON .. "hero_star_bg.png", bg:getContentSize().width / 2, bg:getContentSize().height):addTo(bg)
			local star = display.newSprite(IMAGE_COMMON .. "hero_star_" .. hero.star .. ".png", starBg:getContentSize().width / 2, starBg:getContentSize().height / 2):addTo(starBg)
			local nameBg = display.newSprite(IMAGE_COMMON .. "info_bg_32.png", bg:getContentSize().width / 2, 33):addTo(bg)
			local name = ui.newTTFLabel({text = hero.heroName, font = G_FONT, size = FONT_SIZE_SMALL, x = nameBg:getContentSize().width / 2, y = nameBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(nameBg)
			node.heroName_ = name
		end
	elseif kind == ITEM_KIND_AWAKE_HERO then
		local view = UiUtil.createItemSprite(kind, id):addTo(bg)
		view:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)
		node.sprite_ = view
		if HeroMO.queryHero(id).awakenSkillArr then
			if id > 0 then
				local hero = HeroMO.queryHero(id)
				local starBg = display.newSprite(IMAGE_COMMON .. "hero_awake_star_bg.png", bg:getContentSize().width / 2, bg:getContentSize().height):addTo(bg)
				local star = display.newSprite(IMAGE_COMMON .. "hero_star_" .. hero.star .. ".png", starBg:getContentSize().width / 2, starBg:getContentSize().height / 2):addTo(starBg)
				local nameBg = display.newSprite(IMAGE_COMMON .. "info_bg_32.png", bg:getContentSize().width / 2, 33):addTo(bg)
				local name = ui.newTTFLabel({text = hero.heroName, font = G_FONT, size = FONT_SIZE_SMALL, x = nameBg:getContentSize().width / 2, y = nameBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(nameBg)
				node.heroName_ = name
			end
		else
			if id > 0 then
				local hero = HeroMO.queryHero(id)
				local starBg = display.newSprite(IMAGE_COMMON .. "hero_star_bg.png", bg:getContentSize().width / 2, bg:getContentSize().height):addTo(bg)
				local star = display.newSprite(IMAGE_COMMON .. "hero_star_" .. hero.star .. ".png", starBg:getContentSize().width / 2, starBg:getContentSize().height / 2):addTo(starBg)
				local nameBg = display.newSprite(IMAGE_COMMON .. "info_bg_32.png", bg:getContentSize().width / 2, 33):addTo(bg)
				local name = ui.newTTFLabel({text = hero.heroName, font = G_FONT, size = FONT_SIZE_SMALL, x = nameBg:getContentSize().width / 2, y = nameBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(nameBg)
				node.heroName_ = name
			end
		end
	elseif kind == ITEM_KIND_HUANGBAO then
		local view = display.newSprite("image/item/item_huangbao.jpg"):addTo(bg)
		view:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)
		node.sprite_ = view
		if param and param.count then
			local countLabel = ui.newTTFLabel({text = string.format("%d", param.count), font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[1], algin = ui.TEXT_ALIGN_CENTER}):addTo(node)
			countLabel:setPosition(node:getContentSize().width - countLabel:getContentSize().width/2 - 5,countLabel:getContentSize().height/2 + 5)
		end
		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_PORTRAIT then
		if id >= 100 then
			local q, p = UserBO.parsePortrait(id)  -- 有头像和挂件
			id = q
		end
		local view = UiUtil.createItemSprite(kind, id):addTo(node)
		view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.sprite_ = view

		if param.pendant and param.pendant > 0 then -- 有挂件
			-- local view = display.newSprite(IMAGE_COMMON .. "pendant/p_" .. param.pendant .. ".png"):addTo(node, 2)
			local view = display.newSprite(IMAGE_COMMON .. "pendant/" .. PendantMO.queryPendantById(param.pendant).asset .. ".png"):addTo(node, 20)
			view:setAnchorPoint(cc.p(0, 0.5))
			view:setPosition(5, node:getContentSize().height - 30)
			if param.pendant == 17 or param.pendant == 18 or param.pendant == 19 then
				view:align(display.CENTER,node:width()/2,node:height()/2+10)
			elseif param.pendant == 20 or param.pendant == 21 or param.pendant == 22 then
				view:align(display.CENTER,node:width()/2,node:getContentSize().height - 20)
			elseif param.pendant == 26 then
				view:y(view:y() - 20)
			elseif param.pendant == 46 then
				view:align(display.CENTER,node:width()/2,node:height()/2)
			end
			node.pendant_ = view
		end

		if param.vip then -- 传了VIP表示需要根据VIP的值添加动画
			if param.vip >= 5 and param.vip <= 8 then
				armature_add("animation/effect/ui_item_light_purple.pvr.ccz", "animation/effect/ui_item_light_purple.plist", "animation/effect/ui_item_light_purple.xml")
				local armature = armature_create("ui_item_light_purple", view:getContentSize().width / 2, view:getContentSize().height / 2):addTo(view,10)
				armature:setScale(1.15)
				armature:getAnimation():playWithIndex(0)
				if id >= 32 and id <= 34 then armature:setPosition(0,0) end -- 动画头像
				if id >= 45 and id <= 47 then armature:setPosition(0,0) end -- 动画头像
			elseif param.vip >= 9 then
				armature_add("animation/effect/ui_item_light_orange.pvr.ccz", "animation/effect/ui_item_light_orange.plist", "animation/effect/ui_item_light_orange.xml")
				local armature = armature_create("ui_item_light_orange", view:getContentSize().width / 2, view:getContentSize().height / 2):addTo(view,10)
				armature:setScale(1.15)
				armature:getAnimation():playWithIndex(0)
				if id >= 32 and id <= 34 then armature:setPosition(0,0) end -- 动画头像
				if id >= 45 and id <= 47 then armature:setPosition(0,0) end -- 动画头像
			end
		end
	elseif kind == ITEM_KIND_COMMAND then -- 统率
		local propDB = PropMO.queryPropById(PROP_ID_COMMAND_BOOK)
		if not propDB then propDB = {} end
		local name = propDB.asset or "p_build_accel"
		
		local view = display.newSprite("image/item/" .. name .. ".jpg"):addTo(node)
		view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.sprite_ = view

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_" .. propDB.color .. ".png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_PROSPEROUS then  -- 繁荣度
		local view = display.newSprite("image/item/prosperous.jpg"):addTo(node)
		view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.sprite_ = view

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_FAME then -- 声望
		local view = display.newSprite("image/item/fame.jpg"):addTo(node)
		view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.sprite_ = view

		local name = ""
		if param.count then name = param.count .. "" end  -- 显示数量

		if name ~= "" then  -- 需要显示数量
			strLabel = ui.newTTFLabel({text = name, font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[1], algin = ui.TEXT_ALIGN_CENTER})

			suffix = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(node)
			suffix:setPreferredSize(cc.size(strLabel:getContentSize().width + 10, strLabel:getContentSize().height))
			suffix:setPosition(node:getContentSize().width - suffix:getContentSize().width / 2 - 6, 14)

			strLabel:addTo(suffix)
			strLabel:setPosition(suffix:getContentSize().width / 2, suffix:getContentSize().height / 2)
		end

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_MEDAL then -- 授勋
		local view = display.newSprite("image/item/medal_" .. id .. ".jpg"):addTo(node)
		view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.sprite_ = view

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_RANK then
		local rank = UserMO.queryRankById(id)
		if rank then
			local view = display.newSprite("image/item/" .. rank.asset .. ".jpg"):addTo(node)
			view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
			node.sprite_ = view

			local fame = display.newSprite(IMAGE_COMMON .. "item_fame_" .. rank.quality .. ".png"):addTo(node, 6)
			fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
			node.fame_ = fame
		end
	elseif kind == ITEM_KIND_SKILL then -- 技能
		local skillDB = SkillMO.querySkillById(id)

		local view = display.newSprite("image/item/" .. skillDB.asset .. ".jpg"):addTo(node)
		view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.sprite_ = view

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_TANK then  -- 坦克
		local tank = TankMO.queryTankById(id)

		local view = UiUtil.createItemSprite(kind, id):addTo(node)
		view:setScale(0.6)
		view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.sprite_ = view

		local name = ""
		if param.count then name = param.count .. "" end  -- 显示数量

		if name ~= "" then  -- 需要显示数量
			strLabel = ui.newTTFLabel({text = name, font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[tank.grade], algin = ui.TEXT_ALIGN_CENTER})

			suffix = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(node)
			suffix:setPreferredSize(cc.size(strLabel:getContentSize().width + 10, strLabel:getContentSize().height))
			suffix:setPosition(node:getContentSize().width - suffix:getContentSize().width / 2 - 6, 14)

			strLabel:addTo(suffix)
			strLabel:setPosition(suffix:getContentSize().width / 2, suffix:getContentSize().height / 2)
		end

		if tank.border then 
			if tank.border == 1 then  -- 紫色
				armature_add("animation/effect/ui_item_light_purple.pvr.ccz", "animation/effect/ui_item_light_purple.plist", "animation/effect/ui_item_light_purple.xml")
				local armature = armature_create("ui_item_light_purple", node:getContentSize().width / 2, node:getContentSize().height / 2):addTo(node, 10)
				armature:getAnimation():playWithIndex(0)
				armature:setScale(0.73)
				node.armature_ = armature
			elseif tank.border == 2 then
				armature_add("animation/effect/ui_item_light_orange.pvr.ccz", "animation/effect/ui_item_light_orange.plist", "animation/effect/ui_item_light_orange.xml")
				local armature = armature_create("ui_item_light_orange", node:getContentSize().width / 2 + 2, node:getContentSize().height / 2 - 2):addTo(node, 10)
				armature:getAnimation():playWithIndex(0)
				armature:setScale(0.76)
				node.armature_ = armature
			end
		end

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_" .. tank.grade .. ".png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_SCORE then -- 积分
		-- local resData =  UserMO.getResourceData(kind, id)
		local view = display.newSprite("image/item/item_arena_score.png"):addTo(node)
		view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.sprite_ = view

		local name = ""
		if param.count then name = param.count .. "" end  -- 显示数量

		if name ~= "" then  -- 需要显示数量
			strLabel = ui.newTTFLabel({text = name, font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[1], algin = ui.TEXT_ALIGN_CENTER})

			suffix = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(node)
			suffix:setPreferredSize(cc.size(strLabel:getContentSize().width + 10, strLabel:getContentSize().height))
			suffix:setPosition(node:getContentSize().width - suffix:getContentSize().width / 2 - 6, 14)

			strLabel:addTo(suffix)
			strLabel:setPosition(suffix:getContentSize().width / 2, suffix:getContentSize().height / 2)
		end

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_ATTRIBUTE then -- 仅显示属性
		local name = param.name or "maxHp"
		if param.name == "atkMode" then name = param.name .. "_" .. id end
		
		local view = display.newSprite("image/item/attr_" .. name .. ".jpg"):addTo(node)
		view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.sprite_ = view

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame

		node:setScale(0.4)
	elseif kind == ITEM_KIND_EFFECT then -- 增益
		local effect = EffectMO.queryEffectById(id)

		local view = display.newSprite("image/item/" .. effect.asset .. ".jpg"):addTo(node)
		view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.sprite_ = view

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_PARTY_LIVELY_TASK then --军团活跃任务
		local partyLivelyDB = PartyMO.queryPartyLivelyTask(id)
		local name = partyLivelyDB.asset
		local view = display.newSprite("image/item/" .. name .. ".jpg"):addTo(node)
		view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.sprite_ = view

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_TASK then --任务
		local taskDB = TaskMO.queryTask(id)
		local name = taskDB.asset
		local view = display.newSprite("image/item/" .. name .. ".jpg"):addTo(node)
		-- local view = display.newSprite("image/item/at_1.jpg"):addTo(node)
		view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.sprite_ = view

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_FIGHT_VALUE then -- 战斗力
		local view = nil
		if id == FIGHT_ID_COMMAND then view = display.newSprite("image/item/p_command_book.jpg")
		elseif id == FIGHT_ID_SKILL then view = display.newSprite("image/item/p_skill_book.jpg")
		elseif id == FIGHT_ID_EQUIP_QUALITY then view = display.newSprite("image/item/e_1.png")
		elseif id == FIGHT_ID_EQUIP_LEVEL then view = display.newSprite("image/item/e_2.png")
		elseif id == FIGHT_ID_PART_QUALITY then view = display.newSprite("image/item/part_1_1.png")
		elseif id == FIGHT_ID_PART_UP then view = display.newSprite("image/item/part_2_1.png")
		elseif id == FIGHT_ID_PART_REFIT then view = display.newSprite("image/item/part_3_1.png")
		elseif id == FIGHT_ID_SCIENCE_LEVEL then view = display.newSprite("image/item/p_build_accel.jpg")
		elseif id == FIGHT_ID_PARTY then view = display.newSprite("image/item/medal_4.jpg")
		elseif id == FIGHT_ID_ARMY then view = display.newSprite("image/item/r_arti_fire.jpg")
		elseif id == FIGHT_ID_FULL then view = display.newSprite("image/item/r_arti_fire.jpg")
		elseif id == FIGHT_ID_PROPS then view = display.newSprite("image/item/prosperous.jpg")
		end

		if view then
			view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
			view:addTo(node)
			node.sprite_ = view
		end

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_WORLD_RES then  -- 世界资源
	elseif kind == ITEM_KIND_ARMY_TASK then  -- 部队任务
		if id == ARMY_STATE_WAITTING then id = ARMY_STATE_GARRISON
		elseif id == ARMY_STATE_AID_MARCH then id = ARMY_STATE_MARCH end

		local view = nil
		if id == ARMY_STATE_FORTRESS then
			view = display.newSprite("image/item/t_garrison.jpg")
		elseif id >= ARMY_AIRSHIP_BEGAIN then
			view = display.newSprite("image/item/t_player.jpg")
		else
			view = display.newSprite("image/item/at_" .. id .. ".jpg")
		end
		view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		view:addTo(node)
		node.sprite_ = view

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_MILITARY then --军工科技道具
		local propDB = OrdnanceMO.queryMaterialById(id)
		if not propDB then propDB = {color = propDB.quality} end
		local name = propDB.name or "error_id"..id
		local view = display.newSprite("image/item/military_" .. id .. ".jpg"):addTo(node)
		view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.sprite_ = view
		local name = ""
		if param.count and param.count > 0 then name = UiUtil.strNumSimplify(param.count) .. "" end  -- 显示数量
		if name ~= "" then
			strLabel = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[propDB.color], algin = ui.TEXT_ALIGN_CENTER})
			strLabel:setString(name)

			suffix = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(node)
			suffix:setPreferredSize(cc.size(strLabel:getContentSize().width + 10, strLabel:getContentSize().height))
			suffix:setPosition(node:getContentSize().width - suffix:getContentSize().width / 2 - 6, 14)

			strLabel:addTo(suffix)
			strLabel:setPosition(suffix:getContentSize().width / 2, suffix:getContentSize().height / 2)
		end

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_" .. propDB.quality .. ".png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_MEDAL_MATERIAL then --勋章材料
		local propDB = MedalMO.queryPropById(id)
		local name = propDB.name or "error_id"..id
		local view = display.newSprite("image/item/"..propDB.icon .. ".jpg"):addTo(node)
		view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.sprite_ = view
		local name = ""
		if param.count and param.count > 0 then name = UiUtil.strNumSimplify(param.count) .. "" end  -- 显示数量
		if name ~= "" then
			strLabel = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[propDB.color], algin = ui.TEXT_ALIGN_CENTER})
			strLabel:setString(name)

			suffix = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(node)
			suffix:setPreferredSize(cc.size(strLabel:getContentSize().width + 10, strLabel:getContentSize().height))
			suffix:setPosition(node:getContentSize().width - suffix:getContentSize().width / 2 - 6, 14)

			strLabel:addTo(suffix)
			strLabel:setPosition(suffix:getContentSize().width / 2, suffix:getContentSize().height / 2)
		end

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_" .. propDB.quality .. ".png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_CHAR then --字
		local propDB = PropMO.queryActPropById(id)
		local name = propDB.name or "error_id"..id
		local pic = propDB.icon ~= "" and propDB.icon or "char_"..id
		local view = display.newSprite("image/item/" .. pic .. ".jpg"):addTo(node)
		view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.sprite_ = view
		local name = ""
		if param.count and param.count >= 0 then name = UiUtil.strNumSimplify(param.count) .. "" end  -- 显示数量
		if name ~= "" then
			strLabel = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[propDB.color], algin = ui.TEXT_ALIGN_CENTER})
			strLabel:setString(name)

			suffix = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(node)
			suffix:setPreferredSize(cc.size(strLabel:getContentSize().width + 10, strLabel:getContentSize().height))
			suffix:setPosition(node:getContentSize().width - suffix:getContentSize().width / 2 - 6, 14)

			strLabel:addTo(suffix)
			strLabel:setPosition(suffix:getContentSize().width / 2, suffix:getContentSize().height / 2)
		end

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_" .. propDB.quality .. ".png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_ENERGY_SPAR then ---能晶
		if id ~= 0 then
			local sparDB = EnergySparMO.queryEnergySparById(id)
			
			local view = display.newSprite("image/energy/" .. sparDB.icon .. ".jpg"):addTo(node)
			view:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
			node.sprite_ = view

			local lvLabel = ui.newTTFLabel({text = RomeNum[sparDB.level], font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[12], algin = ui.TEXT_ALIGN_CENTER}):addTo(node)
			lvLabel:setPosition(node:getContentSize().width - lvLabel:getContentSize().width/2 - 10,node:getContentSize().height - lvLabel:getContentSize().height/2 - 10)
			if param and param.count then
				local countLabel = ui.newTTFLabel({text = string.format("%d", param.count), font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[sparDB.quite], algin = ui.TEXT_ALIGN_CENTER}):addTo(node)
				countLabel:setPosition(node:getContentSize().width - countLabel:getContentSize().width/2 - 5,countLabel:getContentSize().height/2 + 5)
			end
			local fame = display.newSprite(IMAGE_COMMON .. "item_fame_" .. sparDB.quite .. ".png"):addTo(node, 6)
			fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
			node.fame_ = fame	
		end		
	elseif kind == ITEM_KIND_POWER then ---能量
		local bg = display.newSprite(IMAGE_COMMON .. "t_power.jpg"):addTo(node)
		bg:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)
		if param and param.count then
			local countLabel = ui.newTTFLabel({text = string.format("%d", param.count), font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[1], algin = ui.TEXT_ALIGN_CENTER}):addTo(node)
			countLabel:setPosition(node:getContentSize().width - countLabel:getContentSize().width/2 - 5,countLabel:getContentSize().height/2 + 5)
		end
		node.sprite_ = bg
		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame	
	elseif kind == ITEM_KIND_WEAPONRY_EMPLOY then 				--军备技工
		local md =WeaponryMO.getEmployById(id)
		local sprite = display.newSprite(IMAGE_COMMON .. "item_fame_4.png"):addTo(node,6)
		sprite:setPosition(sprite:getContentSize().width / 2, sprite:getContentSize().height / 2)
		local fame = display.newSprite("image/item/" .. md.icon .. ".jpg"):addTo(node)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame	
	elseif kind == ITEM_KIND_MILITARY_EXPLOIT then 				--军功
		local sprite = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node,6)
		sprite:setPosition(sprite:getContentSize().width / 2, sprite:getContentSize().height / 2)
		local fame = display.newSprite(IMAGE_COMMON .. "t_militaryranks.png"):addTo(node)
		fame:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_LABORATORY_RES then
		local sprite = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node,6)
		sprite:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		local fame_ = UiUtil.createItemSprite(kind, id):addTo(node)
		fame_:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.fame_ = fame_

		local name = ""
		if param.count and param.count > 0 then name = UiUtil.strNumSimplify(param.count) .. "" end  -- 显示数量
		if name ~= "" then
			local strLabel = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[1], algin = ui.TEXT_ALIGN_CENTER})
			strLabel:setString(name)

			local suffix = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(node)
			suffix:setPreferredSize(cc.size(strLabel:getContentSize().width + 10, strLabel:getContentSize().height))
			suffix:setPosition(node:getContentSize().width - suffix:getContentSize().width / 2 - 6, 14)

			strLabel:addTo(suffix)
			strLabel:setPosition(suffix:getContentSize().width / 2, suffix:getContentSize().height / 2)
		end

	elseif kind == ITEM_KIND_WEAPONRY_SKILL then
		--外框
		local sprite = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node,6)
		sprite:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		local msd = WeaponryMO.queryChangeSkillById(id)
		local fame = nil
		if msd then
			fame = display.newSprite("image/item/" .. msd.icon .. ".jpg"):addTo(node)
		else
			local strpng = "unactive.png"
			if param.super and param.super == 4 then strpng = "unactive2.png" end
			fame = display.newSprite(IMAGE_COMMON .. strpng):addTo(node)
		end
		fame:setAnchorPoint(cc.p(0.5,0.5))
		fame:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == 	ITEM_KIND_LEVEL then -- 我的等级
		local sprite = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node,6)
		sprite:setPosition(sprite:getContentSize().width / 2, sprite:getContentSize().height / 2)
		local fame = display.newSprite(IMAGE_COMMON .. "t_lv.jpg"):addTo(node)
		fame:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_WEAPONRY_RANDOM then				--军备随机材料
		local sprite = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(node,6)
		sprite:setPosition(sprite:getContentSize().width / 2, sprite:getContentSize().height / 2)
		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_9.jpg"):addTo(node)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame	
	elseif kind == ITEM_KIND_HUNTER_COIN then
		local sprite = display.newSprite("image/item/blue_stone.jpg"):addTo(node)
		sprite:setPosition(sprite:getContentSize().width / 2, sprite:getContentSize().height / 2)
		node.sprite_ = sprite
		
		if param.count and param.count > 0 then  -- 显示数量
			strLabel = ui.newTTFLabel({text = UiUtil.strNumSimplify(param.count), font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[1], algin = ui.TEXT_ALIGN_CENTER})

			suffix = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(node)
			suffix:setPreferredSize(cc.size(strLabel:getContentSize().width + 10, strLabel:getContentSize().height))
			suffix:setPosition(node:getContentSize().width - suffix:getContentSize().width / 2 - 6, 14)

			strLabel:addTo(suffix)
			strLabel:setPosition(suffix:getContentSize().width / 2, suffix:getContentSize().height / 2)
		end

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_5.png"):addTo(node, 6)
		fame:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
		node.fame_ = fame
	elseif kind == ITEM_KIND_TACTIC or kind == ITEM_KIND_TACTIC_PIECE then --战术。战术碎片。
		local tactics = TacticsMO.queryTacticById(id)
		local view = display.newSprite("image/tactics/"..tactics.asset..".png"):addTo(node):center()
		node.sprite_ = view

		local suffix = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(node)
		suffix:setPreferredSize(cc.size(view:width(), 30))
		suffix:setPosition(node:width() / 2, suffix:height() / 2 - 10)

		local tankIcon = display.newSprite("image/tactics/tank_type_"..tactics.tanktype..".png"):addTo(node,99):center()
		tankIcon:setPosition(12,node:height() - 12)
		tankIcon:setScale(1.2)

		local tacticIcon = display.newSprite("image/tactics/tactics_attr_"..tactics.tacticstype..".png"):addTo(node,99):center()
		tacticIcon:setScale(0.4)
		tacticIcon:setPosition(12,12)

		if id == TACTICS_ID_ALL_PIECE then --特殊处理万能碎片
			tankIcon:setVisible(false)
			tacticIcon:setVisible(false)
		end

		param.tacticLv = param.tacticLv or 0
		local lv = ui.newTTFLabel({text = "LV." .. param.tacticLv, font = G_FONT, size = 16, align = ui.TEXT_ALIGN_CENTER}):addTo(node)
		lv:setAnchorPoint(cc.p(1, 0.5))
		lv:setPosition(node:getContentSize().width, 9)

		if kind == ITEM_KIND_TACTIC_PIECE then --如果是碎片
			lv:setString("")
			local piece = display.newSprite("image/tactics/tactic_piece.png"):addTo(node,9):center()
			if param.count and param.count >= 1 then
				lv:setString(param.count)
			end
			if id == TACTICS_ID_ALL_PIECE then --特殊处理万能碎片
				piece:setVisible(false)
			end
		end

		local resName = {"", "ui_item_light_green", "ui_item_light_blue", "ui_item_light_purple", "ui_item_light_orange"}
		local resOffset = {cc.p(0, 0), cc.p(0, 2), cc.p(0, 2), cc.p(0, 2), cc.p(2, -2)}
		local resScale = {0, 0.73, 0.73, 0.73, 0.76}
		if tactics.quality >= 3 then
			armature_add("animation/effect/" .. resName[tactics.quality + 1] .. ".pvr.ccz", "animation/effect/" .. resName[tactics.quality + 1] .. ".plist", "animation/effect/" .. resName[tactics.quality + 1] .. ".xml")
			local armature = armature_create(resName[tactics.quality + 1], node:getContentSize().width / 2 + resOffset[tactics.quality + 1].x, node:getContentSize().height / 2 + resOffset[tactics.quality + 1].y):addTo(node, 7)
			armature:setScale(resScale[tactics.quality + 1])
			armature:getAnimation():playWithIndex(0)
		end

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_" .. tactics.quality + 1 .. ".png"):addTo(node, 6):center()
		node.fame_ = fame
	elseif kind == ITEM_KIND_TACTIC_MATERIAL then --战术材料
		local resData = UserMO.getResourceData(kind, id)
		local view = display.newSprite("image/tactics/"..resData.icon..".png"):addTo(node):center()
		node.sprite_ = view

		if param.count and param.count > 0 then  -- 显示数量
			local resData = UserMO.getResourceData(kind, id)

			strLabel = ui.newTTFLabel({text = UiUtil.strNumSimplify(param.count), font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[resData.quality], algin = ui.TEXT_ALIGN_CENTER})

			suffix = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(node)
			suffix:setPreferredSize(cc.size(strLabel:getContentSize().width + 10, strLabel:getContentSize().height))
			suffix:setPosition(node:getContentSize().width - suffix:getContentSize().width / 2 - 6, 14)

			strLabel:addTo(suffix)
			strLabel:setPosition(suffix:getContentSize().width / 2, suffix:getContentSize().height / 2)
		end

		local fame = display.newSprite(IMAGE_COMMON .. "item_fame_" .. resData.quality .. ".png"):addTo(node, 6):center()
		node.fame_ = fame
	end
	node.enough = true
	node.suffix_ = suffix
	if param.own and strLabel then
		local c = COLOR[2]
		if param.count and param.count > param.own then
			c = COLOR[6]
			node.enough = false
		end
		local t = UiUtil.label("/" ..UiUtil.strNumSimplify(param.own),FONT_SIZE_LIMIT,c)
			:addTo(strLabel):align(display.LEFT_CENTER,strLabel:width(),strLabel:height()/2)
		if suffix then
			suffix:setPreferredSize(cc.size(strLabel:width() + t:width()+8, strLabel:height()))
			suffix:align(display.RIGHT_CENTER,node:width()-6,14)
		end
	end
	return node
end

--技能描述提示框 
function UiUtil.createSkillView(kind,id,param)
	param = param or {}
	local node = display.newNode()
	node.kind = kind
	node.id = id
	node.param = param

	local bg = nil

	if kind == 1 then
		-- if id == 2 then
		-- 	bg = display.newScale9Sprite(IMAGE_COMMON .. "item_bg_0.png"):addTo(node)
		-- else
		-- 	bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_47.png"):addTo(node)
		-- end
		bg = display.newScale9Sprite(IMAGE_COMMON .. "item_bg_6.png"):addTo(node)
		bg:setPreferredSize(cc.size(400,130))
		bg:setAnchorPoint(cc.p(0,0.5))
		local skillName = ui.newTTFLabel({text = param.name, font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = 20, y = bg:getContentSize().height - 20, align = ui.TEXT_ALIGN_LEFT}):addTo(bg)

		local skillDesc = ui.newTTFLabel({text = param.desc, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 20, y = skillName:getPositionY() - 60, align = ui.TEXT_ALIGN_LEFT,dimensions = cc.size(bg:getContentSize().width - 30, bg:getContentSize().height - 30)}):addTo(bg)

	end

	return node
end


-- isInScroll: 是放在TableView或者PageView中
function UiUtil.createItemDetailButton(itemView, parent, isInScroll, tagCallback)
	if not isInScroll then
		parent = parent or itemView
	end

	local function showDetail(tag, sender)
		if tagCallback then
			tagCallback(sender.itemView)
		else
			if sender.kind == ITEM_KIND_TANK then
				require("app.dialog.DetailTankDialog").new(sender.id):push()
			elseif sender.kind == ITEM_KIND_EXP or sender.kind == ITEM_KIND_LEVEL then
			else
				require("app.dialog.DetailItemDialog").new(sender.kind, sender.id, sender.param):push()
			end
		end
	end

	local normal = display.newNode()
	normal:setAnchorPoint(cc.p(0.5, 0.5))
	-- normal:setContentSize(itemView:getBoundingBox().size)
	normal:setContentSize(itemView:getContentSize().width*itemView:getScaleX(),itemView:getContentSize().height*itemView:getScaleY())


	local button = nil
	if isInScroll then
		button = CellTouchButton.new(normal, nil, nil, nil, showDetail)
		parent:addButton(button, itemView:getPositionX(), itemView:getPositionY())
	else
		button = TouchButton.new(normal, nil, nil, nil, showDetail):addTo(parent)
		button:setPosition(itemView:getContentSize().width / 2, itemView:getContentSize().width / 2)
	end

	button.itemView = itemView
	button.kind = itemView.kind
	button.id = itemView.id
	button.param = itemView.param

	return button
end

function UiUtil.showTip(parent, tipNum, x, y, order, tag)
	x = x or parent:getContentSize().width - 20
	y = y or parent:getContentSize().height - 20
	order = order or 2
	tag = tag or "tip__"

	if parent[tag] then
		parent[tag]:removeSelf()
		parent[tag] = nil
	end

	local tip = display.newSprite(IMAGE_COMMON .. "icon_red_point.png"):addTo(parent, order)
	tip:setPosition(x, y)
	parent[tag] = tip

	if tipNum then
		ui.newTTFLabel({text = tipNum, font = G_FONT, size = FONT_SIZE_TINY, x = tip:getContentSize().width / 2, y = tip:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(tip)
	end
	return tip
end

function UiUtil.unshowTip(parent, tag)
	tag = tag or "tip__"
	
	if parent[tag] then
		parent[tag]:removeSelf()
		parent[tag] = nil
	end
end

function UiUtil.clearImageCache()
	cc.SpriteFrameCache:sharedSpriteFrameCache():removeUnusedSpriteFrames()
	cc.TextureCache:sharedTextureCache():removeUnusedTextures()
end

local function mergeUiAwards(awards)
	local ret = {}

	local function add(award)
		if award.id and award.id == 0 then award.id = nil end

		for index = 1, #ret do
			local r = ret[index]
			if r.kind == award.kind then
				if r.id and award.id then
					if r.id == award.id then  -- 找到了
						r.count = r.count + award.count
						return
					end
				elseif not r.id and not award.id then  -- 找到了
					r.count = award.count
					return
				end
			end
		end
		ret[#ret + 1] = award
	end
	
	for index = 1, #awards do
		local award = awards[index]
		if not table.isexist(award, "kind") then award.kind = award.type end

		add(award)
	end
	return ret
end

-- bar: 显示奖励条
function UiUtil.showAwards(awards, bar)
	if not awards then return end

	if awards.fameUp then
		gprint("声望提升了 error!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	end

	-- gdump(awards.awards,"test =========== showAwards ")
	local as = {}
	for index = 1, #awards.awards do
		local award = awards.awards[index]
		if award.kind == ITEM_KIND_PROP or award.kind == ITEM_KIND_EQUIP or award.kind == ITEM_KIND_PART or award.kind == ITEM_KIND_CHIP
			or award.kind == ITEM_KIND_MATERIAL or award.kind == ITEM_KIND_HUANGBAO or award.kind == ITEM_KIND_EXP or award.kind == ITEM_KIND_SCORE
			or award.kind == ITEM_KIND_TANK or award.kind == ITEM_KIND_RESOURCE or award.kind == ITEM_KIND_FAME
			or award.kind == ITEM_KIND_POWER or award.kind == ITEM_KIND_HERO or award.kind == ITEM_KIND_MILITARY or award.kind == ITEM_KIND_ENERGY_SPAR 
			or award.kind == ITEM_KIND_EXPLOIT or award.kind == ITEM_KIND_FORMATION or award.kind == ITEM_KIND_CROSSSCORE or award.kind == ITEM_KIND_CHAR 
			or award.kind == ITEM_KIND_MEDAL_MATERIAL or award.kind == ITEM_KIND_MEDAL_ICON or award.kind == ITEM_KIND_MEDAL_CHIP 
			or award.kind == ITEM_KIND_WEAPONRY_ICON or award.kind == ITEM_KIND_WEAPONRY_PAPER or  award.kind == ITEM_KIND_WEAPONRY_MATERIAL
			or award.kind == ITEM_KIND_AWAKE_HERO or award.kind == ITEM_KIND_MILITARY_EXPLOIT or award.kind == ITEM_KIND_LABORATORY_RES
			or award.kind == ITEM_KIND_TACTIC_MATERIAL or award.kind == ITEM_KIND_TACTIC or award.kind == ITEM_KIND_TACTIC_PIECE then
			if award.count > 0 then
				as[#as + 1] = award
			end
		elseif award.kind == ITEM_KIND_COIN then
			award.detailed = true
			if award.count > 0 then
				as[#as + 1] = award
			end
		elseif award.kind == ITEM_KIND_HUNTER_COIN then
			award.detailed = true
			if award.count > 0 then
				as[#as + 1] = award
			end
		-- elseif award.kind == ITEM_KIND_HERO then
		-- 	gprint("UiUtil does not support HEROOOOOOOOOOOOOOOOO!!! Error!!!!")
		else
			gprint("UiUtil does not support!!!! Error!!!!", award.kind)
		end
	end

	if #as > 0 then
		local as = mergeUiAwards(as)
		local AwardsView = require("app.view.AwardsView")
		AwardsView.show(as, awards.levelUp, bar)
	end
end

-- 更新显示新的战力
function UiUtil.showFightChange(oldFight, newFight, fightParam)
	if UserMO.level_ < 2 then return end
	local FightChangeView = require("app.view.FightChangeView")
	FightChangeView.getInstance():start(oldFight, newFight, fightParam)
end

function UiUtil.showProsValue(pros, maxPros)
	local node = display.newNode()

	local label1 = ui.newTTFLabel({text = pros, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(node)
	label1:setAnchorPoint(0, 0)
	label1:setPosition(0, 0)
	node.prosLabel = pros

	node:setContentSize(label1:getContentSize())

	if maxPros then
		local label2 = ui.newTTFLabel({text = "/" .. maxPros, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(node)
		label2:setAnchorPoint(cc.p(0, 0))
		label2:setPosition(label1:getContentSize().width, 0)

		node:setContentSize(cc.size(label1:getContentSize().width + label2:getContentSize().width, label1:getContentSize().height))
		node.maxProsLabel = label2
	end
	return node
end

function UiUtil.showProsBar(pros, maxPros)
	local bar = nil
	if maxPros == 0 then
		bar = ProgressBar.new(IMAGE_COMMON .. "bar_8.png", BAR_DIRECTION_HORIZONTAL, nil, {bgName = IMAGE_COMMON .. "bar_bg_5.png"})
		bar:setPercent(0)
	else
		local percent = pros / maxPros
		if percent > 0.66 then
			bar = ProgressBar.new(IMAGE_COMMON .. "bar_6.png", BAR_DIRECTION_HORIZONTAL, nil, {bgName = IMAGE_COMMON .. "bar_bg_5.png"})
		elseif percent > 0.33 then
			bar = ProgressBar.new(IMAGE_COMMON .. "bar_7.png", BAR_DIRECTION_HORIZONTAL, nil, {bgName = IMAGE_COMMON .. "bar_bg_5.png"})
		else
			bar = ProgressBar.new(IMAGE_COMMON .. "bar_8.png", BAR_DIRECTION_HORIZONTAL, nil, {bgName = IMAGE_COMMON .. "bar_bg_5.png"})
		end
		bar:setPercent(percent)
	end

	local top = display.newSprite(IMAGE_COMMON .. "bar_bg_4.png"):addTo(bar, 10)
	top:setPosition(bar:getContentSize().width / 2, bar:getContentSize().height / 2)
	return bar
end

-- local horn_view_ = nil

-- 显示喇叭
function UiUtil.showHorn(chat)
	local HornView = require("app.view.HornView")
	HornView.show(chat)	
	-- if horn_view_ then
	-- 	horn_view_:removeSelf()
	-- 	horn_view_ = nil
	-- end

	-- local scene = display.getRunningScene()
	-- if scene then
	-- 	local function endCallback(sender)
	-- 		horn_view_:removeSelf()
	-- 		horn_view_ = nil
	-- 	end

	-- 	local HornView = require("app.view.HornView")
	-- 	local view = HornView.new(chat, endCallback):addTo(scene, 10000)
	-- 	view:setPosition(display.cx, display.height - 140)
	-- 	horn_view_ = view
	-- end
end

-- 根据需要显示的字体的大小，确定EditBox的高度
function UiUtil.getEditBoxHeight(fontSize)
	if device.platform == "android" then return fontSize + 12
	elseif device.platform == "ios" then return fontSize * 3 / 2
	else return fontSize + 12
	end
end


function UiUtil.strActivityTime(seconds, format)
	format = format or "dhms"
	format = string.lower(format)

	local isDay = false
	if string.find(format, "d") then isDay = true end

	local isHour = false
	if string.find(format, "h") then isHour = true end

	local isMin = false
	if string.find(format, "m") then isMin = true end

	local isSec = false
	if string.find(format, "s") then isSec = true end

	if format == "" then
		local time = ManagerTimer.time(seconds)
		if time.day > 0 then return string.format("%d:%02d:%02d:%02d", time.day, time.hour, time.minute, time.second)
		elseif time.hour > 0 then return string.format("%02d:%02d:%02d", time.hour, time.minute, time.second)
		else return string.format("%02d:%02d", time.minute, time.second)
		end
	elseif not isSec then -- 不显示秒
		local time = ManagerTimer.time(seconds)
		if time.day > 0 then return string.format("%dd%02dh%02dm", time.day, time.hour, time.minute)
		elseif time.hour > 0 then return string.format("%02dh%02dm", time.hour, time.minute)
		else return string.format("%02dm%02ds", time.minute, time.second)
		end
	else
		local time = ManagerTimer.time(seconds)
		if time.day > 0 then return string.format(CommonText[854][1], time.day, time.hour, time.minute, time.second)
		elseif time.hour > 0 then return string.format(CommonText[854][2], time.hour, time.minute, time.second)
		else return string.format(CommonText[854][3], time.minute, time.second)
		end
	end
end

function UiUtil.label(text,size,color,dimensions,align)
	local lab = ui.newTTFLabel({text = text, font = G_FONT, color=color, size = size or FONT_SIZE_SMALL, dimensions = dimensions, align = align or ui.TEXT_ALIGN_CENTER})
	return lab
end

function UiUtil.button(normal,selected,disabled,func,lab,isCell)
	local normal = display.newSprite(IMAGE_COMMON .. normal)
	local selected = display.newSprite(IMAGE_COMMON..selected)
	local disabled = disabled and display.newSprite(IMAGE_COMMON..disabled) or nil
	local btn = isCell and CellMenuButton or MenuButton
	btn = btn.new(normal, selected, disabled, func)
	if lab then
		btn:setLabel(lab)
	end
	return btn
end

function UiUtil.sprite9(img,x,y,ew,eh,w,h)
	local bg = display.newScale9Sprite(IMAGE_COMMON .. img)
	bg:setCapInsets(cc.rect(x, y, ew, eh))
	bg:setPreferredSize(cc.size(w, h))
	return bg
end

--检查scrollview有没有内容，没有加笑脸
function UiUtil.checkScrollNone(view,data)
	local p = view:getParent()
	if not p then return end
	if data and #data > 0 then
		if p.noneTip_ then p.noneTip_:removeSelf() p.noneTip_ = nil end
	else
		if not p.noneTip_ then
			p.noneTip_ = display.newSprite(IMAGE_COMMON .."smile.png")
				:addTo(p,10):pos(view:x()+view:width()/2,view:y()+view:height()/2)
			UiUtil.label(CommonText[20052],nil,cc.c3b(69, 104, 7))
				:addTo(p.noneTip_):align(display.CENTER_TOP,p.noneTip_:width()/2,-10)
		end
	end
end

--获取梯度价格
function UiUtil.getGradedPrice(grade,nowNum,buyNum)
	local total = 0
	for i=nowNum + 1,nowNum + buyNum do
		local t = grade[1][2]
		for k,v in ipairs(grade) do
			if i > v[1] and i <= grade[k+1][1] then
				t = grade[k+1][2]
				break
			end
		end
		total = total + t
	end
	return total
end


function UiUtil.createClipHead(headPath)
	local path = ""
	if type(headPath) == "string" then 
		path = headPath
	else
		path = string.format("head_%.3d",headPath)
	end
	local bg = display.newSprite(EDITOR_RES .. "head/" .. path .. ".png")
    local mask = display.newSprite(EDITOR_RES .. "scenes/rank/view_ranks_headbg.png")
    local clipping = cc.ClippingNode:create()
    clipping:setInverted(false)
    clipping:setAlphaThreshold(0.0)  

    clipping:setStencil(mask)
    clipping:addChild(bg)
    return clipping
end