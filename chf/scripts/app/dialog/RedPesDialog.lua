--
-- Author: Gss
-- Date: 2018-07-09 18:59:53
--
-- 单个玩家发红包弹框

local Dialog = require("app.dialog.Dialog")
local RedPesDialog = class("RedPesDialog", Dialog)

function RedPesDialog:ctor(sender,friend,index)
	self.data = UserMO.getAllRedPes()
	RedPesDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE,{scale9Size = cc.size(220, 170 + #self.data * 50),alpha = 0})
	self.sender = sender
	self.m_name = friend.nick
	self.m_index = index
	self.m_friend = friend
end

function RedPesDialog:onEnter()
	RedPesDialog.super.onEnter(self)
		
	self:setOutOfBgClose(true)
	self:getBg():setAnchorPoint(cc.p(0.5,0))
	local fromPos = self:convertToNodeSpace(cc.p(self.sender.x, self.sender.y))
	self:getBg():setPosition(fromPos.x,fromPos.y + 20)
	if self.m_index == 1 then
		self:getBg():setPosition(fromPos.x,fromPos.y - 350)
	end

	local desc = UiUtil.label(CommonText[1818]):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0,0.5))
	desc:setPosition(30,self:getBg():height() - 40)

	for index=1,#self.data do
		local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
		local redBtn = MenuButton.new(normal, selected, nil, handler(self, self.redHandler)):addTo(self:getBg())
		redBtn:setPosition(self:getBg():width() / 2, 70 + (index - 1)* 70)
		redBtn.propId = self.data[index].propId

		local resData = UserMO.getResourceData(ITEM_KIND_PROP,self.data[index].propId)
		redBtn:setLabel(resData.name.." * 1",{size = 16})
	end
end

function RedPesDialog:redHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	local propId = sender.propId
	local value = PropMO.getAddValueByRedId(propId)
	local propname = UserMO.getResourceData(ITEM_KIND_PROP,propId).name

    local function doneUseProp()
	    Loading.getInstance():unshow()
	    local isfull = SocialityMO.isFriendLessMax(self.m_friend.lordId)
	    local isFriend = SocialityBO.isOtherFriend(self.m_friend.lordId)
	    if isfull or (not isFriend) then
	    	Toast.show(CommonText[84]..propname)
	    else
	    	Toast.show(string.format(CommonText[1848][1], propname, value))
	    end
	    Loading.getInstance():show()
	    SocialityBO.getFriend(function()
	    	Loading.getInstance():unshow()
	    	end)
    	self:pop()
    end

    Loading.getInstance():show()
    PropBO.asynUseProp(doneUseProp, propId, 1, self.m_name)
end

return RedPesDialog