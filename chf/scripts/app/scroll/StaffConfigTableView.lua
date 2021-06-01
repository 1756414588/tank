--
-- Author: Your Name
-- Date: 2017-07-04 11:14:24
--
--参谋配置StaffConfigTableView
local StaffConfigTableView = class("StaffConfigTableView", TableView)

function StaffConfigTableView:ctor(size)
	StaffConfigTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 210)
	self.m_data = StaffMO.queryStaffHeroInfo()
	self.m_staffHeros = StaffMO.staffHerosData_
end

function StaffConfigTableView:onEnter()
	StaffConfigTableView.super.onEnter(self)
	armature_add("animation/effect/cmpz_tx_mc.pvr.ccz", "animation/effect/cmpz_tx_mc.plist", "animation/effect/cmpz_tx_mc.xml")
end

function StaffConfigTableView:numberOfCells()
	return #self.m_data
end

function StaffConfigTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function StaffConfigTableView:createCellAtIndex(cell, index)
	StaffConfigTableView.super.createCellAtIndex(self, cell, index)
	local staffHero = self.m_staffHeros[index].heroId
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_94.jpg"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 170))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2 - 10)

	local titleBg = display.newSprite(IMAGE_COMMON.."title_bg_1.png"):addTo(bg)
	titleBg:setPosition(titleBg:width() / 2 + 10,bg:height())

	local title = UiUtil.label(self.m_data[index].partName):addTo(titleBg):center()
	title:setRotation(-3)

	local max,maxHeroId = StaffMO.queryStrongStaffHeroById(staffHero)
	for i =1,2 do
		local itemView = UiUtil.createItemView(ITEM_KIND_HERO, staffHero[i]):addTo(cell)
		itemView:setScale(0.65)
		itemView:setPosition((self.m_cellSize.width / 3) * (i - 1) + itemView:width() / 2,itemView:height() / 2 - 10)
		local param = {}
		param.id = i
		param.partId = index
		param.heroId = staffHero[i]
		itemView.param = param
		itemView.max = max
		UiUtil.createItemDetailButton(itemView, nil, nil, handler(self, self.onChoseCallback))
	end
	--技能
	local skill
	local hero = nil
	if max ~= 0 then
		hero = HeroMO.queryHero(maxHeroId)
		local icomStr = "image/item/skillid_"..hero.skillId..".jpg"
		local _info = StaffMO.queryStaffHeroById(index)
		if _info.fullSkill and staffHero[1] > 0 and staffHero[2] > 0 and staffHero[1] ~= staffHero[2] then
			icomStr = "image/item/" .. _info.fullSkillIcon .. ".jpg"
		end
		skill = display.newSprite(icomStr):addTo(cell)
	else
		skill = display.newSprite("image/item/" .. self.m_data[index].iconOff .. ".jpg"):addTo(cell)
	end
	skill:setPosition((self.m_cellSize.width / 3) * 2 + skill:width(),self.m_cellSize.height / 2 - 10)
	local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(skill):center()
	if max ~= 0 then
		self:showTips(skill,staffHero,index,1)
	end

	cell.skill = skill
	return cell
end

function StaffConfigTableView:onChoseCallback(sender)
	ManagerSound.playNormalButtonSound()
	local param = sender.param
	local staffs = StaffMO.queryStaffHeroById(param.partId)
	local staffHeros = json.decode(staffs.heroId)
	if HeroMO.getHeroById(staffHeros[1]) == nil and HeroMO.getHeroById(staffHeros[2]) == nil then
		Toast.show(CommonText[100020])
		return
	end
	
	if param.heroId > 0 then
		require("app.dialog.ExchangeStaffHeroDialog").new(function ()
			self.m_staffHeros = StaffMO.staffHerosData_
			self:reloadData()
		end,param):push()
		return
	end
	require("app.view.StaffHeroView").new(function (lastMax)
		self.m_staffHeros = StaffMO.staffHerosData_
		local offset = self:getContentOffset()
		self:reloadData()
		self:setContentOffset(offset)
		local cell = self:cellAtIndex(param.partId)
		local staffHero = self.m_staffHeros[param.partId].heroId
		local max,maxHeroId = StaffMO.queryStrongStaffHeroById(staffHero)
		-- if max > lastMax or true then
			local armature = armature_create("cmpz_tx_mc"):addTo(cell,2)
			armature:setPosition(cell.skill:getPosition())
			armature:getAnimation():playWithIndex(0)
			
			local hero = HeroMO.queryHero(maxHeroId)
			local _skillname = hero.skillName
			local _skilldesc = hero.skillDesc
			local _info = StaffMO.queryStaffHeroById(param.partId)
			if _info.fullSkill and staffHero[1] > 0 and staffHero[2] > 0 and staffHero[1] ~= staffHero[2] then
				_skillname = _info.fullSkillName
				_skilldesc = _info.fullSkillNameDesc
			end
			Toast.show(string.format(CommonText[100018],_skillname,_skilldesc))
		-- end
	end,param,sender.max):push()
