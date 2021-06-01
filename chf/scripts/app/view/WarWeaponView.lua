--
--
--
--

local WarWeaponView = class("WarWeaponView", UiNode)

function WarWeaponView:ctor()
	WarWeaponView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
end

function WarWeaponView:onEnter()
	WarWeaponView.super.onEnter(self)

	armature_add(IMAGE_ANIMATION .. "effect/mmwq_di.pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_di.plist", IMAGE_ANIMATION .. "effect/mmwq_di.xml")
	armature_add(IMAGE_ANIMATION .. "effect/mmwq_jiesuojineng.pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_jiesuojineng.plist", IMAGE_ANIMATION .. "effect/mmwq_jiesuojineng.xml")
	armature_add(IMAGE_ANIMATION .. "effect/mmwq_jinengshuaxin.pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_jinengshuaxin.plist", IMAGE_ANIMATION .. "effect/mmwq_jinengshuaxin.xml")
	armature_add(IMAGE_ANIMATION .. "effect/mmwq_saoguang.pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_saoguang.plist", IMAGE_ANIMATION .. "effect/mmwq_saoguang.xml")
	armature_add(IMAGE_ANIMATION .. "effect/mmwq_left_s_w_101.pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_left_s_w_101.plist", IMAGE_ANIMATION .. "effect/mmwq_left_s_w_101.xml")
	armature_add(IMAGE_ANIMATION .. "effect/mmwq_left_s_w_102.pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_left_s_w_102.plist", IMAGE_ANIMATION .. "effect/mmwq_left_s_w_102.xml")
	armature_add(IMAGE_ANIMATION .. "effect/mmwq_left_s_w_103.pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_left_s_w_103.plist", IMAGE_ANIMATION .. "effect/mmwq_left_s_w_103.xml")
	armature_add(IMAGE_ANIMATION .. "effect/mmwq_right_s_w_101.pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_right_s_w_101.plist", IMAGE_ANIMATION .. "effect/mmwq_right_s_w_101.xml")
	armature_add(IMAGE_ANIMATION .. "effect/mmwq_right_s_w_102.pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_right_s_w_102.plist", IMAGE_ANIMATION .. "effect/mmwq_right_s_w_102.xml")
	armature_add(IMAGE_ANIMATION .. "effect/mmwq_right_s_w_103.pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_right_s_w_103.plist", IMAGE_ANIMATION .. "effect/mmwq_right_s_w_103.xml")

	-- 部队
	self:setTitle(CommonText[1115][1])

	self:hasCoinButton(true)

	-- top
	local topbg = display.newSprite(IMAGE_COMMON .. "info_bg_107.png"):addTo(self:getBg())
	topbg:setAnchorPoint(cc.p(0.5,1))
	topbg:setPosition(self:getBg():width() * 0.5, self:getBg():height() - 93)
	self.topbg = topbg

	-- 武器框
	local weaponIconBg = display.newSprite(IMAGE_COMMON .. "info_bg_106.png"):addTo(topbg, 5)
	weaponIconBg:setAnchorPoint(cc.p(0,0.5))
	weaponIconBg:setPosition( 10 , topbg:height() * 0.5)
	self.weaponIconBg = weaponIconBg

	local ami_di = armature_create("mmwq_di"):addTo(topbg, 4)
	ami_di:setPosition(topbg:width() * 0.65, topbg:height() * 0.5)
	ami_di:getAnimation():playWithIndex(0)

	local ami_saoguang = armature_create("mmwq_saoguang"):addTo(topbg, 10)
	ami_saoguang:setPosition(topbg:width() * 0.6, topbg:height() * 0.5)
	ami_saoguang:getAnimation():playWithIndex(0)

	-- 线
	local lineBg = display.newSprite(IMAGE_COMMON .. "line3.png"):addTo(self:getBg(), 3)
	lineBg:setPosition(self:getBg():width() * 0.5 , self.topbg:y() - self.topbg:height())
	self.lineBg = lineBg

	-- 名字框
	local namebg = display.newSprite(IMAGE_COMMON .. "info_bg_105.png"):addTo(self:getBg(), 3)
	namebg:setPosition(self:getBg():width() * 0.5 , lineBg:y() - namebg:height())
	self.namebg = namebg

	-- center
	local weaponAttrNode = display.newNode():addTo(self:getBg())
	weaponAttrNode:setAnchorPoint(cc.p(0,0))
	weaponAttrNode:setPosition(0,0)
	self.m_weaponAttrNode = weaponAttrNode

	-- 
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local upBtn = MenuButton.new(normal,selected,disabled,handler(self,self.levelUpSkillCallback)):addTo(self:getBg())
	upBtn:setPosition(self:getBg():getContentSize().width * 0.5, upBtn:height() + 5)
	self.upBtn = upBtn

	local coin_lb1 = ui.newTTFLabel({text = CommonText[1115][3] , font = G_FONT, color = cc.c3b(255, 255, 255), size = FONT_SIZE_TINY}):addTo(self:getBg())
	coin_lb1:setPosition(upBtn:x() , upBtn:y())
	self.upBtn.coin_lb1 = coin_lb1

	-- 
	local sp_coin = UiUtil.createItemSprite(ITEM_KIND_COIN,1):addTo(self:getBg())
	sp_coin:setPosition(upBtn:x() - 15, upBtn:y() - upBtn:height() * 0.5 - 7.5)
	self.upBtn.sp_coin = sp_coin

	local sp_coin_number = ui.newBMFontLabel({text = "0000", font = "fnt/num_8.fnt", align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	sp_coin_number:setAnchorPoint(cc.p(0, 0.5))
	sp_coin_number:setPosition(sp_coin:x() + sp_coin:width() * 0.5 ,sp_coin:y())
	sp_coin_number:setScale(0.75)
	self.upBtn.sp_coin_number = sp_coin_number



	local function tohelpFun()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.WarWeaponHelper):push()
	end
	-- 帮助
	local tohelpBtn = UiUtil.button("btn_detail_normal2.png", "btn_detail_selected2.png", nil,tohelpFun):addTo(self:getBg())
	tohelpBtn:setAnchorPoint(cc.p(1,1))
	tohelpBtn:setPosition(self:getBg():width() - 15 , topbg:y() - topbg:height() - 15)

	-- 锁定状态
	self.lockOpacityValue = 0
	self.lockOpacityValueAdd = 1
	self.lockItemList = {}

	-- 描述列表
	self.skillDescList = {}

	self.isTouch = true
	self.isAmiRunningList = {}

	self.WeaponData = WarWeaponBO.weaponDataList
	
	local weaponIndex = #self.WeaponData > 0 and 1 or 0
	self:updateWeaponView(weaponIndex)

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) self:onEnterFrame(dt) end)
    self:scheduleUpdate_()
