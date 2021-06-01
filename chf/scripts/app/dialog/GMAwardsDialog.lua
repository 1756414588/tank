--
-- Author: gf
-- Date: 2015-12-30 16:48:03
--


local ConfirmDialog = require("app.dialog.ConfirmDialog")
local Dialog = require("app.dialog.Dialog")
local GMAwardsDialog = class("GMAwardsDialog", Dialog)

function GMAwardsDialog:ctor()
	GMAwardsDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(GAME_SIZE_WIDTH, display.height)})
	
end

function GMAwardsDialog:onEnter()
	GMAwardsDialog.super.onEnter(self)

	self:setTitle(CommonText[712])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(display.width, display.height))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(btm)
   	line:setPreferredSize(cc.size(btm:getContentSize().width - 60, line:getContentSize().height))
   	line:setPosition(btm:getContentSize().width / 2, 120)

   	local awardNode = {}
   	for index = 1,10 do
   		local m_node = display.newNode():addTo(btm)
   		local input_bg = IMAGE_COMMON .. "info_bg_15.png"
   		local typeLab = ui.newTTFLabel({text = "type:", font = G_FONT, size = FONT_SIZE_MEDIUM, 
			x = 50, y = btm:getContentSize().height - 100 - (index - 1) * 80, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(m_node)
		typeLab:setAnchorPoint(cc.p(0, 0.5))
		local inputType = ui.newEditBox({image = input_bg, listener = onEdit, size = cc.size(100, 50)}):addTo(m_node)
		inputType:setFontColor(COLOR[3])
		inputType:setFontSize(FONT_SIZE_TINY)
		inputType:setPosition(typeLab:getPositionX() + typeLab:getContentSize().width + inputType:getContentSize().width / 2, typeLab:getPositionY())
		m_node.inputType = inputType

		local idLab = ui.newTTFLabel({text = "id:", font = G_FONT, size = FONT_SIZE_MEDIUM, 
			x = 250, y = btm:getContentSize().height - 100 - (index - 1) * 80, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(m_node)
		idLab:setAnchorPoint(cc.p(0, 0.5))
		local inputId = ui.newEditBox({image = input_bg, listener = onEdit, size = cc.size(100, 50)}):addTo(m_node)
		inputId:setFontColor(COLOR[3])
		inputId:setFontSize(FONT_SIZE_TINY)
		inputId:setPosition(idLab:getPositionX() + idLab:getContentSize().width + inputId:getContentSize().width / 2, idLab:getPositionY())
		m_node.inputId = inputId

		local countLab = ui.newTTFLabel({text = "count:", font = G_FONT, size = FONT_SIZE_MEDIUM, 
			x = 400, y = btm:getContentSize().height - 100 - (index - 1) * 80, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(m_node)
		countLab:setAnchorPoint(cc.p(0, 0.5))
		local inputCount = ui.newEditBox({image = input_bg, listener = onEdit, size = cc.size(100, 50)}):addTo(m_node)
		inputCount:setFontColor(COLOR[3])
		inputCount:setFontSize(FONT_SIZE_TINY)
		inputCount:setPosition(countLab:getPositionX() + countLab:getContentSize().width + inputCount:getContentSize().width / 2, countLab:getPositionY())
		m_node.inputCount = inputCount

		awardNode[#awardNode + 1] = m_node
   	end

   	self.awardNode = awardNode

   	--取消
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local cancelBtn = MenuButton.new(normal, selected, nil, handler(self,self.cancelHandler)):addTo(btm)
	cancelBtn:setPosition(btm:getContentSize().width / 2 - 200,80)
	cancelBtn:setLabel("取消")

   	--保存
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local saveBtn = MenuButton.new(normal, selected, nil, handler(self,self.saveAwardsHandler)):addTo(btm)
	saveBtn:setPosition(btm:getContentSize().width / 2 + 200,80)
	saveBtn:setLabel("保存")


	--预览
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local preBtn = MenuButton.new(normal, selected, nil, handler(self,self.preHandler)):addTo(btm)
	preBtn:setPosition(btm:getContentSize().width / 2,80)
	preBtn:setLabel("奖励预览")
end

function GMAwardsDialog:preHandler(tag, sender)
	local awards = {}
	for index=1,#self.awardNode do
		local awardNode = self.awardNode[index]
		local typeValue = string.gsub(awardNode.inputType:getText()," ","") 
		local idValue = string.gsub(awardNode.inputId:getText()," ","")
		local countValue = string.gsub(awardNode.inputCount:getText()," ","")
		if typeValue and typeValue ~= "" and idValue and idValue ~= "" and countValue and countValue ~= "" then
			local award = {}
			award.type = tonumber(typeValue)
			award.id = tonumber(idValue)
			award.count = tonumber(countValue)
			awards[#awards + 1] = award
		end
	end

	require_ex("app.dialog.GMAwardsPreDialog").new(awards):push()
	

end

function GMAwardsDialog:saveAwardsHandler(tag, sender)
	local awards = {}
	for index=1,#self.awardNode do
		local awardNode = self.awardNode[index]
		local typeValue = string.gsub(awardNode.inputType:getText()," ","") 
		local idValue = string.gsub(awardNode.inputId:getText()," ","")
		local countValue = string.gsub(awardNode.inputCount:getText()," ","")
		if typeValue and typeValue ~= "" and idValue and idValue ~= "" and countValue and countValue ~= "" then
			local award = {}
			award.type = tonumber(typeValue)
			award.id = tonumber(idValue)
			award.count = tonumber(countValue)
			awards[#awards + 1] = award
		end
	end

	gdump(awards,"need add awards====")
	if #awards > 0 then
		local oldAwards = GMBO.getAwards()
		oldAwards[#oldAwards + 1] = awards
		GMBO.saveAwards(function()
			Toast.show("保存成功!")

			end,oldAwards)
	else
		Toast.show("请添加需要保存的奖励!")
	end
end

function GMAwardsDialog:cancelHandler(tag, sender)
	self:pop()
end

return GMAwardsDialog