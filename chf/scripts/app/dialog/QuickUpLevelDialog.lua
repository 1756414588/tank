--
-- Author: xiaoxing
-- Date: 2017-03-22 15:37:15
--
local Dialog = require("app.dialog.Dialog")
local QuickUpLevelDialog = class("QuickUpLevelDialog", Dialog)

function QuickUpLevelDialog:ctor(_canGet)
	QuickUpLevelDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 590)})
	--self.day = _day
	self.get = _canGet
end

function QuickUpLevelDialog:onEnter()
	QuickUpLevelDialog.super.onEnter(self)
	self:setTitle(CommonText.WeekActivity[1][4])
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(552, 560))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	self:setOutOfBgClose(true)
	self:showUI()
end

function QuickUpLevelDialog:showUI()
	self:getBg():setPositionY(display.cy + 50)
	local titBg = display.newSprite(IMAGE_COMMON .. "fight_up.jpg"):addTo(self:getBg(),2)
	titBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 222)


	local node = display.newNode():addTo(self:getBg())
	node:setContentSize(self:getBg():getContentSize())
	node:setAnchorPoint(cc.p(0.5, 0.5))
	node:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2)
	self.m_container = node

	UiUtil.label(CommonText.WeekActivity[1][5],24):addTo(self:getBg()):align(display.LEFT_CENTER, 50, 200)
	local titLab = ui.newTTFLabel({text = (self.get == false and CommonText[20213][1] or CommonText[20213][2]), font = G_FONT, size = 24, dimensions = cc.size(440, 0),
		x = 100, y = 180, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT}):addTo(self:getBg())
	titLab:setAnchorPoint(cc.p(0.5, 1))
	self.m_titleLabel = titLab

	-- local bg = display.newSprite(IMAGE_COMMON .. "info_bg_5.png"):addTo(self:getBg())
	-- bg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 10)

	-- local name = ui.newTTFLabel({text = CommonText[487][1], font = G_FONT, size = FONT_SIZE_SMALL, x = bg:getContentSize().width / 2, y = bg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)

	-- local desc = ui.newTTFLabel({text = CommonText[487][2], font = G_FONT, size = FONT_SIZE_SMALL, x = self:getBg():getContentSize().width / 2, y = self:getBg():getContentSize().height - 45, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(237, 169, 6)}):addTo(self:getBg())
	self:updateBtn()
end

function QuickUpLevelDialog:updateBtn()
	if self.get == false then
		if ServiceBO.muzhiAdPlat() and UserMO.vip_ == 0 and MuzhiADMO.Day7ActLvUpADStatus == 0 then
			-- 获取权限
			local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
			local btn = MenuButton.new(normal, selected, nil, handler(self, self.playAD)):addTo(self.m_container)
			btn:setPosition(self.m_container:getContentSize().width / 2 , 30)
			btn:setLabel(CommonText.MuzhiAD[1][2])
			btn.m_label:setPositionX(btn.m_label:getPositionX() + 20)
			display.newSprite(IMAGE_COMMON.."free.png"):addTo(btn):pos(45,58)
			display.newSprite(IMAGE_COMMON.."playAD.png"):addTo(btn):pos(75,50)

			local adLab = ui.newTTFLabel({text = CommonText.MuzhiAD[2][2], font = G_FONT, size = 24, 
				x = self.m_container:getContentSize().width / 2, y = 90, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_container)
			adLab:setAnchorPoint(cc.p(0.5, 0.5))

		else
			-- 我想发展
			local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
			local btn = MenuButton.new(normal, selected, nil, handler(self, self.showSecondaryUi)):addTo(self.m_container)
			btn:setPosition(self.m_container:getContentSize().width / 2 - 120 , 30)
			btn:setLabel(CommonText[81])
			btn.index = 1

			-- 我要变强
			local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
			local btn = MenuButton.new(normal, selected, nil, handler(self, self.showSecondaryUi)):addTo(self.m_container)
			btn:setPosition(self.m_container:getContentSize().width / 2 + 120, 30)
			btn:setLabel(CommonText[20213][3])
			btn.index = 2
		end
	else
		-- 我很无聊
		local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
		local btn = MenuButton.new(normal, selected, nil, handler(self, self.showSecondaryUi)):addTo(self.m_container)
		btn:setPosition(self.m_container:getContentSize().width / 2 ,30)
		btn:setLabel(CommonText[1])
		btn.index = 3
	end
end


function QuickUpLevelDialog:playAD()
	ServiceBO.playMzAD(MZAD_TYPE_VIDEO,function()
			Loading.getInstance():show()
			MuzhiADBO.PlayDay7ActLvUpAD(function()
					Loading.getInstance():unshow()
					self.m_container:removeAllChildren()
					self:updateBtn()
				end)
		end)
end

function QuickUpLevelDialog:showSecondaryUi(tag, sender)
	local index = sender.index
	--local secondaryIndex = sender.secondaryIndex


	if index == 1 then  -- 立即升级
		ActivityWeekBO.asynDay7ActLvUp(function(success)
				self:pop()
			end)
	elseif index == 2 then  -- 稍后再来
		self:pop()
	elseif index == 3 then  -- 我很无聊
		self:pop()
	end

end

return QuickUpLevelDialog