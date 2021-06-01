--
-- Author: gf
-- Date: 2015-12-18 18:53:37
-- 分配百团混战 奖励


local Dialog = require("app.dialog.Dialog")
local PartyBAwardAllotDialog = class("PartyBAwardAllotDialog", Dialog)

function PartyBAwardAllotDialog:ctor(data)
	PartyBAwardAllotDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 450)})

	
	self.data = data
end

function PartyBAwardAllotDialog:onEnter()
	PartyBAwardAllotDialog.super.onEnter(self)

	self:setOutOfBgClose(true)
	self:showUI()
end

function PartyBAwardAllotDialog:showUI()
	if self.m_numLabel then return end

	local resData = UserMO.getResourceData(ITEM_KIND_PROP, self.data.propId)

	local itemView = UiUtil.createItemView(ITEM_KIND_PROP, self.data.propId)
	itemView:setPosition(100,self:getBg():getContentSize().height - 100)
	self:getBg():addChild(itemView)

	-- 名称
	local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 170, y = self:getBg():getContentSize().height - 60, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	name:setAnchorPoint(cc.p(0, 0.5))

	local desc = ui.newTTFLabel({text = resData.desc, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 170, y = self:getBg():getContentSize().height - 100, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(260, 80)}):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0.5, 0.5))

	
	-- local function onEdit(event, editbox)
	-- --    if eventType == "return" then
	-- --    end
 --    end
	-- local input_bg = IMAGE_COMMON .. "info_bg_14.jpg"

 --    local inputName = ui.newEditBox({image = input_bg, listener = nil, size = cc.size(300, 40)}):addTo(self:getBg())
	-- inputName:setFontColor(COLOR[1])
	-- inputName:setFontSize(FONT_SIZE_SMALL)
	-- inputName:setPosition(100 + inputName:getContentSize().width / 2, self:getBg():getContentSize().height - 190)
	-- inputName:setEnabled(false)
	
	local input_bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	input_bg:setPreferredSize(cc.size(300, 40))
	input_bg:setPosition(100 + input_bg:getContentSize().width / 2, self:getBg():getContentSize().height - 190)

	local inputName = ui.newTTFLabel({text = "点击添加分配成员", font = G_FONT, size = FONT_SIZE_MEDIUM,dimensions = cc.size(300, 30),
		 color = COLOR[1], align = ui.TEXT_ALIGN_LEFT}):addTo(input_bg)
	inputName:setAnchorPoint(cc.p(0, 0.5))
	inputName:setPosition(0, input_bg:getContentSize().height / 2)


	nodeTouchEventProtocol(input_bg, function(event) 
		-- Toast.show(CommonText[717]) 
		if event.name == "ended" then
            self:openContactDia()
		else
			return true
        end
	       
		end, nil, nil, true)

	self.inputName = inputName



	local normal = display.newSprite(IMAGE_COMMON .. "btn_search_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_search_selected.png")
	local contactBtn = MenuButton.new(normal, selected, nil, handler(self,self.openContactDia)):addTo(self:getBg())
	contactBtn:setPosition(self:getBg():getContentSize().width - 80, self:getBg():getContentSize().height - 190)


    -- 减少按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_reduce_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_reduce_selected.png")
    local reduceBtn = MenuButton.new(normal, selected, nil, handler(self, self.onReduceCallback)):addTo(self:getBg())
    reduceBtn:setPosition(64, 160 + 16)

    -- 增加按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
    local addBtn = MenuButton.new(normal, selected, nil, handler(self, self.onAddCallback)):addTo(self:getBg())
    addBtn:setPosition(self:getBg():getContentSize().width - 64, reduceBtn:getPositionY())

	-- 数量
	local label = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_MEDIUM, x = self:getBg():getContentSize().width / 2 - 50, y = 220, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 
	local count = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_MEDIUM, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	count:setAnchorPoint(cc.p(0, 0.5))
	self.m_numLabel = count

    self.m_maxNum = self.data.count
    self.m_minNum = 1
    if self.m_maxNum == 0 then self.m_minNum = 0 end
    
	self.m_settingNum = self.m_minNum

	local barHeight = 40
	local barWidth = 266
	self.m_numSlider = Slider.new(display.LEFT_TO_RIGHT, {bar = IMAGE_COMMON.."bar_4.png", button = IMAGE_COMMON.."btn_slider_head.png"}, {scale9 = true,min=self.m_minNum,max = self.m_maxNum}):addTo(self:getBg())
	self.m_numSlider:align(display.LEFT_BOTTOM, self:getBg():getContentSize().width / 2 - barWidth / 2, 160)
    self.m_numSlider:setSliderSize(barWidth, barHeight)
    self.m_numSlider:onSliderValueChanged(handler(self, self.onSlideCallback))
    self.m_numSlider:setSliderValue(self.m_settingNum)
    self.m_numSlider:setBg(IMAGE_COMMON .. "bar_bg_3.png", cc.size(266 + 78, 64), {x = barWidth / 2, y = barHeight / 2 - 4})

	-- 分配
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onAllotCallback)):addTo(self:getBg())
	btn:setPosition(self:getBg():getContentSize().width / 2, 80)
	btn:setLabel(CommonText[818])

end

function PartyBAwardAllotDialog:onReduceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum - 1
	self.m_settingNum = math.max(self.m_settingNum, self.m_minNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

function PartyBAwardAllotDialog:onAddCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum + 1
	self.m_settingNum = math.min(self.m_settingNum, self.m_maxNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

function PartyBAwardAllotDialog:onSlideCallback(event)

	local value = event.value - event.value % 1
	self.m_settingNum = math.min(value, self.m_maxNum)
	self.m_numLabel:setString(self.m_settingNum)
end

function PartyBAwardAllotDialog:openContactDia(tag,sender)
	local function contactCallback(contacts)
		local num = 0
		self.sendIds = {}
		if contacts and #contacts >= 0 then
			num = #contacts

			local str = ""
			for index = 1, #contacts do
				local contact = contacts[index]
				self.sendIds[#self.sendIds + 1] = contact.lordId
				if index ~= #contacts then
					str = str .. contact.name .. "&&"
				else
					str = str .. contact.name
				end
			end
			self:updateSettingNum()
			self.inputName:setString(str)
		else
			self.inputName:setString("")
		end
	end

	self.m_settingNum = self.m_minNum
	local ContactDialog = require("app.dialog.ContactDialog")
	ContactDialog.new(CONTACT_MODE_MULTIPLE, contactCallback, 1):push()
end

function PartyBAwardAllotDialog:updateSettingNum()
	if self.sendIds and #self.sendIds > 0 then
		self.m_maxNum = math.floor(self.data.count / #self.sendIds) 
		-- self.m_settingNum = self.m_maxNum
	else
		self.m_maxNum = self.data.count
	end

	self.m_numSlider:setSliderValue(self.m_settingNum)

end

function PartyBAwardAllotDialog:onAllotCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if not self.sendIds or #self.sendIds == 0 then
		Toast.show(CommonText[819])
		return
	end
	--判断数量
	if self.m_maxNum == 0 or #self.sendIds * self.m_settingNum > self.data.count then
		Toast.show(CommonText[822])
		return
	end
	Loading.getInstance():show()
	PartyBattleBO.asynSendPartyAmyProp(function()
		Loading.getInstance():unshow()
		Toast.show(CommonText[820])
		UiDirector.pop()
		end,self.sendIds,self.m_settingNum,self.data)

end

return PartyBAwardAllotDialog