end

function WarWeaponView:onExit()
	WarWeaponView.super.onExit(self)
	armature_remove(IMAGE_ANIMATION .. "effect/mmwq_di.pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_di.plist", IMAGE_ANIMATION .. "effect/mmwq_di.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/mmwq_jiesuojineng.pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_jiesuojineng.plist", IMAGE_ANIMATION .. "effect/mmwq_jiesuojineng.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/mmwq_jinengshuaxin.pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_jinengshuaxin.plist", IMAGE_ANIMATION .. "effect/mmwq_jinengshuaxin.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/mmwq_saoguang.pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_saoguang.plist", IMAGE_ANIMATION .. "effect/mmwq_saoguang.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/mmwq_left_s_w_101.pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_left_s_w_101.plist", IMAGE_ANIMATION .. "effect/mmwq_left_s_w_101.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/mmwq_left_s_w_102.pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_left_s_w_102.plist", IMAGE_ANIMATION .. "effect/mmwq_left_s_w_102.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/mmwq_left_s_w_103.pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_left_s_w_103.plist", IMAGE_ANIMATION .. "effect/mmwq_left_s_w_103.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/mmwq_right_s_w_101.pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_right_s_w_101.plist", IMAGE_ANIMATION .. "effect/mmwq_right_s_w_101.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/mmwq_right_s_w_102.pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_right_s_w_102.plist", IMAGE_ANIMATION .. "effect/mmwq_right_s_w_102.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/mmwq_right_s_w_103.pvr.ccz", IMAGE_ANIMATION .. "effect/mmwq_right_s_w_103.plist", IMAGE_ANIMATION .. "effect/mmwq_right_s_w_103.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/ryxz_dianji.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_dianji.plist", IMAGE_ANIMATION .. "effect/ryxz_dianji.xml")

