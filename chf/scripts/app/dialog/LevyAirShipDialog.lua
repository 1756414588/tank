
------------------------------------------------------------------------------
-- 发起战事
------------------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local LevyAirShipDialog = class("LevyAirShipDialog", Dialog)

function LevyAirShipDialog:ctor(airshipId)
	LevyAirShipDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 350)})
	self.m_airshipId = airshipId
end

function LevyAirShipDialog:onEnter()
	LevyAirShipDialog.super.onEnter(self)
	self:setOutOfBgClose(true)
	self:setTitle(CommonText[1052])  -- 军团集结

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(520, 320))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local propId = PROP_ID_LEVY_AIRSHIP
	local prop = UserMO.getResourceData(ITEM_KIND_PROP, propId)
	local propCount = UserMO.getResource(ITEM_KIND_PROP, propId)

	local ab = AirshipMO.queryShipById(self.m_airshipId)
    local cost = json.decode(ab.cost)
    local factor = 1

	local lab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL+2, 
		x = self:getBg():getContentSize().width / 2, 
		y = self:getBg():getContentSize().height - 60, 
		dimensions = cc.size(420, 120),
		align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	lab:setAnchorPoint(cc.p(0.5, 1))

	local function updateLabel()
	    local costStr = ""

	    for i,v in ipairs(cost) do
	        local resData = UserMO.getResourceData(v[1], v[2])
	        if factor > 1 then
		        costStr = costStr .. v[3] .. "*" .. factor .. resData.name
		    else
		        costStr = costStr .. v[3] .. resData.name
		    end
	        if i < #cost then
	            costStr = costStr .. ","
	        end
	    end		

		lab:setString(string.format(CommonText[1047], costStr))
	end

	if propCount > 0 then
		factor = 2
	    for i,v in ipairs(cost) do
	    	-- print("@^^^^^^^^^^^",UserMO.getResource(v[1], v[2]), v[1], v[2], v[3])
	        if v[3] * factor > UserMO.getResource(v[1], v[2]) then
	        	factor = 1
	        	break
	        end
	    end	
	else
		factor = 1
	end

	if factor > 1 then
		local tip = UiUtil.label("拥有:"):addTo(self:getBg()):pos(self:getBg():getContentSize().width*0.5 - 60, 150)

		local item = UiUtil.createItemView(ITEM_KIND_PROP, propId):alignTo(tip, 60)
		item:setScale(0.6)

		UiUtil.createItemDetailButton(item)

		local lbCount = UiUtil.label("*" .. UiUtil.strNumSimplify(propCount), nil, nil, nil, ui.TEXT_ALIGN_LEFT):alignTo(tip, 100)
		lbCount:setAnchorPoint(cc.p(0,0.5))

		local tips = UiUtil.label("军功足够时会自动消耗强征道具获得双份奖励."):addTo(self:getBg()):pos(self:getBg():getContentSize().width*0.5, 85)
		tips:setColor(COLOR[2])
	end

	updateLabel()

	local function doLevyHandler()
		ManagerSound.playNormalButtonSound()

	    for i,v in ipairs(cost) do
	    	-- print("@^^^^^^^^^^^",UserMO.getResource(v[1], v[2]), v[1], v[2], v[3])
	        if v[3] * factor > UserMO.getResource(v[1], v[2]) then
	        	local resData = UserMO.getResourceData(v[1], v[2])
	        	Toast.show(resData.name .. CommonText[1046])
	        	return
	        end
	    end	

	    local useProp = false
	    if factor > 1 then
	    	useProp = true
	    end		

	    AirshipBO.asynLevyAirshipProduce(function ()
	    	self:pop()
	    end, self.m_airshipId, useProp)
	end

	---取消
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local cancelBtn = MenuButton.new(normal, selected, nil, function ()
		self:pop()
	end):addTo(self:getBg())
	cancelBtn:setPosition(self:getBg():getContentSize().width * 0.25,25)
	cancelBtn:setLabel(CommonText[2])	

	---征收
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local attackBtn = MenuButton.new(normal, selected, nil, doLevyHandler):addTo(self:getBg())
	attackBtn:setPosition(self:getBg():getContentSize().width * 0.75,25)
	attackBtn:setLabel(CommonText[1])		
end

return LevyAirShipDialog
