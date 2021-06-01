--
-- Author: gf
-- Date: 2015-12-09 15:48:09
--


local SystemMailTableView = class("SystemMailTableView", TableView)

function SystemMailTableView:ctor(size,  mail)
	SystemMailTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	
	self.m_mail = mail
	

	local height = 600

	if self.m_mail.award and #self.m_mail.award > 0 then
		height = height + math.ceil(#self.m_mail.award / 5) * 130
	end
	
	self.m_cellSize = cc.size(size.width, height)
end

function SystemMailTableView:reloadData()
	SystemMailTableView.super.reloadData(self)
end

function SystemMailTableView:numberOfCells()
	return 1
end

function SystemMailTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function SystemMailTableView:createCellAtIndex(cell, index)
	SystemMailTableView.super.createCellAtIndex(self, cell, index)

	-- 标题
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(20, self.m_cellSize.height - 40)

	local title = ui.newTTFLabel({text = self.m_mail.title, font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	local contentLab = ui.newTTFLabel({text = self.m_mail.contont, font = G_FONT, size = FONT_SIZE_SMALL, 
   		x = -220, y = self.m_cellSize.height - 70, color = COLOR[1], 
   		align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,
   		dimensions = cc.size(510, 573)}):addTo(cell)
	contentLab:setAnchorPoint(cc.p(0, 1))

	if self.m_mail.award and #self.m_mail.award > 0 then
		-- 附件奖励
		local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell)
		bg:setAnchorPoint(cc.p(0, 0.5))
		bg:setPosition(20, self.m_cellSize.height - 300)

		local title = ui.newTTFLabel({text = CommonText[689], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

		-- 74 消灭叛军奖励 127 消灭匪徒奖励 128 匪徒消失
		if self.m_mail.moldId == 74 or self.m_mail.moldId == 127 or self.m_mail.moldId == 128 then
			--奖励列表
			local ReportRewardTableView = require("app.scroll.ReportRewardTableView")
			local view = ReportRewardTableView.new(cc.size(self.m_cellSize.width - 40, 140), self.m_mail.award, true, true):addTo(cell)
			view:setAnchorPoint(cc.p(0,0.5))
			view:setPosition(20 , bg:getPositionY() - bg:getContentSize().height * 0.5 - view:getContentSize().height * 0.5)
		else
			--奖励列表
			for index=1,#self.m_mail.award do
				local award = self.m_mail.award[index]
				local itemView = UiUtil.createItemView(award.type, award.id, {count = award.count})
				if award.type == ITEM_KIND_EQUIP then
					itemView = UiUtil.createItemView(award.type, award.id, {count = award.count,star = award.param[2],equipLv = award.param[1]})
				end
				local _scale = 0.7 
				if award.type == ITEM_KIND_HERO or award.type == ITEM_KIND_AWAKE_HERO or 
					(award.type == ITEM_KIND_PORTRAIT and award.id >= 32 and award.id <= 34) then 
					_scale = 0.48
				end
				itemView:setScale(_scale)
				if itemView.heroName_ then itemView.heroName_:removeSelf() itemView.heroName_ = nil end
				itemView:setPosition(5 + ((index - 1) % 5 + 1 - 0.5) * ((self.m_cellSize.width - 10) / 5) ,
									 self.m_cellSize.height - 380 - math.floor((index - 1) / 5) * 125)
				self:chechAndUpLoadParam(itemView,award)
				cell:addChild(itemView)
				UiUtil.createItemDetailButton(itemView,cell,true)
				local propDB = UserMO.getResourceData(award.type, award.id)
				local nameStr = propDB.name
				if award.type == ITEM_KIND_PROP or award.type == ITEM_KIND_RED_PACKET then nameStr = propDB.name2 end
				local name = ui.newTTFLabel({text = nameStr, font = G_FONT, size = FONT_SIZE_TINY, 
					x = itemView:getPositionX(), y = itemView:getPositionY() - 50, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			end
		end
	end


	return cell
end

-- 处理奖励的扩展信息
function SystemMailTableView:chechAndUpLoadParam(item,awarddata)
	if awarddata.type == ITEM_KIND_AWAKE_HERO then -- 觉醒将领
		if table.isexist(awarddata, "param") then
			local hero = HeroMO.queryHero(awarddata.id)
			local awakeSkill = {}
			if hero.awakenSkillArr then
				awakeSkill = {}
				awakeSkill = json.decode(hero.awakenSkillArr)
			else
				hero = HeroMO.queryHero(hero.awakenHeroId)
				awakeSkill = {}
				awakeSkill = json.decode(hero.awakenSkillArr)
			end
			local outdata = {skillInfo = {}}
			
			for index = 1, #awakeSkill do
				local out = {}
				out.key = awakeSkill[index]
				out.value = awarddata.param[index]
				outdata.skillInfo[#outdata.skillInfo + 1] = out
			end
			item.param = outdata
		end
	elseif awarddata.type == ITEM_KIND_WEAPONRY_ICON then -- 军备
		if table.isexist(awarddata, "param") then
			local out = {}
			out.skillInfo = awarddata.param
			item.param = out
		end
	end
end


return SystemMailTableView
