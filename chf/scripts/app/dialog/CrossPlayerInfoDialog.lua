-- 跨服聊天角色信息框
-- Author: Duchengchao
-- Date: 2019-05-29
--
local Dialog = require("app.dialog.Dialog")
local CrossPlayerInfoDialog = class("CrossPlayerInfoDialog", Dialog)

function CrossPlayerInfoDialog:ctor(chatinfo)
	CrossPlayerInfoDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_LEFT_TO_RIGHT, {scale9Size = cc.size(588, 500)})

	self._chatinfo = chatinfo
end

function CrossPlayerInfoDialog:onEnter()
	CrossPlayerInfoDialog.super.onEnter(self)
	-- gdump(self._chatinfo, "self._chatinfo == ")

	self:setTitle(CommonText[543])
	local sp9_btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	sp9_btm:setPreferredSize(cc.size(self:getBg():width() - 40, self:getBg():height() - 50))
	sp9_btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local sp9_tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(sp9_btm)
	sp9_tableBg:setPreferredSize(cc.size(504, 260))
  	sp9_tableBg:setPosition(sp9_btm:width()/2, sp9_btm:height() - 180)

  	--头像
	local portrait, pendant = UserBO.parsePortrait(self._chatinfo.portrait)
	local itemview = UiUtil.createItemView(ITEM_KIND_PORTRAIT, self._chatinfo.portrait, nil):addTo(sp9_tableBg)
	itemview:setScale(0.7)
	itemview:setPosition(sp9_tableBg:width() / 2 - 130, sp9_tableBg:height() - 90)

	local nameStartX = sp9_tableBg:width() / 2 - 10
	local nameStartY = sp9_tableBg:height() - 30
	--角色名
	local lb_name = ui.newTTFLabel({text = self._chatinfo.name, font = G_FONT, size = FONT_SIZE_MEDIUM, color = COLOR[12], align = ui.TEXT_ALIGN_LEFT}):addTo(sp9_tableBg, 10)
	lb_name:setAnchorPoint(cc.p(0, 0.5))
	lb_name:setPosition(nameStartX,nameStartY)
	-- --性别符号
	-- local lb_sex = UiUtil.createItemSprite(ITEM_KIND_SEX, portrait):addTo(sp9_tableBg)
	-- lb_sex:setAnchorPoint(cc.p(0, 0.5))
	-- lb_sex:setPosition(nameStartX + lb_name:getContentSize().width + 30, nameStartY)
	nameStartY = nameStartY - lb_name:getContentSize().height - 3
	--等级
	local lb_level = ui.newTTFLabel({text = CommonText.CrossPlayerInfo[1], font = G_FONT, size = FONT_SIZE_SMALL, x = nameStartX, y = nameStartY, color = COLOR[1], align = ui.TEXT_ALIGN_LEFT}):addTo(sp9_tableBg, 10)
	local level = UiUtil.label(self._chatinfo.crossPlayInfo.level, 18, COLOR[2]):addTo(sp9_tableBg):rightTo(lb_level)
	level:setAnchorPoint(cc.p(0,0.5))
	nameStartY = nameStartY - lb_level:getContentSize().height - 3
	--战力
	local lb_battleforce = ui.newTTFLabel({text = CommonText.CrossPlayerInfo[2], font = G_FONT, size = FONT_SIZE_SMALL, x = nameStartX, y = nameStartY, color = COLOR[1],
		align = ui.TEXT_ALIGN_LEFT}):addTo(sp9_tableBg, 10)
	local powerDetail = UiUtil.label(UiUtil.strNumSimplify(self._chatinfo.crossPlayInfo.fight), 18, COLOR[2]):addTo(sp9_tableBg):rightTo(lb_battleforce)
	powerDetail:setAnchorPoint(cc.p(0,0.5))
	nameStartY = nameStartY - lb_battleforce:getContentSize().height - 3
	--军团
	local lb_party = ui.newTTFLabel({text = CommonText.CrossPlayerInfo[3], font = G_FONT, size = FONT_SIZE_SMALL, x = nameStartX, y = nameStartY, color = COLOR[1],
		align = ui.TEXT_ALIGN_LEFT}):addTo(sp9_tableBg, 10)
	local partyname
	if self._chatinfo.crossPlayInfo.partyName and self._chatinfo.crossPlayInfo.partyName ~= "" then
		partyname = self._chatinfo.crossPlayInfo.partyName
	else
		partyname = CommonText[108]
	end
	local party = UiUtil.label(partyname, 18, COLOR[2]):addTo(sp9_tableBg):rightTo(lb_party)
	party:setAnchorPoint(cc.p(0,0.5))
	nameStartY = nameStartY - lb_party:getContentSize().height - 3
	--服务器
	local lb_service = ui.newTTFLabel({text = CommonText.CrossPlayerInfo[4], font = G_FONT, size = FONT_SIZE_SMALL, x = nameStartX, y = nameStartY, color = COLOR[1],
		align = ui.TEXT_ALIGN_LEFT}):addTo(sp9_tableBg, 10)
	local server = UiUtil.label(self._chatinfo.crossPlayInfo.serverName, 18, COLOR[2]):addTo(sp9_tableBg):rightTo(lb_service)
	server:setAnchorPoint(cc.p(0,0.5))

	--屏蔽回调
	local function shieldcallback(tag, sender)
		ManagerSound.playNormalButtonSound()

		local shield = ChatBO.getShield(self._chatinfo.roleId)
		if shield then
			--已屏蔽则询问是否取消屏蔽
			local ConfirmDialog = require("app.dialog.ConfirmDialog")
			ConfirmDialog.new(string.format(CommonText[405][2], shield[2]), function ()
				ChatBO.deleteShield(shield[1])
				self:pop()
			end):push()
		else
			--为屏蔽则询问是否确认屏蔽
			local ConfirmDialog = require("app.dialog.ConfirmDialog")
			ConfirmDialog.new(string.format(CommonText[405][1], self._chatinfo.name), function ()
				if ChatBO.isShieldFull() then
					--屏蔽人数已满
					Toast.show(CommonText[404][4])
				else
					ChatBO.addShield(self._chatinfo.roleId, self._chatinfo.name, self._chatinfo.portrait, self._chatinfo.crossPlayInfo.level)
				end
				self:pop()
			end):push()
		end
	end

	--屏蔽按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local shieldBtn = MenuButton.new(normal, selected, nil, shieldcallback):addTo(self:getBg(), 10)
	shieldBtn:setPosition(self:getBg():getContentSize().width / 2, 100)

	local shield = ChatBO.getShield(self._chatinfo.roleId)
	-- gdump(shield)
	if shield then
		shieldBtn:setLabel(CommonText[404][3])  -- 取消屏蔽
	else
		shieldBtn:setLabel(CommonText[404][2])  -- 屏蔽
	end
end

return CrossPlayerInfoDialog