end


function WarWeaponView:onEnterFrame(ft)
	self.lockOpacityValue = self.lockOpacityValue + self.lockOpacityValueAdd

	if self.lockOpacityValue >= 250 then
		self.lockOpacityValueAdd = -1
	end

	if self.lockOpacityValue <= 50 then
		self.lockOpacityValueAdd = 1
	end 

	for k , v in pairs(self.lockItemList) do
		if v then
			v:setOpacity(self.lockOpacityValue)
		end
	end

	for k, v in pairs(self.isAmiRunningList) do
		if v then
			self.isTouch = false
			return
		end
	end

	self.isTouch = true
end



-- 刷新 武器图标
function WarWeaponView:updateWeaponView(weaponIndex)
	if weaponIndex <= 0 then return end 
	-- weaponIndex 1 2 3
	
	local weapon = self.WeaponData[weaponIndex]
	local weaponInfo = WarWeaponMO.queryWeaponById(weapon.id)


	if self.ami_left then
		self.ami_left:removeSelf()
		self.ami_left = nil
	end
	self.ami_left = armature_create("mmwq_left_" .. weaponInfo.icon):addTo(self.weaponIconBg)
	self.ami_left:setPosition(self.weaponIconBg:width() * 0.5, self.weaponIconBg:height() * 0.5)
	self.ami_left:getAnimation():playWithIndex(0)

	-- 武器图标 
	if self.weaponIcon then
		self.weaponIcon:removeSelf()
		self.weaponIcon = nil
	end
	local weaponIcon = display.newSprite(IMAGE_COMMON .. "weapon/" .. weaponInfo.icon .. ".png"):addTo(self.topbg, 5)
	weaponIcon:setPosition(self.topbg:width() * 0.65 , self.topbg:height() * 0.5)
	self.weaponIcon = weaponIcon

	local ami_right = armature_create("mmwq_right_" .. weaponInfo.icon):addTo(weaponIcon)
	ami_right:setPosition(weaponIcon:width() * 0.5, weaponIcon:height() * 0.5)
	ami_right:getAnimation():playWithIndex(0)



	-- 武器名字
	if self.weaponName then
		self.weaponName:removeSelf()
		self.weaponName = nil
	end
	local weaponName = ui.newTTFLabel({text = weaponInfo.name , font = G_FONT, color = cc.c3b(255, 255, 255), size = 24}):addTo(self.namebg)
	weaponName:setPosition(self.namebg:width() * 0.5 , self.namebg:height() * 0.5)
	self.weaponName = weaponName

	-- 刷新方向
	self:updateDirection(weaponIndex)

	-- 刷新技能
	self:updateWeaponSkillItem(weaponIndex)

end





