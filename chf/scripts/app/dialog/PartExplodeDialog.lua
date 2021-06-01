
-- 配件分解预览弹出框

local Dialog = require("app.dialog.Dialog")
local PartExplodeDialog = class("PartExplodeDialog", Dialog)

-- partKeyIds:所有要分解的配件的keyId
-- qualities: 如果partKeyIds的数量是多个，则必须有qualities字段，表示的是分解这些品质下的所有配件
function PartExplodeDialog:ctor(partKeyIds, qualities, key)
	self.m_keyIds = partKeyIds
	self.m_qualities = qualities
	self.key = key
	local res = {}

	gdump(self.m_keyIds, "PartExplodeDialog partKeyIds")
	--配件芯片(分解兑换活动开启时才有)
	local actChipCount = nil
	if ActivityCenterBO.isValid(ACTIVITY_ID_PART_RESOLVE) and not key then
		actChipCount = 0
	end

	-- 勋章芯片
	local actMedalCount = nil
	if ActivityCenterBO.isValid(ACTIVITY_ID_MEDAL_RESOLVE) and key == "medal" then
		actMedalCount = 0
	end

	for index = 1, #self.m_keyIds do
		local keyId = self.m_keyIds[index]
		if not key then
			local part = PartMO.getPartByKeyId(keyId)
			local partDB = PartMO.queryPartById(part.partId)
			local partRefit = PartMO.queryPartRefit(partDB.quality, part.refitLevel, part.partId)
			local partUp = PartMO.queryPartUp(part.partId, part.upLevel)

			-- dump(part, "part")
			-- dump(partDB, "partDB")
			-- dump(partRefit, "partRefit")

			if partRefit then
				if partRefit.fittingExplode > 0 then res[#res + 1] = {kind = ITEM_KIND_MATERIAL, id = MATERIAL_ID_FITTING, count = partRefit.fittingExplode} end
				if partRefit.planExplode > 0 then res[#res + 1] = {kind = ITEM_KIND_MATERIAL, id = MATERIAL_ID_PLAN, count = partRefit.planExplode} end
				if partRefit.mineralExplode > 0 then res[#res + 1] = {kind = ITEM_KIND_MATERIAL, id = MATERIAL_ID_MINERAL, count = partRefit.mineralExplode} end
				if partRefit.toolExplode > 0 then res[#res + 1] = {kind = ITEM_KIND_MATERIAL, id = MATERIAL_ID_TOOL, count = partRefit.toolExplode} end
				if partRefit.explode and partRefit.explode ~= "" then
					for k,v in ipairs(json.decode(partRefit.explode)) do
						-- for m,n in ipairs(res) do
							-- if n.kind == v[1] and n.id == v[2] then
							-- 	n.count = n.count + v[3]
							-- 	break
							-- end
						-- end
						table.insert(res, {kind = v[1],id = v[2],count = v[3]})
					end
				end
			end

			if partUp then
				if partUp.stoneExplode > 0 then res[#res + 1] = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_STONE, count = partUp.stoneExplode} end
			end

			if actChipCount then
				local resData = UserMO.getResourceData(ITEM_KIND_PART, part.partId)
				actChipCount = actChipCount + ActivityCenterMO.getActPartResolveChip(1,resData.quality)
			end
		elseif key == "medal" then
			for k,v in ipairs(MedalMO.getResolve(keyId)) do
				table.insert(res,v)
			end

			if actMedalCount ~= nil then
				local medal = MedalBO.medals[keyId]
				local md = MedalMO.queryById(medal.medalId)
				local quality = md.quality

				if medal.medalId ~= 1101 then
					if quality < 5 then
						local count = ActivityCenterMO.getMedalResolveChipCount(28, quality, md.position)
						actMedalCount = actMedalCount + count
					end
				else
					local count = ActivityCenterMO.getMedalResolveChipCount(29, 5)
					actMedalCount = actMedalCount + count
				end
			end
		elseif key == "weaponry" then
			--判断分解的品质，大于1则添加随机

			local resolvelist , quality = WeaponryMO.getResolve(keyId)
			for index = 1 , #resolvelist do
				table.insert(res,resolvelist[index])
			end

			--添加随机物品
			if quality > 1 then 
				local ret = {}
				ret.count = 1
				ret.type = ITEM_KIND_WEAPONRY_RANDOM
				ret.id = ITEM_KIND_WEAPONRY_RANDOM
				table.insert(res,ret)
			end
		end
	end

	self.m_explodeResource = CombatBO.arrangeAwards(res)

	gdump(self.m_explodeResource, "PartExplodeDialog resource")

	--如果有分解兑换活动则在分解资源中插入配件芯片（假道具，不存在背包，只是显示）
	if actChipCount and actChipCount > 0 then
		self.m_explodeResource[#self.m_explodeResource + 1] = {actChipCount = actChipCount}
	end

	if actMedalCount and actMedalCount > 0 then
		self.m_explodeResource[#self.m_explodeResource + 1] = {actMedalCount = actMedalCount}
	end

	local height = 0
	if #self.m_explodeResource <= 0 then
		height = 120 + 272
	else
		height = math.ceil(#self.m_explodeResource / 2) * 120 + 272   -- 每行显示两个
	end

	PartExplodeDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, height)})
end

function PartExplodeDialog:onEnter()
	PartExplodeDialog.super.onEnter(self)
	self:setTitle(CommonText[215]) -- 分解预览

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	local height = 0
	if #self.m_explodeResource <= 0 then
		height = 120 + 80
	else
		local row = math.ceil(#self.m_explodeResource / 2)
		height = row * 120 + 80
	end

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(506, height))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 75 - infoBg:getContentSize().height / 2)

	local desc = ui.newTTFLabel({text = CommonText[216], font = G_FONT, size = FONT_SIZE_MEDIUM, x = 20, y = infoBg:getContentSize().height - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	desc:setAnchorPoint(cc.p(0, 0.5))



	for index = 1, #self.m_explodeResource do
		local row = math.ceil(index / 2)
		local col = index - (row - 1) * 2

		local award = self.m_explodeResource[index]
		if award.actChipCount and award.actChipCount > 0 then
			local itemBg = display.newSprite(IMAGE_COMMON .. "item_fame_4.png"):addTo(self:getBg())
			itemBg:setPosition(100 + (col - 1) * 230, self:getBg():getContentSize().height - 130 - (row - 0.5) * 120)
			local itemView = display.newSprite("image/item/activity_115_chip.jpg"):addTo(itemBg)
			itemView:setPosition(itemBg:getContentSize().width / 2 , itemBg:getContentSize().height / 2)

			local name = ui.newTTFLabel({text = CommonText[881], font = G_FONT, size = FONT_SIZE_MEDIUM, x = itemBg:getPositionX() + itemBg:getContentSize().width / 2 + 6, y = itemBg:getPositionY() + itemBg:getContentSize().height / 2 - 20, color = COLOR[4], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			name:setAnchorPoint(cc.p(0, 0.5))

			-- 零件数量
			local label1 = ui.newTTFLabel({text = "+" .. UiUtil.strNumSimplify(award.actChipCount), font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 50, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			label1:setAnchorPoint(cc.p(0, 0.5))
		elseif	award.actMedalCount and award.actMedalCount > 0 then
			local itemBg = display.newSprite(IMAGE_COMMON .. "item_fame_4.png"):addTo(self:getBg())
			itemBg:setPosition(100 + (col - 1) * 230, self:getBg():getContentSize().height - 130 - (row - 0.5) * 120)
			local itemView = display.newSprite("image/item/activity_153_chip.jpg"):addTo(itemBg)
			itemView:setPosition(itemBg:getContentSize().width / 2 , itemBg:getContentSize().height / 2)

			local name = ui.newTTFLabel({text = "勋章芯片", font = G_FONT, size = FONT_SIZE_MEDIUM, x = itemBg:getPositionX() + itemBg:getContentSize().width / 2 + 6, y = itemBg:getPositionY() + itemBg:getContentSize().height / 2 - 20, color = COLOR[4], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			name:setAnchorPoint(cc.p(0, 0.5))

			-- 零件数量
			local label1 = ui.newTTFLabel({text = "+" .. UiUtil.strNumSimplify(award.actMedalCount), font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 50, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			label1:setAnchorPoint(cc.p(0, 0.5))

		elseif	award.kind == ITEM_KIND_WEAPONRY_RANDOM then
			local resData = UserMO.getResourceData(award.kind, award.id)

			local itemView = UiUtil.createItemView(award.kind, award.id):addTo(self:getBg())
			itemView:setPosition(100 + (col - 1) * 230, self:getBg():getContentSize().height - 130 - (row - 0.5) * 120)
			--UiUtil.createItemDetailButton(itemView)

			local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_MEDIUM, x = itemView:getPositionX() + itemView:getContentSize().width / 2 + 6, y = itemView:getPositionY() + itemView:getContentSize().height / 2 - 20, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			name:setAnchorPoint(cc.p(0, 0.5))

		else
			local resData = UserMO.getResourceData(award.kind, award.id)

			local itemView = UiUtil.createItemView(award.kind, award.id):addTo(self:getBg())
			itemView:setPosition(100 + (col - 1) * 230, self:getBg():getContentSize().height - 130 - (row - 0.5) * 120)
			UiUtil.createItemDetailButton(itemView)

			local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_MEDIUM, x = itemView:getPositionX() + itemView:getContentSize().width / 2 + 6, y = itemView:getPositionY() + itemView:getContentSize().height / 2 - 20, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			name:setAnchorPoint(cc.p(0, 0.5))

			-- 零件数量
			local label1 = ui.newTTFLabel({text = "+" .. UiUtil.strNumSimplify(award.count), font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 50, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
			label1:setAnchorPoint(cc.p(0, 0.5))
		end
	end

	-- 取消
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local cancelBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onCancelCallback)):addTo(self:getBg())
	cancelBtn:setPosition(self:getBg():getContentSize().width / 2 - 150, 26)
	cancelBtn:setLabel(CommonText[2])

	-- 分解
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local exchangeBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onExplodeCallback)):addTo(self:getBg())
	exchangeBtn:setPosition(self:getBg():getContentSize().width / 2 + 150, 26)
	exchangeBtn:setLabel(CommonText[171])
end

function PartExplodeDialog:onCancelCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	self:pop()
end

function PartExplodeDialog:onExplodeCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	
	local function doneExplode(stastAwards)
		Loading.getInstance():unshow()
		UiUtil.showAwards(stastAwards)
		Toast.show(CommonText[517]) -- 分解成功
		self:pop()
	end

	Loading.getInstance():show()
	local func = nil 	
	if self.key == "medal" then
		func = MedalBO.explodeMedal 
	elseif self.key == "weaponry" then
		func =  WeaponryBO.explodeWeaponry
	else
		func = PartBO.asynExplodePart
	end 

	if #self.m_keyIds > 1 then -- 按品质批量分解
		func(doneExplode, nil, self.m_qualities)
	else
		func(doneExplode, self.m_keyIds[1])
	end
end

return PartExplodeDialog