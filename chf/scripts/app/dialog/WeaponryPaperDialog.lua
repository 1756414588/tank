--
-- Author: xiaoxing
-- Date: 2016-12-21 18:53:31
--

local Dialog = require("app.dialog.Dialog")
local WeaponryPaperDialog = class("WeaponryPaperDialog", Dialog)

function WeaponryPaperDialog:ctor(data)
	WeaponryPaperDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 340)})
	self.data = data
end

function WeaponryPaperDialog:onEnter()
	WeaponryPaperDialog.super.onEnter(self)
	
	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	self:setTitle(CommonText[1720]) -- 查看勋章

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(506, 200))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 85 - infoBg:getContentSize().height / 2)
	local data = WeaponryMO.queryById(self.data)
	--self.data = data
	local itemView = UiUtil.createItemView(ITEM_KIND_WEAPONRY_PAPER,self.data,{data = self.data}):addTo(infoBg)
	itemView:setPosition(70, infoBg:getContentSize().height / 2 + 8)
	UiUtil.createItemDetailButton(itemView)


	local md = WeaponryMO.queryPaperById(self.data)
	local t = UiUtil.label(md.name,nil,COLOR[md.quality])
		:addTo(self:getBg()):align(display.LEFT_CENTER, 200, 205)
	--t = UiUtil.label(CommonText[20164][1]):alignTo(t, -25, 1)
	--UiUtil.label(CommonText[1601][math.floor(md.id/1000)],nil,COLOR[2]):rightTo(t)

	local count = WeaponryBO.Weaponryprop[self.data].count

	t = UiUtil.label(CommonText[95] .."："):alignTo(t, -25, 1)
	UiUtil.label(count,nil,COLOR[2]):rightTo(t)
	
	local desc = ui.newTTFLabel({text = md.desc, font = G_FONT, size = FONT_SIZE_SMALL,
		align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,dimensions = cc.size(350, 80)}):alignTo(t, -50, 1)

end


function WeaponryPaperDialog:resolveBtn(tag, sender)
	ManagerSound.playNormalButtonSound()
	self:pop(function()
		local PartExplodeDialog = require("app.dialog.PartExplodeDialog")
		PartExplodeDialog.new({self.data.keyId},nil,"weaponry"):push()
	end)
end

function WeaponryPaperDialog:unloadBtn(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.data.pos == 0 then
		WeaponryBO.PutonLordEquip(self.data.keyId,function()
			self:pop()
		end)
	else
		WeaponryBO.TakeOffEquip(self.data.pos,function()
			self:pop()
		end)
	end

end

function WeaponryPaperDialog:shareCallback(tag,sender)
	ManagerSound.playNormalButtonSound()
	local item = {}
	item.medalId = self.data.medalId
	item.upLv = self.data.upLv
	item.refitLv = self.data.refitLv
	local dialog = require("app.dialog.ShareDialog").new(SHARE_TYPE_MEDAL,item,sender):push()
	dialog:getBg():setPosition(display.cx + 150, display.cy + 150)
end

function WeaponryPaperDialog:onExit()

end

return WeaponryPaperDialog