-- 刷新 方向按钮
-- 根据当前武器索引ID 刷新方向按钮
function WarWeaponView:updateDirection(weaponIndex)
	local min = 1
	local max = #self.WeaponData
	local left = false
	local right = false
	if weaponIndex > min then left = true end
	if weaponIndex < max then right = true end

	if self.arrowPic then
		self.arrowPic:removeSelf()
		self.arrowPic = nil
	end

	local function directionCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		if not self.isTouch then return end
		self.isTouch = false
		local _windex = sender.weaponIndex
		local add = sender.add

		if add == 1 and self.arrowPic then
			UserMO.setFunctionState(self.arrowPic.code)
			self.arrowPic:removeSelf()
			self.arrowPic = nil
		end

		local nextWeaponIndex = _windex + add
		self:updateWeaponView(nextWeaponIndex)
	end

	if not left and self.leftBtn then
		self.leftBtn:removeSelf()
		self.leftBtn = nil
	end

	if not right and self.rightBtn then
		self.rightBtn:removeSelf()
		self.rightBtn = nil
	end

	-- 左
	if left and not self.leftBtn then
		local sp_left_normal = display.newSprite(IMAGE_COMMON .. "btn_left.png")
		local sp_left_selected = display.newSprite(IMAGE_COMMON .. "btn_left.png")
		local leftBtn = MenuButton.new(sp_left_normal, sp_left_selected, nil, directionCallback):addTo(self:getBg(), 4)
		-- leftBtn:setAnchorPoint(cc.p(0.5,0))
		leftBtn:setPosition(self.namebg:x() - self.namebg:width() * 0.65 - leftBtn:width() * 0.5 , self.namebg:y())
		leftBtn.add = -1
		self.leftBtn = leftBtn
	end
	
	-- 右
	if right and not self.rightBtn then
		local sp_right_normal = display.newSprite(IMAGE_COMMON .. "btn_right.png")
		local sp_right_selected = display.newSprite(IMAGE_COMMON .. "btn_right.png")
		local rightBtn = MenuButton.new(sp_right_normal, sp_right_selected, nil, directionCallback):addTo(self:getBg(), 4)
		-- rightBtn:setAnchorPoint(cc.p(0.5,0))
		rightBtn:setPosition(self.namebg:x() + self.namebg:width() * 0.65 + rightBtn:width() * 0.5 , self.namebg:y())
		rightBtn.add = 1
		self.rightBtn = rightBtn
	end

	if self.leftBtn then
		self.leftBtn.weaponIndex = weaponIndex
	end

	if self.rightBtn then
		self.rightBtn.weaponIndex = weaponIndex
	end

	if max == 2 and weaponIndex == 1 then
		local ishaveDone = UserMO.checkFunctionState(LOCAL_FUNC_WARWEAPON_1)
		if not ishaveDone then
			if not self.arrowPic then
				armature_add(IMAGE_ANIMATION .. "effect/ryxz_dianji.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_dianji.plist", IMAGE_ANIMATION .. "effect/ryxz_dianji.xml")
				local arrowPic = CCArmature:create("ryxz_dianji"):addTo(self:getBg(), 100)
		        arrowPic:getAnimation():playWithIndex(0)
		        arrowPic:setPosition(display.cx + 167 + 18, display.height - 93 - 262 - 45)
		        self.arrowPic = arrowPic
		        self.arrowPic.code = LOCAL_FUNC_WARWEAPON_1
			end
		end
	end
	if max == 3 and weaponIndex == 2 then
		local ishaveDone = UserMO.checkFunctionState(LOCAL_FUNC_WARWEAPON_2)
		if not ishaveDone then
			if not self.arrowPic then
				armature_add(IMAGE_ANIMATION .. "effect/ryxz_dianji.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_dianji.plist", IMAGE_ANIMATION .. "effect/ryxz_dianji.xml")
				local arrowPic = CCArmature:create("ryxz_dianji"):addTo(self:getBg(), 100)
		        arrowPic:getAnimation():playWithIndex(0)
		        arrowPic:setPosition(display.cx + 167 + 18, display.height - 93 - 262 - 45)
		        self.arrowPic = arrowPic
		        self.arrowPic.code = LOCAL_FUNC_WARWEAPON_2
			end
		end
	end
end





-- 刷新 当前武器的 技能
function WarWeaponView:updateWeaponSkillItem(weaponIndex, openIndex, isLevelup)
	if self.m_weaponAttrNode then
		self.m_weaponAttrNode:removeAllChildren()
	end

	local weapon = self.WeaponData[weaponIndex]
	local weaponInfo = WarWeaponMO.queryWeaponById(weapon.id)
	local isOut = true
	for index = 1 , weaponInfo.sknMax do
		local _weaponSkillInfo = weapon.skills[index]

		if isOut then
			self:updateWeaponItem(index, weaponIndex, _weaponSkillInfo, weaponInfo.sknMax, openIndex, isLevelup)
		else
			if self.lockItemList[index] then
    			self.lockItemList[index]:removeSelf()
    			self.lockItemList[index] = nil
    		end
    		self.isAmiRunningList[index] = false
		end
		
		if not _weaponSkillInfo then isOut = false end
	end 

	local prDecode = json.decode(weaponInfo.studyProp)

	-- 刷新 洗练按钮和道具
	self:updateUpPropAndButton(weaponIndex, prDecode, weaponInfo.id, weaponInfo.studyCost, weapon.skills)
