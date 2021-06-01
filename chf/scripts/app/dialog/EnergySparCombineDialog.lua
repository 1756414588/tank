
local function formatCombineConfirm(szProb,color1,times,color2, name, lv, color3)
	local str = CommonText[947][3]
	str = json.decode(str)

	dump(str, "formatCombineConfirm")

	local stringDatas = {}

	for i=1,#str do
		stringDatas[i] = {}
		stringDatas[i].size = FONT_SIZE_MEDIUM - 2
	end

	local index = 1
	stringDatas[index].content = str[index][1]
	index = index + 1
	stringDatas[index].content = string.format(str[index][1], szProb)
	stringDatas[index].color = color1
	index = index + 1
	stringDatas[index].content = str[index][1]
	index = index + 1
	stringDatas[index].content = string.format(str[index][1], times)
	stringDatas[index].color = color2
	index = index + 1
	stringDatas[index].content = str[index][1]	
	index = index + 1
	stringDatas[index].content = string.format(str[index][1], name, lv)
	stringDatas[index].color = color3

	return stringDatas
end


-- 能晶合成弹出框

local Dialog = require("app.dialog.Dialog")
local EnergySparCombineDialog = class("EnergySparCombineDialog", Dialog)

-- chipId:配件碎片的keyId
function EnergySparCombineDialog:ctor(stoneId)
	EnergySparCombineDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 450)})
	self.m_stoneId = stoneId

	self.m_minNum = 1
	self.m_maxNum = 3	
	self.m_limit = self.m_maxNum
	self.m_totolCount = 0
end

