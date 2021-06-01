--
-- Author: Xiaohang
-- Date: 2016-05-20 14:24:33
--
local Dialog = require("app.dialog.Dialog")
local CrossPlayback = class("CrossPlayback", Dialog)

function CrossPlayback:ctor(data,title)
	CrossPlayback.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 834)})
	self:size(582,834)
	self.data = data
	self.title = title
end

function CrossPlayback:onEnter()
	CrossPlayback.super.onEnter(self)
	self:setTitle(CommonText[20024])
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(552, 804))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local node = self:getBg()
	local t = self:showInfo(1):addTo(node):pos(150,node:height()-206)
	self:showInfo(2):addTo(node):pos(node:width()-t:x(),t:y())
	UiUtil.label(self.title,nil,COLOR[12]):addTo(node):pos(node:width()/2,t:y()+50)
	display.newSprite(IMAGE_COMMON.."label_vs_1.png"):addTo(node):pos(node:width()/2,t:y())

	local y,ey = node:height()-430,150
	self.rounds = PbProtocol.decodeArray(self.data.compteRound)
	for i=0,2 do
		self:createItem(i+1):addTo(node):pos(node:width()/2,y-i*ey)
	end
end

function CrossPlayback:showInfo(index)
	local info = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, 224, 274)
	local data = PbProtocol.decodeRecord(self.data["c"..index])
	if not data then return info end
	local t = UiUtil.label(data.nick):addTo(info):pos(info:width()/2,info:height()-25)
	UiUtil.label(data.serverName):addTo(info):alignTo(t, -32, 1)
	UiUtil.createItemView(ITEM_KIND_PORTRAIT, data.portrait):addTo(info):pos(info:width()/2,118):scale(0.8)
	local flag = "fail.png"
	if (self.data.win == 1 and index == 1) or (self.data.win == 0 and index == 2) then
		flag = "win.png"
	end
	display.newSprite(IMAGE_COMMON..flag)
		:addTo(info):pos(info:width()/2,35)
	return info
end

function CrossPlayback:createItem(index)
	local t = UiUtil.sprite9("info_bg_11.png",130,40,1,1,494,142)
	local l = display.newSprite(IMAGE_COMMON .. "info_bg_28.png")
		:addTo(t):pos(t:width()/2,t:height()-10)
	local data = self.rounds[index]
	UiUtil.label(string.format(CommonText[30042],index)):addTo(l):center()
	if not data then
		UiUtil.label(CommonText[30041],nil,COLOR[6]):addTo(t):center()
	else
		local s = nil
		if data.win == -1 then
			s = UiUtil.label(CommonText[30027][data.detail],20,COLOR[6]):addTo(t):center()
		else	
			s = UiUtil.button("back_normal.png", "back_selected.png", nil, handler(self, self.back))
				:addTo(t):center()
			s.key = data.reportKey
			s.detail = data.detail
		end
		local list = {"win.png","fail.png"}
		if data.win == 0 then
			list = {"fail.png","win.png"}
		elseif data.win == -1 then
			list = {"fail.png","fail.png"}
		end
		display.newSprite(IMAGE_COMMON..list[1]):addTo(t):alignTo(s,-162)
		display.newSprite(IMAGE_COMMON..list[2]):addTo(t):alignTo(s,162)
	end
	return t
end

function CrossPlayback:back(tag,sender)
	CrossBO.fightReport(sender.key,sender.detail)
end

return CrossPlayback