end





-- 刷新 技能条目
-- index 下标
-- weaponIndex 武器索引id
-- _weaponSkillInfo 武器技能信息
-- Max 可拥有的技能数量
-- openIndex 正在解锁的ID
-- isLevelup 是否正在洗练
function WarWeaponView:updateWeaponItem(index, weaponIndex, _weaponSkillInfo, Max, openIndex, isLevelup)
	-- 背景
	local itembgNomal = display.newSprite(IMAGE_COMMON .. "info_bg_103.png")
	local itembgNomal2 = display.newSprite(IMAGE_COMMON .. "info_bg_103.png")
	itembgNomal2:setOpacity(158)
	local itembg = MenuButton.new(itembgNomal, itembgNomal2, nil, handler(self, self.takeItemCallback)):addTo(self.m_weaponAttrNode)
	itembg:setAnchorPoint(cc.p(0.5,0.5))
	itembg:setPosition(self:getBg():width() * 0.5 , self.lineBg:y() - 110 - 63 * (index - 1)) 

	local coin = 0
	-- 有技能
	if _weaponSkillInfo then
		local weaponSkillData = WarWeaponMO.queryWeaponSkillBySid(_weaponSkillInfo.sid) 

		-- icon图标
		local buffIcon = display.newSprite(IMAGE_COMMON .. "weapon/" .. weaponSkillData.icon .. ".jpg"):addTo(itembg, 5)
		buffIcon:setScale(0.45)
		buffIcon:setPosition(buffIcon:width() * 0.5 * 0.45 + 7, itembg:height() * 0.5 )

		local buffIconBoard = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(buffIcon)
		buffIconBoard:setPosition(buffIcon:width() * 0.5, buffIcon:height() * 0.5)

		local desc = ui.newTTFLabel({text = weaponSkillData.desc, font = G_FONT, color = cc.c3b(231, 162, 29), size = 24}):addTo(itembg,1)
		desc:setAnchorPoint(cc.p(0.5,0.5))
		desc:setPosition(itembg:width() * 0.5 , itembg:height() * 0.5)

		if isLevelup and self.skillDescList[index] and _weaponSkillInfo.sid ~= self.skillDescList[index].sid and not _weaponSkillInfo.locked  then
			self.isAmiRunningList[index] = true
			desc:setString(self.skillDescList[index].desc)
			local ami_xin = armature_create("mmwq_jinengshuaxin", 0, 0, function (movementType, movementID, armature) 
					if movementType == MovementEventType.COMPLETE then
						desc:setString(weaponSkillData.desc)
						armature:removeSelf()
						self.isAmiRunningList[index] = false
					end
				end):addTo(itembg,2)
			ami_xin:setPosition(itembg:width() * 0.5, itembg:height() * 0.5)
			ami_xin:getAnimation():playWithIndex(0)
		else
			self.isAmiRunningList[index] = false
		end

		self.skillDescList[index] = {sid = _weaponSkillInfo.sid, desc = weaponSkillData.desc}

		local lockIcon = "icon_unlock_2.png"
		if _weaponSkillInfo.locked then lockIcon = "icon_lock_2.png" end
		if not self.lockItemList[index] then
			local sp_lock = display.newSprite(IMAGE_COMMON .. lockIcon):addTo(self:getBg(), 10)
			sp_lock:setPosition(itembg:x() + itembg:width() * 0.5 - sp_lock:width() * 0.5, itembg:y() )
			sp_lock:setOpacity(0)
			sp_lock.islock = _weaponSkillInfo.locked
    		self.lockItemList[index] = sp_lock
		end

		if self.lockItemList[index] and self.lockItemList[index].islock ~= _weaponSkillInfo.locked then
			self.lockItemList[index]:setTexture( CCTextureCache:sharedTextureCache():addImage(IMAGE_COMMON ..lockIcon) )
			self.lockItemList[index].islock = _weaponSkillInfo.locked
		end

		-- 解锁技能
		if openIndex and index == openIndex then
			local ami_jiesuo = armature_create("mmwq_jiesuojineng"):addTo(itembg)
			ami_jiesuo:setPosition(itembg:width() * 0.5, itembg:height() * 0.5)
			ami_jiesuo:getAnimation():playWithIndex(0)
		end
	else
		if self.lockItemList[index] then
			self.lockItemList[index]:removeSelf()
			self.lockItemList[index] = nil
		end

		-- 背景
		itembg:setNormalSprite(display.newSprite(IMAGE_COMMON .. "info_bg_104.png"))
		itembg:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "info_bg_103.png"))

		local number = WarWeaponMO.getWeaponUnLockCoin(self.WeaponData[weaponIndex].id , index)
		coin = number

		if number > 0 then
			-- 
			local coinIcon = display.newSprite(IMAGE_COMMON .. "icon_coin_2.png"):addTo(itembg)
			coinIcon:setPosition(itembg:width() * 0.5 - coinIcon:width() * 0.55 , itembg:height() * 0.5 )

			-- 无技能
			local coinNumberLb = ui.newBMFontLabel({text = number, font = "fnt/num_1.fnt", align = ui.TEXT_ALIGN_CENTER}):addTo(itembg)
			coinNumberLb:setAnchorPoint(cc.p(0,0.5))
			coinNumberLb:setPosition(coinIcon:x() + coinIcon:width() * 0.5 + 5, itembg:height() * 0.5 + 3)
		else
			local free = ui.newTTFLabel({text = CommonText[729], font = G_FONT, color = cc.c3b(255, 255, 255), size = 24}):addTo(itembg,1)
			free:setAnchorPoint(cc.p(0.5,0.5))
			free:setPosition(itembg:width() * 0.5 , itembg:height() * 0.5)
		end

	end

	itembg.coin = coin
	itembg._weaponSkillInfo = _weaponSkillInfo
	itembg.index = index
	itembg.weaponIndex = weaponIndex
	itembg.Max = Max

