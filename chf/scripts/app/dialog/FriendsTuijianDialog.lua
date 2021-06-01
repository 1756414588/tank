--
-- Author: gf
-- Date: 2016-01-19 09:56:10
-- 好友推荐


local Dialog = require("app.dialog.Dialog")
local FriendsTuijianDialog = class("FriendsTuijianDialog", Dialog)

function FriendsTuijianDialog:ctor(mans)
	FriendsTuijianDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(590, 460)})

	self.mans = mans
end

function FriendsTuijianDialog:onEnter()
	FriendsTuijianDialog.super.onEnter(self)
	self:setTitle(CommonText[857])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(560, 370))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	
	local m_lords = {}

	local posConfig = {
		{x = 80, y = 290},
		{x = 210, y = 290},
		{x = 340, y = 290},
		{x = 470, y = 290},
		{x = 80, y = 130},
		{x = 210, y = 130},
		{x = 340, y = 130},
		{x = 470, y = 130}
	}

	gdump(self.mans,"self.mans")
	local friendNum
	if #self.mans > 8 then
		friendNum = 8
	else
		friendNum = #self.mans
	end
	for index=1,friendNum do
		local man = self.mans[index]

		local itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, man.icon):addTo(btm)
		itemView:setScale(0.65)
		itemView:setPosition(posConfig[index].x,posConfig[index].y)

		local name = ui.newTTFLabel({text = man.nick, font = G_FONT, size = FONT_SIZE_SMALL, x = posConfig[index].x, y = posConfig[index].y - 80, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
		name:setAnchorPoint(cc.p(0.5, 0.5))

		m_lords[#m_lords + 1] = man.lordId
	end

	self.m_lords = m_lords

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local goBtn = MenuButton.new(normal, selected, nil, handler(self,self.goHandler)):addTo(self:getBg())
	goBtn:setPosition(self:getBg():getContentSize().width / 2,30)
	goBtn:setLabel(CommonText[858])

end

function FriendsTuijianDialog:goHandler()
	ManagerSound.playNormalButtonSound()
	if #SocialityMO.myFriends_ >= SocialityMO.friendMax then
		Toast.show(CommonText[710])
		return
	end
	gdump(self.m_lords,"self.m_lords")
	Loading.getInstance():show()
	TriggerGuideBO.asynAddTipFriends(function()
		Loading.getInstance():unshow()
		Toast.show(CommonText[859])
		self:pop()
		end,self.m_lords)
end


function FriendsTuijianDialog:onExit()
	FriendsTuijianDialog.super.onExit(self)
end

return FriendsTuijianDialog
