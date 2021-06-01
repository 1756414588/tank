--
-- Author: Xiaohang
-- Date: 2016-05-20 10:33:13
--
local Dialog = require("app.dialog.Dialog")
local CrossPlayer = class("CrossPlayer", Dialog)

-- tankId: 需要改装的tank
function CrossPlayer:ctor(data)
	CrossPlayer.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(460, 400)})
	self.data = data
	self:size(460,400)
end

function CrossPlayer:onEnter()
	CrossPlayer.super.onEnter(self)
	self:setTitle(CommonText[543])
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(430, 370))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local t = UiUtil.sprite9("info_bg_15.png", 30, 30, 1, 1, 370, 220)
		:addTo(self:getBg()):pos(self:getBg():width()/2,215)
	UiUtil.createItemView(ITEM_KIND_PORTRAIT, self.data.portrait):addTo(t):pos(80,t:height()/2):scale(0.7)
	local l = UiUtil.label(CommonText[30018][1],nil,cc.c3b(200,200,200)):addTo(t):align(display.LEFT_CENTER, 160, t:height()-45)
	UiUtil.label(self.data.nick,nil,COLOR[12]):addTo(t):rightTo(l)
	l = UiUtil.label(CommonText[567][2],nil,cc.c3b(200,200,200)):addTo(t):alignTo(l, -32, 1)
	UiUtil.label(self.data.level,nil,COLOR[12]):addTo(t):rightTo(l)
	l = UiUtil.label(CommonText[642][5],nil,cc.c3b(200,200,200)):addTo(t):alignTo(l, -32, 1)
	UiUtil.label(UiUtil.strNumSimplify(self.data.fight),nil,COLOR[12]):addTo(t):rightTo(l)
	l = UiUtil.label(CommonText[30018][2],nil,cc.c3b(200,200,200)):addTo(t):alignTo(l, -32, 1)
	UiUtil.label(self.data.partyName,nil,COLOR[12]):addTo(t):rightTo(l)
	l = UiUtil.label(CommonText[30018][3],nil,cc.c3b(200,200,200)):addTo(t):alignTo(l, -32, 1)
	UiUtil.label(self.data.serverName,nil,COLOR[12]):addTo(t):rightTo(l)

	UiUtil.button("btn_9_normal.png", "btn_9_selected.png", nil, handler(self, self.close), CommonText[1])
		:addTo(self:getBg()):pos(self:getBg():width()/2,70)
end

function CrossPlayer:close()
	self:pop()
end

function CrossPlayer:onExit()
	CrossPlayer.super.onExit(self)
end

return CrossPlayer