end





-- weaponindex 下标 1 2 3
-- role 数据
-- weaponid 武器ID
-- studyCost 消费
-- skillList 技能列表
function WarWeaponView:updateUpPropAndButton(weaponindex, role, weaponid, studyCost, skillList)
	local propId = role[1]
	local limitCount = role[2]
	local hasCount = UserMO.getResource(ITEM_KIND_PROP, propId)

	local max = #skillList
	local count = 0
	local coin = 0
	for index = 1, max do
		if skillList[index].locked then
			count = count + 1 
		end
	end

	self.upBtn:setEnabled(not (max == 0 or (count > 0 and count == max)))

	local price = WarWeaponMO.getWeaponStudyLockCoin(weaponid, count) or 0

	-- 使用研究劵
	if hasCount >= limitCount then

		self.upBtn.coin_lb1:setString(string.format(CommonText[1115][5] ,hasCount))
		self.upBtn.sp_coin_number:setString(price)
		coin = price

		self.upBtn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_11_normal.png"))
		self.upBtn:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_11_selected.png"))
	else
		-- 使用金币
		coin = studyCost + price -- 洗练技能消耗 + 技能加锁消耗

		self.upBtn.coin_lb1:setString(CommonText[1115][6] .. CommonText[1115][3])
		self.upBtn.sp_coin_number:setString(coin)

		self.upBtn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_9_normal.png"))
		self.upBtn:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_9_selected.png"))
	end
	self.upBtn.weaponid = weaponid
	self.upBtn.weaponindex = weaponindex
	self.upBtn.coin = coin
end




