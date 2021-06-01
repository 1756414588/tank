--
-- Author: Gss
-- Date: 2018-12-18 13:46:17
--
-- 战术批量选择消耗界面  BatchChoseTacticsDialog


local Dialog = require("app.dialog.Dialog")
local BatchChoseTacticsDialog = class("BatchChoseTacticsDialog", Dialog)

--dialogFor 1为战术，2为战术碎片
function BatchChoseTacticsDialog:ctor(dialogFor,keyId, callBack, formation)
	BatchChoseTacticsDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 382)})
	self.m_dialogFor = dialogFor
	self.m_keyId = keyId
	self.m_callBack = callBack
	self.m_formation = formation
	self.m_checkBoxs = {}
	self.m_tankType = {}
	for i=1,3 do
		self.m_tankType[i] = {1,2,3,4,5}
	end
end

function BatchChoseTacticsDialog:onEnter()
	BatchChoseTacticsDialog.super.onEnter(self)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	self:setTitle(CommonText[4007])

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(506, 210))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 75 - infoBg:getContentSize().height / 2)

	local desc = ui.newTTFLabel({text = CommonText[4022], font = G_FONT, size = FONT_SIZE_SMALL, x = infoBg:getContentSize().width / 2, y = infoBg:getContentSize().height - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)

	for index = 1, 3 do
		local checkBox = CheckBox.new(nil, nil, handler(self, self.onCheckedChanged)):addTo(infoBg)
		local x, y
		if index <= 2 then y = 130
		else y = 50 end

		if index == 1 or index == 3 then x = 50
		else x = 310 end

		checkBox:setPosition(x, y)
		checkBox.index = index

		local str = ""
		if self.m_dialogFor == 1 then
			str = CommonText.color[index + 1][2] .. CommonText[4002][2]
		elseif self.m_dialogFor == 2 then
			str = CommonText.color[index + 1][2] .. CommonText[4002][1]
		end

		local label = ui.newTTFLabel({text = str, font = G_FONT, size = FONT_SIZE_TINY, x = checkBox:getPositionX() + checkBox:getContentSize().width / 2 + 10, y = checkBox:getPositionY(), color = COLOR[index + 1], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		if TacticsMO.getTacticQualityState(self.m_dialogFor,index,self.m_keyId,self.m_formation) then
			--设置
			local normal = display.newSprite(IMAGE_COMMON .. "btn_levelset_nomal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_levelset_select.png")
			local settingBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onSetCallback)):addTo(infoBg)
			settingBtn:setPosition(label:getPositionX()+label:getContentSize().width+20,label:getPositionY()-2)
			settingBtn.index = index
			checkBox.btn = settingBtn
			settingBtn:setVisible(checkBox:isChecked())
		end
		self.m_checkBoxs[index] = checkBox
	end

	-- 取消
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local strengthBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onCancelCallback)):addTo(self:getBg())
	strengthBtn:setPosition(self:getBg():getContentSize().width / 2 - 150, 26)
	strengthBtn:setLabel(CommonText[2])

	-- 确定
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local recreateBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onOKCallback)):addTo(self:getBg())
	recreateBtn:setPosition(self:getBg():getContentSize().width / 2 + 150, 26)
	recreateBtn:setLabel(CommonText[1])

end

function BatchChoseTacticsDialog:onSetCallback(tag, sender)
	require("app.dialog.BatchChoseMoreTacticsDialog").new(self.m_dialogFor,sender.index,self.m_keyId, function (tankType,quality)
		self.m_tankType[quality] = tankType
	end,self.m_formation):push()
end

function BatchChoseTacticsDialog:onCheckedChanged( sender, isChecked)
	ManagerSound.playNormalButtonSound()
	if sender.btn~= nil then
		if isChecked then 
			sender.btn:setVisible(true)
		else
			sender.btn:setVisible(false)
		end
	end
end

function BatchChoseTacticsDialog:onCancelCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self:pop()
end

function BatchChoseTacticsDialog:onOKCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local res = {}
	for index = 1, #self.m_checkBoxs do
		if self.m_checkBoxs[index]:isChecked() then
			res[#res + 1] = index -- 品质为index(绿色为1)
		end
	end

	local function hasQuality(quality)
		for index = 1, #res do
			local limit = res[index] + 1
			limit = res[index]

			if limit == quality then
				return true
			end
		end
		return false
	end
	--战术类型
	local function hasType(taticType,quality)
		for k,v in pairs(self.m_tankType[quality]) do
			if v == taticType then
				return true
			end
		end
		return false
	end

	local taticList = {} --全部战术
	local pieceList = {} --全部碎片
	if self.m_dialogFor == 2 then --如果是战术
		local tactics = TacticsMO.getConsumeTactics(self.m_keyId, self.m_formation)
		for index = 1, #tactics do
			local tactic = tactics[index]
			local tacticsDb = TacticsMO.queryTacticById(tactic.tacticsId)
			if hasQuality(tactic.quality) and hasType(tacticsDb.tanktype,tactic.quality) then
				taticList[#taticList + 1] = tactic
			end
		end

		if #taticList <= 0 then
			Toast.show(CommonText[4023][1])
			self:pop()
			return
		end
	elseif self.m_dialogFor == 1 then --碎片
		local pieces = TacticsMO.getConsumeTacticPieces()
		for index = 1, #pieces do
			local tactic = pieces[index]
			if hasQuality(tactic.quality) and hasType(tactic.tanktype,tactic.quality)  then
				pieceList[#pieceList + 1] = tactic
			end
		end

		if #pieceList <= 0 then
			Toast.show(CommonText[4023][2])
			self:pop()
			return
		end
	end

	if self.m_callBack then
		self.m_callBack(taticList, pieceList)
	end
	self:pop()
end

return BatchChoseTacticsDialog
