
-- 物品

local BagTableView = class("BagTableView", TableView)

VIEW_FOR_MINE_ALL        = 1  -- 我的所有的背包
VIEW_FOR_MINE_RESOURCE   = 6
VIEW_FOR_MINE_GAIN       = 7
VIEW_FOR_MINE_OTHER      = 8

VIEW_FOR_SHOP_ALL        = 2  -- 商城的所有
VIEW_FOR_SHOP_RESOURCE   = 3  -- 商城的资源
VIEW_FOR_SHOP_GAIN       = 4  -- 商城的增益
VIEW_FOR_SHOP_OTHER      = 5  --商城的其他
VIEW_FOR_SHOP_SALE       = 101  --特价商品
VIEW_FOR_SHOP_WORLD      = 201  --世界商品

function BagTableView:ctor(size, viewFor)
	BagTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
	self.m_viewFor = viewFor

	self:initShowProps()
end

function BagTableView:initShowProps()
	self.m_props = {}
	if self.m_viewFor == VIEW_FOR_MINE_ALL then
		self.m_props = PropMO.getAllProps()
		table.sort(self.m_props, PropBO.orderProps)
	elseif self.m_viewFor == VIEW_FOR_MINE_RESOURCE then
		self.m_props = PropMO.getPropsByKind(SHOP_KIND_RESOURCE)
		table.sort(self.m_props, PropBO.orderProps)
	elseif self.m_viewFor == VIEW_FOR_MINE_GAIN then
		self.m_props = PropMO.getPropsByKind(SHOP_KIND_GAIN)
		table.sort(self.m_props, PropBO.orderProps)
	elseif self.m_viewFor == VIEW_FOR_MINE_OTHER then
		self.m_props = PropMO.getPropsByKind(SHOP_KIND_OTHER)
		table.sort(self.m_props, PropBO.orderProps)
	elseif self.m_viewFor == VIEW_FOR_SHOP_ALL then
		self.m_props = PropBO.getShopProp(SHOP_KIND_ALL)
	elseif self.m_viewFor == VIEW_FOR_SHOP_RESOURCE then
		self.m_props = PropBO.getShopProp(SHOP_KIND_RESOURCE)
	elseif self.m_viewFor == VIEW_FOR_SHOP_GAIN then
		self.m_props = PropBO.getShopProp(SHOP_KIND_GAIN)
	elseif self.m_viewFor == VIEW_FOR_SHOP_OTHER then  -- 显示成长和特殊两类道具
		self.m_props = PropBO.getShopProp(SHOP_KIND_OTHER)
	elseif self.m_viewFor == VIEW_FOR_SHOP_SALE then
		self.m_props = PropMO.getVipShop()
	elseif self.m_viewFor == VIEW_FOR_SHOP_WORLD then
		self.m_props = PropMO.getWorldShop()
	end
end

function BagTableView:numberOfCells()
	return #self.m_props
end

function BagTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function BagTableView:createCellAtIndex(cell, index)
	BagTableView.super.createCellAtIndex(self, cell, index)

	local prop = self.m_props[index]

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	if self.m_viewFor == VIEW_FOR_SHOP_SALE or self.m_viewFor == VIEW_FOR_SHOP_WORLD then
		local item = json.decode(prop.reward)
		local view = UiUtil.createItemView(item[1], item[2], {count = item[3]}):addTo(cell):pos(100, self.m_cellSize.height / 2)
		UiUtil.createItemDetailButton(view, cell, true)
		local pb = UserMO.getResourceData(item[1], item[2])
		-- 名称
		local name = ui.newTTFLabel({text = pb.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[pb.quality]}):addTo(cell)
		-- local desc = pb.desc or ""
		local descStr = pb.desc or ""
		local limitCount = 20
		local descCount , str = string.utf8len(descStr, limitCount)
		local desc = ui.newTTFLabel({text = descStr, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self.m_cellSize.height / 2 - 15, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(260, 88)}):addTo(cell)
		desc:setAnchorPoint(cc.p(0.5, 0.5))
		if descCount > limitCount then
			descStr = str  .. "..."
			desc:setString(descStr)
			local descTip = ui.newTTFLabel({text = CommonText[1777], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[12], align = ui.TEXT_ALIGN_RIGHT}):addTo(cell)
			descTip:setAnchorPoint(cc.p(1, 0))
			descTip:setPosition(170 + desc:width(),self.m_cellSize.height / 2 - 60)
			desc.kind = item[1]
			desc.id = item[2]
			-- desc.param = param
			UiUtil.createItemDetailButton(desc,cell,true)
		end
		
		local t = UiUtil.label(CommonText[20222]):addTo(cell):align(display.LEFT_CENTER, 460, 114)
		UiUtil.label(prop.price):rightTo(t)
		display.newSprite(IMAGE_COMMON.."info_bg_73.png"):addTo(cell):pos(495,114):scale(0.8)

		-- 购买按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onBtnCallback))
		btn.itemView = view
		btn.gid = prop.gid
		btn.data = item
		btn.vipLevel = prop.vipLevel
		cell:addButton(btn, self.m_cellSize.width - 120, self.m_cellSize.height / 2 - 22)
		--现价
		local nowPrice = prop.cost or prop.price
		local count = VipBO.getBuyshopNum()
		if self.m_viewFor == VIEW_FOR_SHOP_WORLD then
			if prop.discountAndNmuber then
				local data = nil
				local info = json.decode(prop.discountAndNmuber)
				for k,v in ipairs(info) do
					if StaffMO.worldLv_ == v[1] then
						data = v
						break
					end
				end
				nowPrice = math.ceil(data[2]/10000* prop.price)
				count = data[3]
			end
		end
		btn.price = nowPrice
		local info = PropBO.shopInfo_[self.m_viewFor]
		local left = count
		if info and info[prop.gid] then
			left = count - info[prop.gid]
		end
		btn.left = left
		UiUtil.label("("..left.."/"..count..")",nil,COLOR[left == 0 and 6 or 2]):rightTo(name, 10)
		if left == 0 then
			btn:setLabel(CommonText[20216][3])
			btn:setEnabled(false)
		else
			btn:setLabel(nowPrice)
			btn.m_label:align(display.LEFT_CENTER, btn:width()/2, btn:height()/2)
			display.newSprite(IMAGE_COMMON.."icon_coin.png"):leftTo(btn.m_label)
		end
		--世界商城等级限制
		if self.m_viewFor == VIEW_FOR_SHOP_WORLD then
			if UserMO.level_ < prop.levelLimit then
				desc:setString(string.format(CommonText[290], prop.levelLimit, ""))
				desc:setColor(COLOR[6])
				btn:setEnabled(false)
			end
		end
		return cell
	end
	local propDB = PropMO.queryPropById(prop.propId)
	local bagView = nil
	local param = {}
	if self.m_viewFor == VIEW_FOR_MINE_ALL or self.m_viewFor == VIEW_FOR_MINE_RESOURCE or self.m_viewFor == VIEW_FOR_MINE_GAIN or self.m_viewFor == VIEW_FOR_MINE_OTHER then
		param = {count = UserMO.getResource(ITEM_KIND_PROP, prop.propId)}
		bagView = UiUtil.createItemView(ITEM_KIND_PROP, prop.propId, param):addTo(cell)
	else
		param = nil
		bagView = UiUtil.createItemView(ITEM_KIND_PROP, prop.propId):addTo(cell)
	end
	bagView:setPosition(100, self.m_cellSize.height / 2)
	UiUtil.createItemDetailButton(bagView, cell, true)

	-- 名称
	local name = ui.newTTFLabel({text = PropMO.getPropName(prop.propId), font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[propDB.color]}):addTo(cell)

	local descStr = propDB.desc or ""
	local limitCount = 20
	local descCount , str = string.utf8len(descStr, limitCount)
	local desc = ui.newTTFLabel({text = descStr, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self.m_cellSize.height / 2 - 15, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(260, 88)}):addTo(cell)
	desc:setAnchorPoint(cc.p(0.5, 0.5))
	if descCount > limitCount then
		descStr = str  .. "..."
		desc:setString(descStr)
		local descTip = ui.newTTFLabel({text = CommonText[1777], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[12], align = ui.TEXT_ALIGN_RIGHT}):addTo(cell)
		descTip:setAnchorPoint(cc.p(1, 0))
		descTip:setPosition(170 + desc:width(),self.m_cellSize.height / 2 - 60)
		desc.kind = ITEM_KIND_PROP
		desc.id = prop.propId
		desc.param = param
		UiUtil.createItemDetailButton(desc,cell,true)
	end

	if self.m_viewFor == VIEW_FOR_MINE_ALL or self.m_viewFor == VIEW_FOR_MINE_RESOURCE or self.m_viewFor == VIEW_FOR_MINE_GAIN or self.m_viewFor == VIEW_FOR_MINE_OTHER then -- 我的背包
		-- 数量
		local label = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = self.m_cellSize.width - 120 - 25, y = 114, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))

		-- 
		local count = ui.newTTFLabel({text = prop.count, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		count:setAnchorPoint(cc.p(0, 0.5))

		if propDB.canUse == 1 then -- 可以使用
			-- 使用按钮
			local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
			local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onBtnCallback))
			btn:setLabel(CommonText[86])
			btn.propId = propDB.propId
			-- btn.itemView = bagView
			btn.propLabel = count
			cell:addButton(btn, self.m_cellSize.width - 120, self.m_cellSize.height / 2 - 22)
		end		
	else -- 商城
		-- 售价
		local label = ui.newTTFLabel({text = CommonText[198] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = self.m_cellSize.width - 120 - 55, y = 114, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))

		local view = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(cell)
		view:setPosition(label:getPositionX() + label:getContentSize().width + view:getContentSize().width / 2, label:getPositionY())

		local price = ui.newBMFontLabel({text = propDB.price, font = "fnt/num_2.fnt", x = view:getPositionX() + view:getContentSize().width / 2, y = view:getPositionY()}):addTo(cell)
		price:setAnchorPoint(cc.p(0, 0.5))

		-- 购买按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onBtnCallback))
		btn.propId = propDB.propId
		btn:setLabel(CommonText[119])
		btn.itemView = bagView
		cell:addButton(btn, self.m_cellSize.width - 120, self.m_cellSize.height / 2 - 22)
	end

	return cell