----------------------------------------------------------
--						按钮							--
----------------------------------------------------------
-- 研究
function WarWeaponView:levelUpSkillCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	if not self.isTouch then return end
		self.isTouch = false

	local weaponid = sender.weaponid
	local weaponindex = sender.weaponindex
	local coin = sender.coin
	local function callback(data)
		self.WeaponData = WarWeaponBO.weaponDataList

		self:updateWeaponSkillItem(weaponindex,0 , true)

		-- Toast.show(CommonText[1115][3] .. CommonText[1116][2])
	end

	local function levelup()
		WarWeaponBO.StudyWeaponSkill(callback, weaponid, weaponindex)
	end

	local coinCount = UserMO.getResource(ITEM_KIND_COIN)
	if coinCount < coin then
		require("app.dialog.CoinTipDialog").new(CommonText[679] .. CommonText[1116][1] .. CommonText[1115][3]):push()
		return
	end

	if coin > 0 and UserMO.consumeConfirm then
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[1117], coin, CommonText[1115][3]), function() levelup() end, nil):push()
	else
		levelup()
	end
	
end

-- 解锁技能 / 开放新技能
function WarWeaponView:takeItemCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	if not self.isTouch then return end
		self.isTouch = false

	local _weaponSkillInfo = sender._weaponSkillInfo 					-- 技能信息 (_weaponSkillInfo == nil 代表开启新技能)
	local lock = _weaponSkillInfo and (not _weaponSkillInfo.locked)		-- 加锁信息
	local weaponindex = sender.weaponIndex 								-- 武器索引ID
	local weaponId = self.WeaponData[weaponindex].id 					-- 武器ID
	local index = sender.index 											-- 技能索引下标
	local barIdx = index - 1 											-- 服务端技能索引下标 (从0开始)
	local Max = sender.Max 												-- 可拥有的最大值
	local coin = sender.coin 											-- 解锁消费

	local openIndex = (not _weaponSkillInfo and index) or 0 			-- 正在解锁的技能下标索引


	local function updataItem()
		WarWeaponBO.checkInAllAttr()
		UserBO.triggerFightCheck()

		self.WeaponData = WarWeaponBO.weaponDataList
		self:updateDirection(weaponindex)
		self:updateWeaponSkillItem(weaponindex, openIndex)

		Toast.show(CommonText[1115][4])
	end

	-- 刷新数据
	local function updataCallback(data)
		local _dbs = PbProtocol.decodeRecord(data["weapon"])
		local weapon = {}
		weapon.id = _dbs.id
		weapon.skills = PbProtocol.decodeArray(_dbs.bar)
		WarWeaponBO.weaponDataList[weaponindex] = weapon

		WarWeaponBO.checkInAllAttr()
	end

	--开放新技能
	local function openCallback(data)
		if not _weaponSkillInfo and (Max == index) then
			WarWeaponBO.GetSecretWeaponInfo(updataItem)
		else
			updataCallback(data)
			UserBO.triggerFightCheck()
			self.WeaponData = WarWeaponBO.weaponDataList
			self:updateWeaponSkillItem(weaponindex, openIndex)

			-- Toast.show(CommonText[1115][4])
		end
	end

	-- 加锁解锁 按钮
	local function lockCallback(data)
		updataCallback(data)
		if lock then
			Toast.show(CommonText[902][1] .. CommonText[1116][2])
		else
			Toast.show(CommonText[902][2] .. CommonText[1116][2])
		end
		self.WeaponData = WarWeaponBO.weaponDataList
		self:updateWeaponSkillItem(weaponindex, openIndex)
	end

	local function openNewSkill()
		--开放新技能
		WarWeaponBO.UnlockWeaponBar(openCallback, weaponId)
	end
	
	if _weaponSkillInfo then
		-- 加锁解锁 按钮
		WarWeaponBO.LockedWeaponBar(lockCallback, weaponId, barIdx, lock)
	else
		local coinCount = UserMO.getResource(ITEM_KIND_COIN)
		if coinCount < coin then
			require("app.dialog.CoinTipDialog").new(CommonText[679] .. CommonText[1116][1] .. CommonText[1115][4]):push()
			return
		end

		if coin > 0 and UserMO.consumeConfirm then
			local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
			CoinConfirmDialog.new(string.format(CommonText[1117], coin, CommonText[1115][4]), function() openNewSkill() end, nil):push()
		else
			openNewSkill()
		end
	end
end

return WarWeaponView