--
-- Author: gongfan
-- Date: 2017-05-26 15:37:15
--
local Dialog = require("app.dialog.Dialog")
local PlayAdDialog = class("PlayAdDialog", Dialog)

function PlayAdDialog:ctor()
	PlayAdDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 400)})
end

function PlayAdDialog:onEnter()
	PlayAdDialog.super.onEnter(self)
	self:setTitle(CommonText.MuzhiAD[1][1])
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(552, 370))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	self:setOutOfBgClose(true)
	self:showUI()
end

function PlayAdDialog:showUI()
	self:getBg():setPositionY(display.cy + 50)
	

	local node = display.newNode():addTo(self:getBg())
	node:setContentSize(self:getBg():getContentSize())
	node:setAnchorPoint(cc.p(0.5, 0.5))
	node:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2)
	self.m_container = node


	for j = 1,#MuzhiADMO.LoginADAwards do
			local award = MuzhiADMO.LoginADAwards[j]
			local itemView = UiUtil.createItemView(award.type, award.id, {count = award.count}):addTo(self.m_container)
			-- itemView:setScale(0.8)
			itemView:setPosition(70 + j * 150, 250)
			UiUtil.createItemDetailButton(itemView)


			local itemNameBg = display.newSprite(IMAGE_COMMON .. 'info_bg_32.png'):addTo(self.m_container)
			itemNameBg:setPosition(itemView:getPositionX(), itemView:getPositionY() - 65)

			local itemName = ui.newTTFLabel({text = " ", font = G_FONT, 
				size = FONT_SIZE_TINY - 2}):addTo(itemNameBg)
			local propData = UserMO.getResourceData(award.type, award.id)
			itemName:setString(propData.name2 .. "*" .. award.count)
			itemName:setAnchorPoint(cc.p(0.5,0.5))
			itemName:setPosition(itemNameBg:getContentSize().width / 2, itemNameBg:getContentSize().height / 2)
			if propData.quality then
				itemName:setColor(COLOR[propData.quality])
			end
		end

	local adLab = ui.newTTFLabel({text = CommonText.MuzhiAD[1][3], font = G_FONT, size = 24, 
		x = self.m_container:getContentSize().width / 2, y = 100, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_container)
	adLab:setAnchorPoint(cc.p(0.5, 0.5))

	-- 去观看
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.playAD)):addTo(self.m_container)
	btn:setPosition(self.m_container:getContentSize().width / 2 , 30)
	btn:setLabel(CommonText.MuzhiAD[1][2])
	btn.m_label:setPositionX(btn.m_label:getPositionX() + 20)
	display.newSprite(IMAGE_COMMON.."free.png"):addTo(btn):pos(45,58)
	display.newSprite(IMAGE_COMMON.."playAD.png"):addTo(btn):pos(75,50)
end


function PlayAdDialog:playAD()
	ServiceBO.playMzAD(MZAD_TYPE_VIDEO,function()
		Loading.getInstance():show()
		MuzhiADBO.PlayLoginAD(function()
				Loading.getInstance():unshow()
				self:pop()
			end)
		end)
end



return PlayAdDialog