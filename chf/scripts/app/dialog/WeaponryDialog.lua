--
-- Author: xiaoxing
-- Date: 2016-12-21 18:53:31
--
-- 查看军备界面

local Dialog = require("app.dialog.Dialog")
local WeaponryDialog = class("WeaponryDialog", Dialog)

function WeaponryDialog:ctor(data, preview)
	self.isOpenChange = false
	self.tDialogHeight = 400
	self.tSkinHeight = 200
	self.previewDexHeight = 0
	if UserMO.queryFuncOpen(UFP_WEAP_CHANGE) then self.isOpenChange = true end
	if self.isOpenChange then
		self.tDialogHeight = 530
		self.tSkinHeight = 330
	end
	self.data = data
	self.preview = preview or false
	if self.preview then self.previewDexHeight = 85 end
	WeaponryDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, self.tDialogHeight - self.previewDexHeight)})
	
	-- dump(data,"查看军备界面")
end

function WeaponryDialog:onEnter()
	WeaponryDialog.super.onEnter(self)
	
	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	self:setTitle(CommonText[1605][3]) -- 查看军备

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(506, self.tSkinHeight))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 65 - infoBg:getContentSize().height / 2)


	-- 显示强度
	local attrs = WeaponryBO.getPartAttrShow(self.data.keyId,self.data)
	--强度
	local strengthLabel = display.newSprite(IMAGE_COMMON .. "Label_weaponry.png"):addTo(infoBg)
	strengthLabel:setAnchorPoint(cc.p(0,0.5))
	strengthLabel:setPosition(30,infoBg:getContentSize().height - strengthLabel:getContentSize().height )
		-- :align(display.LEFT_CENTER, 60, 355)
	local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(attrs), font = "fnt/num_2.fnt"}):rightTo(strengthLabel, 15)

	-- item
	local itemView = UiUtil.createItemView(ITEM_KIND_WEAPONRY_ICON,self.data.equip_id):addTo(infoBg)
	itemView:setAnchorPoint(0,0.5)
	itemView:setPosition(30, strengthLabel:getPositionY() - strengthLabel:getContentSize().height *0.5 - itemView:getContentSize().height *0.5 - 10)
	-- UiUtil.createItemDetailButton(itemView)

	local lockIcon = display.newSprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(itemView)
	lockIcon:setScale(0.5)
	lockIcon:setPosition(itemView:getContentSize().width - lockIcon:getContentSize().width / 2 * 0.5, itemView:getContentSize().height - lockIcon:getContentSize().height / 2 * 0.5)
	lockIcon:setVisible(self.data.isLock)
	self.m_lockIcon = lockIcon

	-- 名字和 品质
	local md = UserMO.getResourceData(ITEM_KIND_WEAPONRY_ICON, self.data.equip_id)
	local t = UiUtil.label(md.name,FONT_SIZE_MEDIUM,COLOR[md.quality]):addTo(infoBg)--:align(display.LEFT_CENTER, 180, 325)
	t:setAnchorPoint(cc.p(0,0.5))
	t:setPosition(itemView:getPositionX() + itemView:getContentSize().width + 30,itemView:getPositionY() + itemView:getContentSize().height *0.5 - t:getContentSize().height * 0.5)

	--锁定/解锁按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local lockBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onLockCallback)):addTo(infoBg)
	lockBtn:setPosition(infoBg:getContentSize().width - 80,infoBg:getContentSize().height - 80 )
	self.m_lockBtn = lockBtn
	if self.data.isLock then
		lockBtn:setLabel(CommonText[902][2]) 
	else
		lockBtn:setLabel(CommonText[902][1])
	end

	t = UiUtil.label(CommonText[20164][1]):alignTo(t, -35, 1)
	UiUtil.label(CommonText[1601][md.pos],nil,COLOR[2]):rightTo(t)

	-- 装备数据
	local equipdata = WeaponryMO.queryById(self.data.equip_id)

	--属性
	local temp = WeaponryBO.getPartAttrData(self.data.keyId,self.data)
	local attNum = #temp
	if attNum > 0 then
		for index = 1 , attNum do
			local attdata = temp[index]
			t = UiUtil.label(attdata.name .."："):alignTo(t, -25, 1)
			UiUtil.label(attdata.strValue,nil,COLOR[2]):rightTo(t)
		end
	else
		t = UiUtil.label(CommonText[1040] .."："):alignTo(t, -25, 1)
			UiUtil.label(equipdata.tankCount,nil,COLOR[2]):rightTo(t)
	end
	

	if self.isOpenChange then
		-- 洗练属性
		local tip = UiUtil.label(CommonText[1042],FONT_SIZE_MEDIUM):addTo(infoBg)
		tip:setAnchorPoint(cc.p(0,1))
		tip:setPosition(30 ,itemView:getPositionY() - itemView:getContentSize().height * 0.5 - 20)

		-- 洗练技能列表
		local skills = PbProtocol.decodeArray(self.data.skillLv) --table.isexist(self.data , "skillLv") and PbProtocol.decodeArray(self.data.skillLv) or {}
		if table.isexist(self.data , "skillLvSecond") and self.data.lordEquipSaveType == 1 then
			skills = PbProtocol.decodeArray(self.data.skillLvSecond)
		end
		local loopnumber = math.max(#skills,equipdata.normalBox)
		local skillX = 30
		for index = 1 , loopnumber do
			local skill = skills[index]
			if not skill then
				skill = {v1 = 0}
			end
			-- 技能itme
			local scale = 0.9
			local skillUI = UiUtil.createItemView(ITEM_KIND_WEAPONRY_SKILL,skill.v1,{super = index}):addTo(infoBg)
			skillUI:setScale(scale)
			skillUI:setAnchorPoint(cc.p(1,1))
			skillUI:setPosition( skillX + skillUI:getContentSize().width * scale, tip:getPositionY() - tip:getContentSize().height - 20)
			skillX = skillX + skillUI:getContentSize().width * 1.4 * scale

			if skill.v1 ~= 0 then
				local bg = display.newSprite(IMAGE_COMMON .. "info_bg_32.png"):addTo(skillUI)
				bg:setScaleX(0.8)
				bg:setPosition(skillUI:getContentSize().width * 0.5 , bg:getContentSize().height * 0.5)

				local lbdata = WeaponryMO.queryChangeSkillById(skill.v1)
				--技能信息 名字 等级
				local lv = lbdata.level >= equipdata.maxSkillLevel and "Max" or lbdata.level
				local lb = UiUtil.label(" Lv." .. lv,FONT_SIZE_SMALL,COLOR[1]):addTo(skillUI)
				lb:setPosition(skillUI:getContentSize().width * 0.5 , bg:getContentSize().height * 0.5)

				--简讯
				local anchrpoint = 0
				if index == 4 then anchrpoint = 1 end
				self:showTips(skillUI,skill,equipdata.maxSkillLevel,anchrpoint)
			end
		end
	end

	


	-- 分解
	local resolvebtn = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", "btn_9_disabled.png", handler(self, self.resolveBtn), CommonText[515][2]):addTo(self:getBg()):pos(self:getBg():width()*0.2,90)
	if self.data.pos ~= 0 or self.data.isLock then
		resolvebtn:setEnabled(false)
	end
	self.m_resolvebtn = resolvebtn

	-- 装备和卸下
	local takebtn = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", nil, handler(self, self.unloadBtn), CommonText[137]):addTo(self:getBg()):pos(self:getBg():width()*0.5,90)
	if self.data.pos ~= 0 then
		takebtn:setLabel(CommonText[172])
	end

	local changebtn = nil
	if self.isOpenChange then
		-- 洗练
		changebtn = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", "btn_9_disabled.png", handler(self, self.doChange), CommonText[1603][2]):addTo(self:getBg()):pos(self:getBg():width()*0.8,90)
		self.m_changebtn = changebtn
		self.m_changebtn:setEnabled(not self.data.isLock)
	else
		takebtn:setPosition(self:getBg():width()*0.8,90)
	end

	if self.preview then
		resolvebtn:setVisible(false)
		takebtn:setVisible(false)
		if changebtn then changebtn:setVisible(false) end
	end
end

-- 分解装备
function WeaponryDialog:resolveBtn(tag, sender)
	ManagerSound.playNormalButtonSound()
	self:pop(function()
		local PartExplodeDialog = require("app.dialog.PartExplodeDialog")
		PartExplodeDialog.new({self.data.keyId},nil,"weaponry"):push()
	end)
end

-- 穿上 或 脱下装备
function WeaponryDialog:unloadBtn(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.data.pos == 0 then
		--如果等级不足，弹框
		if UserMO.level_ <  WeaponryMO.queryById(self.data.equip_id).level then
			Toast.show(CommonText[1725])
			return
		end
		WeaponryBO.PutonLordEquip(self.data.keyId,function()
			Toast.show(CommonText[1727])
			self:pop()
		end)
	else
		WeaponryBO.TakeOffEquip(self.data.pos,function()
			Toast.show(CommonText[1728])
			self:pop()
		end)
	end

end

-- 洗练
function WeaponryDialog:doChange(tag, sender)
	ManagerSound.playNormalButtonSound()
	UiDirector.popMakeUiTop("HomeView")

	local equiped = self.data.pos > 0 and 1 or 2
	local pointParam = {keyId = self.data.keyId, equiped = equiped}
	require("app.view.WeaponryView").new(1,2,pointParam):push()
end

-- 分享
-- function WeaponryDialog:shareCallback(tag,sender)
-- 	ManagerSound.playNormalButtonSound()
-- 	local item = {}
-- 	item.medalId = self.data.medalId
-- 	item.upLv = self.data.upLv
-- 	item.refitLv = self.data.refitLv
-- 	local dialog = require("app.dialog.ShareDialog").new(SHARE_TYPE_MEDAL,item,sender):push()
-- 	dialog:getBg():setPosition(display.cx + 150, display.cy + 150)
-- end

function WeaponryDialog:showTips(node,data,max,anchor)
	anchor = anchor or 0
	node:setTouchEnabled(true)
	node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			local db = WeaponryMO.queryChangeSkillById(data.v1)
			-- 背景框
			local bg = display.newSprite(IMAGE_COMMON .. "tipbg.png"):addTo(node) 
			bg:setAnchorPoint(cc.p(anchor,0))
			bg:setPosition(0 + node:getContentSize().width * anchor,node:getContentSize().height * 1.1)
			-- 名字
			local name = UiUtil.label(db.name,FONT_SIZE_MEDIUM,COLOR[1]):addTo(bg)
			name:setAnchorPoint(0,0)
			name:setPosition(30,bg:getContentSize().height * 0.5 + 5)
			-- lv
			local lv = UiUtil.label("Lv." .. db.level,FONT_SIZE_MEDIUM,COLOR[1]):addTo(bg)
			lv:setAnchorPoint(0,0)
			lv:setPosition(name:getPositionX() + name:getContentSize().width + 10,bg:getContentSize().height * 0.5 + 5)
			-- star
			local starStr = db.level >= max and "estar.png" or "estar_bg.png"
			local star = display.newSprite(IMAGE_COMMON .. starStr):addTo(bg)
			star:setAnchorPoint(0,0.5)
			star:setPosition(lv:getPositionX() + lv:getContentSize().width + 20,bg:getContentSize().height * 0.5 + name:getContentSize().height * 0.5 + 5)
			--desc
			local desc = UiUtil.label(db.desc,FONT_SIZE_MEDIUM,COLOR[1]):addTo(bg)
			desc:setAnchorPoint(0,1)
			desc:setPosition(30,bg:getContentSize().height * 0.5 - 5)

			node.tipNode_ = bg
			return true
		elseif event.name == "ended" then
			node.tipNode_:removeSelf()
		end
	end)
end

function WeaponryDialog:onLockCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local function doneLock(data)
		Loading.getInstance():unshow()
		Toast.show(data.lordEquip.isLock and CommonText[1615][1] or CommonText[1615][2])
		self.m_lockIcon:setVisible(data.lordEquip.isLock)
		if data.lordEquip.isLock then
			self.m_lockBtn:setLabel(CommonText[902][2])
			if self.m_changebtn then --洗练
				self.m_changebtn:setEnabled(false)
			end
			self.m_resolvebtn:setEnabled(false) --分解
		else
			self.m_lockBtn:setLabel(CommonText[902][1])
			if data.lordEquip.pos <= 0 then
				self.m_resolvebtn:setEnabled(true)
			else
				self.m_resolvebtn:setEnabled(false)
			end
			if self.m_changebtn then
				self.m_changebtn:setEnabled(true)
			end
		end
	end

	Loading.getInstance():show()
	WeaponryBO.asynLockWeapon(doneLock, self.data)
end

function WeaponryDialog:onExit()
	WeaponryDialog.super.onExit(self)
end

return WeaponryDialog