--
-- Author: Zjw
-- Date: 2018-12-18 13:46:17
--
-- 战术批量选择消耗界面  BatchChoseMoreTacticsDialog


local Dialog = require("app.dialog.Dialog")
local BatchChoseMoreTacticsDialog = class("BatchChoseMoreTacticsDialog", Dialog)

--dialogFor 1为战术，2为战术碎片
function BatchChoseMoreTacticsDialog:ctor(dialogFor,quality,keyId,callBack,formation)
	BatchChoseMoreTacticsDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(500, 600)})
	self.m_dialogFor = dialogFor
	self.m_keyId = keyId
	self.m_quality = quality
	self.m_callBack = callBack
	self.m_formation = formation
	self.m_checkBoxs = {}
end

function BatchChoseMoreTacticsDialog:onEnter()
	BatchChoseMoreTacticsDialog.super.onEnter(self)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleX((self:getBg():getContentSize().width - 45) / btm:getContentSize().width) 
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	self:setTitle(CommonText[4007])

	local hasTanktype ={} 
	for index=1,5 do
		if TacticsMO.getTacticTankTypeState(self.m_dialogFor,self.m_quality,index,self.m_keyId,self.m_formation) then
			table.insert(hasTanktype,index)
		end
	end

	local index = 1
	for k,v in pairs(hasTanktype) do
		local tankicon = display.newSprite("image/tactics/tank_icon_"..v..".png"):addTo(self:getBg())
		tankicon:setPosition(cc.p(120,600-(index*80)-60))

		local name = ui.newTTFLabel({text = CommonText[4000][v], font = G_FONT, size = FONT_SIZE_MEDIUM, x = self:getBg():getContentSize().width / 2, y = 600-(index*80)-60, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		name:setColor(COLOR[11])
		name:setAnchorPoint(cc.p(0.5, 0.5))


		local lineB = display.newScale9Sprite(IMAGE_COMMON .. "awake_line.png"):addTo(self:getBg())
		lineB:setPreferredSize(cc.size(self:getBg():getContentSize().width - 80, lineB:height()))
		lineB:setPosition(self:getBg():getContentSize().width / 2, 600-(index*80)-100)

		local checkBox = CheckBox.new(nil, nil, handler(self, self.onCheckedChanged)):addTo(self:getBg())
		checkBox:setPosition(cc.p(self:getBg():getContentSize().width-120,600-(index*80)-60))
		checkBox:setChecked(true)
		checkBox.index = v
		index = index+1
		self.m_checkBoxs[v] = checkBox
	
	end

	-- 取消
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local strengthBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onCancelCallback)):addTo(self:getBg())
	strengthBtn:setPosition(self:getBg():getContentSize().width / 2 - 120, 26)
	strengthBtn:setLabel(CommonText[2])

	-- 确定
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local recreateBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onOKCallback)):addTo(self:getBg())
	recreateBtn:setPosition(self:getBg():getContentSize().width / 2 + 120, 26)
	recreateBtn:setLabel(CommonText[1])

end


function BatchChoseMoreTacticsDialog:onCheckedChanged(sender, isChecked)
	ManagerSound.playNormalButtonSound()

end

function BatchChoseMoreTacticsDialog:onCancelCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self:pop()
end

function BatchChoseMoreTacticsDialog:onOKCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local res = {}
	for k,v in pairs(self.m_checkBoxs) do
		if v:isChecked() then
			res[#res + 1] = k
		end
	end
	if self.m_callBack then
		self.m_callBack(res,self.m_quality)
	end
	self:pop()
end

return BatchChoseMoreTacticsDialog