end

function BagTableView:onBtnCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local propId = sender.propId
	if propId then
		local pb = PropMO.queryPropById(propId)
		if pb.effectType == 9 or pb.effectType == 10 then
			local effectValue = json.decode(pb.effectValue)
			local data = PendantBO.pendants_[effectValue[1][1]]
			if pb.effectType == 10 then 
				data = PendantBO.portraits_[effectValue[1][1]]
			end
			if data then
				if data.foreverHold or data.endTime - ManagerTimer.getTime() > 0 then
					Toast.show(ErrorText.text742)
					return
				end
			end
		end
	end

	if self.m_viewFor == VIEW_FOR_MINE_ALL or self.m_viewFor == VIEW_FOR_MINE_RESOURCE or self.m_viewFor == VIEW_FOR_MINE_GAIN or self.m_viewFor == VIEW_FOR_MINE_OTHER then  -- 使用
		if self.m_isUseProp then return end

		local function doneUserProp(awards)
			Loading.getInstance():unshow()
			
			local resData = UserMO.getResourceData(ITEM_KIND_PROP, propId)

			--军团贡献箱子特殊提示
			if propId == PROP_ID_PARTY_CONTRIBUTION or propId == PROP_ID_PARTY_CONTRIBUTION1 then
				Toast.show(string.format(CommonText[888],propId == PROP_ID_PARTY_CONTRIBUTION and 5 or 10))
			elseif propId == PROP_ID_RED_PACKET_MICRO or propId == PROP_ID_RED_PACKET_SMALL or propId == PROP_ID_RED_PACKET_MEDIUM or propId == PROP_ID_RED_PACKET_BIG then
				Loading.getInstance():show()
				SocialityBO.getFriend(function()
					Loading.getInstance():unshow()
					end)
				local value = PropMO.getAddValueByRedId(propId)
				Toast.show(string.format(CommonText[1848][2], resData.name))
			else
				Toast.show(CommonText[84] .. resData.name)
			end

			if awards then
				UiUtil.showAwards(awards)
			end

			self.m_isUseProp = false

			local offset = self:getContentOffset()

			self:initShowProps()
			self:reloadData()

			local maxOffset = self:maxContainerOffset()
			local minOffset = self:minContainerOffset()
			-- print("minOffset.y:", minOffset.y, "maxOffset.y:", maxOffset.y)
			if minOffset.y > maxOffset.y then
			    local y = math.max(maxOffset.y, minOffset.y)
			    self:setContentOffset(cc.p(0, y))
		    elseif offset then
		    	if offset.y < minOffset.y then
		    		self:setContentOffset(minOffset)
		    	else
			    	self:setContentOffset(offset)
		    	end
		    end

			-- local count = UserMO.getResource(ITEM_KIND_PROP, propId)
			-- if count <= 0 then  -- 使用完了
			-- 	self:initShowProps()
			-- 	self:reloadData()
			-- else
			-- 	local label = sender.propLabel
			-- 	if label then
			-- 		label:setString(count)
			-- 	end
			-- 	local need = false
			-- 	if awards and awards.awards then
			-- 		for index = 1, #awards.awards do
			-- 			if awards.awards[index].kind == ITEM_KIND_PROP then
			-- 				need = true
			-- 				break
			-- 			end
			-- 		end
			-- 	end
			-- 	if need then
			-- 		local offset = self:getContentOffset()
			-- 		self:reloadData()
			-- 		self:setContentOffset(offset)
			-- 	end
			-- end
		end

		if propId == PROP_ID_MOVE_HOME_RANDOM then  -- 随机迁城
			-- 确定迁徙吗？
			local ConfirmDialog = require("app.dialog.ConfirmDialog")
			ConfirmDialog.new(CommonText[311][2], function()
					local status = WorldBO.getMoveHomeStatus()
					if status == 1 then
						Toast.show(CommonText[10002][1])  -- 部队正在执行任务，无法迁徙
						return
					end
					Loading.getInstance():show()
					WorldBO.asynMoveHome(doneUserProp, nil, nil, 2)  -- 随机迁城
				end):push()
		elseif propId == PROP_ID_HORN_NORMAL or propId == PROP_ID_HORN_LOVE or propId == PROP_ID_HORN_BLESS or propId == PROP_ID_HORN_BIRTH then -- 喇叭
			local HornUseDialog = require("app.dialog.HornUseDialog")
			HornUseDialog.new(propId, doneUserProp):push()
		elseif propId == PROP_ID_INDICATOR_RESOURCE or propId == PROP_ID_INDICATOR_PLAYER then
			local IndicatorUseDialog = require("app.dialog.IndicatorUseDialog")
			IndicatorUseDialog.new(propId, doneUserProp):push()
		elseif propId == PROP_ID_RED_PACKET_MICRO or propId == PROP_ID_RED_PACKET_SMALL or propId == PROP_ID_RED_PACKET_MEDIUM or propId == PROP_ID_RED_PACKET_BIG then
			local PropSendDialog = require("app.dialog.PropSendDialog")
			PropSendDialog.new(propId, doneUserProp):push()
		elseif propId == PROP_ID_NICK_CHANGE then -- 身份铭牌
			local NickChangeDialog = require("app.dialog.NickChangeDialog")
			NickChangeDialog.new(propId, doneUserProp):push()
		elseif propId == PROP_ID_PROFOTO then --哈洛克宝图
			local function unfoldProfoto(useGold)
				if useGold and PROFOTO_UNFOLD_COIN > UserMO.getResource(ITEM_KIND_COIN) then
					require("app.dialog.CoinTipDialog").new():push()
					return
				end
				Loading.getInstance():show()
				ActivityCenterBO.asynUnfoldProfoto(function(awards)
						Loading.getInstance():unshow()
						doneUserProp(awards)
					end,useGold)
			end
			--判断信物是否足够
			local count = UserMO.getResource(ITEM_KIND_PROP, PROFOTO_PROP_TRUST_ID)
			if count == 0 then
				if UserMO.consumeConfirm then
					local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
					CoinConfirmDialog.new(string.format(CommonText[787],PROFOTO_UNFOLD_COIN), function()
							unfoldProfoto(true)
						end):push()
				else
					unfoldProfoto(true)
				end
			else
				unfoldProfoto(false)
			end
		-- elseif propId == PROP_ID_TANKBOX then --军团战箱子
		-- 	Loading.getInstance():show()
		-- 	PartyBattleBO.asynUseAmyProp(function(awards)
		-- 			Loading.getInstance():unshow()
		-- 			doneUserProp(awards)
		-- 		end,propId)
			
		elseif propId == PROP_ID_FREE_WAR_72 or propId == PROP_ID_FREE_WAR_24 or propId == PROP_ID_FREE_WAR_8 then  -- 是免战
			local attack = false
			local armies = ArmyMO.getArmiesByState(ARMY_STATE_MARCH)
			for index = 1, #armies do
				local army = armies[index]
				-- local pos = WorldMO.decodePosition(army.target)
				-- local mine = WorldBO.getMineAt(pos)
				-- if not mine then
				if army.type == ARMY_TARGET_TYPE_PLAYER then  -- 有人被攻击了
					attack = true
					break
				end
			end

			if attack then -- 不能使用保护罩
				Toast.show(CommonText[10006])
				return
			end

			Loading.getInstance():show()
			self.m_isUseProp = true
			PropBO.asynUseProp(doneUserProp, propId, 1)
		elseif propId == PROP_ID_HERO_CHIP then -- 将神魂碎片
			local heroDB = PropMO.queryPropById(PROP_ID_JIANGSHENHUN) -- 获得将魂的数据信息
			local heroName = UserMO.getResourceData(ITEM_KIND_PROP, PROP_ID_JIANGSHENHUN).name
			local chipName = UserMO.getResourceData(ITEM_KIND_PROP, PROP_ID_HERO_CHIP).name

			local count = UserMO.getResource(ITEM_KIND_PROP, PROP_ID_HERO_CHIP)
			if count < heroDB.heroChip then
				Toast.show(CommonText[10048])  -- 碎片不足，无法合成
			else
				local ConfirmDialog = require("app.dialog.ConfirmDialog")
				ConfirmDialog.new(string.format(CommonText[10050], heroDB.heroChip, chipName, heroName), function()
						Loading.getInstance():show()
						self.m_isUseProp = true
						PropBO.asynComposeSant(doneUserProp)
					end):push()
			end
		elseif propId == PROP_ID_PARTY_RENAME then
			gprint("use party rename")
			--判断是否有军团并且自己是军团长
			if not PartyBO.getMyParty() then
				Toast.show(CommonText[614])  -- 暂无军团
				return
			end
			if PartyMO.myJob < PARTY_JOB_MASTER then
				Toast.show(CommonText[896])  -- 不是军团长
				return
			end

			--弹出军团改名窗口
			local PartyNameChangeDialog = require("app.dialog.PartyNameChangeDialog")
			PartyNameChangeDialog.new(propId, doneUserProp):push()
		else
			local propDB = PropMO.queryPropById(propId)
			if propDB.batchUse == 1 then  -- 可以批量使用
				local PropUseDialog = require("app.dialog.PropUseDialog")
				PropUseDialog.new(propId, doneUserProp):push()
			else
				if propId == PROP_ID_EQUIP_BOX_WHITE or propId == PROP_ID_EQUIP_BOX_GREEN or propId == PROP_ID_EQUIP_BOX_BLUE or propId == PROP_ID_EQUIP_BOX_PURPLE
					or propId == PROP_ID_NEED_BOX_FIGHT then
					local equips = EquipMO.getFreeEquipsAtPos()
					local remainCount = UserMO.equipWarhouse_ - #equips
					if remainCount <= 0 then
						Toast.show(CommonText[711])  -- 仓库已满
						return
					end
					Loading.getInstance():show()
					self.m_isUseProp = true
					PropBO.asynUseProp(doneUserProp, propId, 1)
				elseif propId == PROP_ID_PARTY_CONTRIBUTION or propId == PROP_ID_PARTY_CONTRIBUTION1 then
					if not PartyBO.getMyParty() then
						Toast.show(CommonText[614])  -- 暂无军团
						return
					end
					Loading.getInstance():show()
					self.m_isUseProp = true
					PropBO.asynUseProp(doneUserProp, propId, 1)
				else
					--检查能量条使用
					local effect = json.decode(propDB.effectValue)
					if effect[1] and effect[1][1] == 19 and effect[1][2] == 0 then
						if effect[1][3] + UserMO.power_ > POWER_MAX_HAVE then
							Toast.show(CommonText[20007])
							return
						end
					end
					Loading.getInstance():show()
					self.m_isUseProp = true
					PropBO.asynUseProp(doneUserProp, propId, 1)
				end
			end
		end
	else
		if sender.vipLevel and sender.vipLevel > UserMO.vip_ then
			Toast.show(CommonText[382][4])
			return
		end
		local itemView = sender.itemView
		local worldPoint = itemView:getParent():convertToWorldSpace(cc.p(itemView:getPositionX(), itemView:getPositionY()))
		-- print("pos: x:", worldPoint.x, "y:", worldPoint.y)

		local BagBuyDialog = require("app.dialog.BagBuyDialog")
		local param = nil
		if self.m_viewFor == VIEW_FOR_SHOP_SALE or self.m_viewFor == VIEW_FOR_SHOP_WORLD then
			local data = sender.data
			local function rhand(num,hand)
				PropBO.buyShopGoods(self.m_viewFor,sender.gid,num,function()
						local offset = self:getContentOffset()
						self:reloadData()
						self:setContentOffset(offset)
						--加入背包
						local ret = CombatBO.addAwards({{type = data[1],id = data[2],count = data[3] * num}})
						UiUtil.showAwards(ret)
						hand()
					end)
			end
			param = {max = sender.left, item = sender.data, price = sender.price, keyId = sender.gid, rhand = rhand}
		end
		local dialog = BagBuyDialog.new(worldPoint, propId, param)
		dialog:push()
	end
end

-- function BagTableView:cellTouched(cell, index)
-- 	print("BagTableView index:", index)
-- end

return BagTableView