end

-- 点击触发提示
function StaffConfigTableView:showTips(node,data,index,anchor)
	local hero
	local max,maxHeroId = StaffMO.queryStrongStaffHeroById(data)
	if max ~= 0 then
		hero = HeroMO.queryHero(maxHeroId)
	end
	anchor = anchor or 0
	node:setTouchEnabled(true)
	node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			if index == 4 and data[1] > 0 and data[2] > 0 and data[1] ~= data[2] then
				hero1 = HeroMO.queryHero(data[1])
				hero2 = HeroMO.queryHero(data[2])
				local detBg = display.newScale9Sprite(IMAGE_COMMON .. "tipbg.png"):addTo(node)
				detBg:setPreferredSize(cc.size(380, 100))
				detBg:setAnchorPoint(cc.p(anchor,0.4))
				detBg:setPosition(0,node:getContentSize().height * 1.1)

				local name1 = UiUtil.label(hero1.skillName.."：",FONT_SIZE_SMALL,COLOR[1]):addTo(detBg)
				name1:setPosition(60,detBg:getContentSize().height - 30)
				local name2 = UiUtil.label(hero2.skillName.."：",FONT_SIZE_SMALL,COLOR[1]):addTo(detBg)
				name2:setPosition(60,detBg:getContentSize().height - 70)
				local desc1 = UiUtil.label(hero1.skillDesc,FONT_SIZE_SMALL,COLOR[1]):addTo(detBg):rightTo(name1)
				local desc2 = UiUtil.label(hero2.skillDesc,FONT_SIZE_SMALL,COLOR[1]):addTo(detBg):rightTo(name2)
				node.tipNode_ = detBg
			else
				local _skillname = hero.skillName
				local _skilldesc = hero.skillDesc
				local _info = StaffMO.queryStaffHeroById(index)
				if _info.fullSkill and data[1] > 0 and data[2] > 0 and data[1] ~= data[2] then
					_skillname = _info.fullSkillName
					_skilldesc = _info.fullSkillNameDesc
				end
				-- 背景框
				local bg = display.newScale9Sprite(IMAGE_COMMON .. "tipbg.png"):addTo(node)
				bg:setPreferredSize(cc.size(300, 100)) 
				bg:setAnchorPoint(cc.p(anchor,0.4))
				bg:setPosition(0,node:getContentSize().height * 1.1)
				-- -- 名字
				local name = UiUtil.label(_skillname,FONT_SIZE_SMALL,COLOR[1]):addTo(bg)
				name:setAnchorPoint(0,0)
				name:setPosition(30,bg:getContentSize().height * 0.5 + 5)
				-- --desc
				local desc = UiUtil.label(_skilldesc,FONT_SIZE_SMALL,COLOR[1],cc.size(260, 0),ui.TEXT_ALIGN_LEFT):addTo(bg)
				desc:setAnchorPoint(0,1)
				desc:setPosition(30,bg:getContentSize().height * 0.5 + 5)
				node.tipNode_ = bg
			end

			return true
		elseif event.name == "ended" then
			node.tipNode_:removeSelf()
		end
	end)
end

function StaffConfigTableView:onExit()
	StaffConfigTableView.super.onExit(self)
	armature_remove("animation/effect/cmpz_tx_mc.pvr.ccz", "animation/effect/cmpz_tx_mc.plist", "animation/effect/cmpz_tx_mc.xml")

end

return StaffConfigTableView