function EnergySparCombineDialog:onEnter()
	EnergySparCombineDialog.super.onEnter(self)

	self:setTitle(CommonText[214]) -- 合成

	local sparDB = EnergySparMO.queryEnergySparById(self.m_stoneId)
	local count = UserMO.getResource(ITEM_KIND_ENERGY_SPAR, self.m_stoneId)

	self.m_sparDB = sparDB

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(506, 145))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 75 - infoBg:getContentSize().height / 2)

	local itemView = UiUtil.createItemView(ITEM_KIND_ENERGY_SPAR, self.m_stoneId):addTo(infoBg)
	itemView:setPosition(70, infoBg:getContentSize().height - 20 - itemView:getContentSize().height / 2)

	local name = ui.newTTFLabel({text = string.format("%sLv.%d", sparDB.stoneName, sparDB.level), font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = 135, y = infoBg:getContentSize().height - 40, color = COLOR[sparDB.quite], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	name:setAnchorPoint(cc.p(0, 0.5))

	-- 当前数量
	local label1 = ui.newTTFLabel({text = CommonText[95] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label1:setAnchorPoint(cc.p(0, 0.5))
	startLabel = label1

	self.m_limit = math.min(self.m_limit, count)

	local value = ui.newTTFLabel({text = count, font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX() + label1:getContentSize().width + 5, y = label1:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	local attr = AttributeBO.getAttributeData(sparDB.attrId, sparDB.attrValue)
	-- 当前数量
	local label1 = ui.newTTFLabel({text = attr.name ..CommonText[176], font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 70, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label1:setAnchorPoint(cc.p(0, 0.5))
	startLabel = label1

	local value = ui.newTTFLabel({text = (attr.value > 0 and "+" or "-") .. attr.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label1:getPositionX() + label1:getContentSize().width + 5, y = label1:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	---下一等级
	local nextSparDB = EnergySparMO.queryEnergySparById(sparDB.synthesizing)

	-- local arrows = display.newSprite(IMAGE_COMMON .. "icon_arrow_right.png"):addTo(infoBg)
	-- arrows:setPosition(value:getPositionX() + 150, name:getPositionY())

	local nextName = ui.newTTFLabel({text = string.format("Lv.%d", nextSparDB.level), font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = value:getPositionX() + 180, y = name:getPositionY(), color = COLOR[nextSparDB.quite], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	nextName:setAnchorPoint(cc.p(0, 0.5))

	local arrows = display.newSprite(IMAGE_COMMON .. "icon_arrow_right.png"):addTo(infoBg)
	arrows:setPosition(value:getPositionX() + 120, value:getPositionY())

	local attr = AttributeBO.getAttributeData(nextSparDB.attrId, nextSparDB.attrValue)
	local value = ui.newTTFLabel({text = (attr.value > 0 and "+" or "-") .. attr.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = arrows:getPositionX() + arrows:getContentSize().width + 10, y = arrows:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	value:setAnchorPoint(cc.p(0, 0.5))	

    -- 减少按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_reduce_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_reduce_selected.png")
    local reduceBtn = MenuButton.new(normal, selected, nil, handler(self, self.onReduceCallback)):addTo(self:getBg())
    reduceBtn:setPosition(self:getBg():getContentSize().width / 2 - 150, 160 + 16)

    -- 增加按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
    local addBtn = MenuButton.new(normal, selected, nil, handler(self, self.onAddCallback)):addTo(self:getBg())
    addBtn:setPosition(self:getBg():getContentSize().width / 2 + 150, reduceBtn:getPositionY())

	-- -- 数量
	-- local label = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_MEDIUM, x = self:getBg():getContentSize().width / 2 - 50, y = 220, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	-- label:setAnchorPoint(cc.p(0, 0.5))

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(200, 60))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, reduceBtn:getPositionY())
	-- -- 
	local countLabel = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = self:getBg():getContentSize().width / 2, y = reduceBtn:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	self.m_numLabel = countLabel

	---放入数量
	local label1 = ui.newTTFLabel({text = CommonText[948][2], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 70, y = 120, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label1:setAnchorPoint(cc.p(0, 0.5))

	local inputLabel = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = label1:getPositionX() + label1:getContentSize().width + 2, y = label1:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	inputLabel:setAnchorPoint(cc.p(0, 0.5))
	self.m_inputLabel = inputLabel

	local label2 = ui.newTTFLabel({text = "/3", font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = label1:getPositionX() + label1:getContentSize().width + 20, y = label1:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label2:setAnchorPoint(cc.p(0, 0.5))

	---合成率
	local label1 = ui.newTTFLabel({text = CommonText[948][3], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 70, y = 85, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label1:setAnchorPoint(cc.p(0, 0.5))

	local combineLabel = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = label1:getPositionX() + label1:getContentSize().width + 2, y = label1:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	combineLabel:setAnchorPoint(cc.p(0, 0.5))
	self.m_combineLabel = combineLabel

	-- 批量合成
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local exchangeBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onBatchCallback)):addTo(self:getBg())
	exchangeBtn:setPosition(self:getBg():getContentSize().width / 2 - 150, 26)
	exchangeBtn:setLabel(CommonText[948][1])


	-- 合成
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local combineBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onCombineCallback)):addTo(self:getBg())
	combineBtn:setPosition(self:getBg():getContentSize().width / 2 + 150, 26)
	combineBtn:setLabel(CommonText[214])

	self.m_totolCount = count

	self.m_settingNum = math.min(count, self.m_maxNum)

	self:updateCountLable()
end

function EnergySparCombineDialog:onReduceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum - 1
	self.m_settingNum = math.max(self.m_settingNum, self.m_minNum)
	self:updateCountLable()
end

function EnergySparCombineDialog:onAddCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum + 1
	self.m_settingNum = math.min(self.m_settingNum, self.m_limit)
	self:updateCountLable()
end

function EnergySparCombineDialog:updateCountLable()
	self.m_numLabel:setString(self.m_settingNum .. "")
	self.m_inputLabel:setString(self.m_settingNum .. "")

	if self.m_settingNum >= self.m_maxNum then
		self.m_combineLabel:setColor(COLOR[2])
	else
		self.m_combineLabel:setColor(COLOR[6])
	end
	self.m_combineLabel:setString(string.format("%d%%", math.floor((self.m_settingNum / self.m_maxNum) * 100)))
end

function EnergySparCombineDialog:onBatchCallback( tag, sender )
	self:doCombine(true, math.floor(self.m_totolCount/self.m_settingNum))
end

function EnergySparCombineDialog:onCombineCallback( tag, sender )
	self:doCombine(false, 1)
end

function EnergySparCombineDialog:doCombine( isBatch, combineTimes )
	local sparDB = self.m_sparDB
	local nextSparDB = EnergySparMO.queryEnergySparById(sparDB.synthesizing)

	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	local str = self.m_combineLabel:getString()
	-- local desc = string.format(CommonText[947][3], str,combineTimes, nextSparDB.stoneName, nextSparDB.level)
	local desc = formatCombineConfirm(str, self.m_combineLabel:getColor(), combineTimes,COLOR[2], nextSparDB.stoneName, nextSparDB.level, COLOR[nextSparDB.quite])
	ConfirmDialog.new(desc, function()
		local function doneCallback(newStoneId, successTimes, loseTimes)
			Loading.getInstance():unshow()
			self:pop()
			if isBatch then
				local EnergyCombineRsDialog = require("app.dialog.EnergyCombineRsDialog")		
				EnergyCombineRsDialog.new(newStoneId, successTimes, loseTimes):push()
			else
				if successTimes > 0 then
					Toast.show(CommonText[467][1])
					UiUtil.showAwards({awards = {{kind = ITEM_KIND_ENERGY_SPAR, id = newStoneId, count = successTimes}}})
				else
					Toast.show(CommonText[467][2])
				end
			end
		end

		Loading.getInstance():show()
		EnergySparBO.doEnergyStoneCombine(doneCallback, self.m_stoneId, self.m_settingNum, combineTimes, isBatch)
	end):push()	
end

return EnergySparCombineDialog