--
-- Author: gf
-- Date: 2015-09-16 18:35:45
-- 军情列表

local PartyTrendTableView = class("PartyTrendTableView", TableView)

function PartyTrendTableView:ctor(size,index)
	PartyTrendTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 90)

	self.trendType = index
	if self.trendType == PARTY_TREND_TYPE_1 then
		self.trends = PartyMO.trends_1
	else
		self.trends = PartyMO.trends_2
	end
end

function PartyTrendTableView:onEnter()
	PartyTrendTableView.super.onEnter(self)

	self.m_updateListHandler = Notify.register(LOCAL_PARTY_TREND_UPDATE_EVENT, handler(self, self.updateListHandler))
end

function PartyTrendTableView:numberOfCells()
	if #self.trends > 0 and #self.trends % 20 == 0 then
		return #self.trends + 1
	else
		return #self.trends
	end
end

function PartyTrendTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PartyTrendTableView:createCellAtIndex(cell, index)
	PartyTrendTableView.super.createCellAtIndex(self, cell, index)

	if #self.trends > 0 and #self.trends % 20 and index == #self.trends + 1 then
		local normal = display.newScale9Sprite(IMAGE_COMMON .. "btn_10_normal.png")
		normal:setPreferredSize(cc.size(600, 100))
		local selected = display.newScale9Sprite(IMAGE_COMMON .. "btn_10_selected.png")
		selected:setPreferredSize(cc.size(600, 100))
		local getNextButton = MenuButton.new(normal, selected, disabled, handler(self,self.getNextHandler)):addTo(cell)
		getNextButton:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
		getNextButton.page = (index - 1) / 20
		getNextButton:setLabel(CommonText[577])
	else
		local trend = self.trends[index]

		local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell, -1)
		bg:setPreferredSize(cc.size(550, 2))

		bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2 - 35)
		
		-- gdump(trend,"trend====")
		local time = ui.newTTFLabel({text = os.date("%x", trend.trendTime) .. "\n" .. os.date("%X", trend.trendTime), font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 0, y = self.m_cellSize.height / 2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		time:setAnchorPoint(cc.p(0, 0.5))

		local treadInfo = PartyMO.queryPartyTrend(trend.trendId)

		-- if treadInfo.trendId == 13 then
		-- 	trend.trendParam[4].content = UiUtil.strNumSimplify(tonumber(trend.trendParam[4].content))
		-- end

		local list = string.split(treadInfo.content, "|")  
		local labList = {}
		-- gdump(trend.trendParam,"trend.trendParam")
		gdump(list,"list=========")
		local parmIndex = 1
		local newline = {} --换行index
		for index = 1,#list do
			local isParam
			local man = nil
			local str = string.gsub(list[index], " ", "")
			if str == "%s" and trend.trendParam[parmIndex] then
				str = trend.trendParam[parmIndex].content
				isParam = true
				if table.isexist(trend.trendParam[parmIndex], "man") then
					man = trend.trendParam[parmIndex]["man"]
				end
				parmIndex = parmIndex + 1
			end
			local lab = ui.newTTFLabel({text = str, font = G_FONT, size = FONT_SIZE_SMALL - 2,color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			lab:setAnchorPoint(cc.p(0, 0.5))
			
			if isParam then
				lab:setColor(COLOR[2])
				if man then
					--加下划线
					local line = display.newRect(CCRect(lab:getContentSize().width / 2, 0, lab:getContentSize().width, 2))
					line:setLineColor(cc.c4f(120/255, 201/255, 22/255,1))
					line:setFill(true)
					lab:addChild(line)
					--添加点击事件
					nodeTouchEventProtocol(lab, function(event) 
						if event.name == "ended" then
	                        local player = {icon = man.icon, nick = man.nick, level = man.level, lordId = man.lordId, rank = man.ranks,
						        fight = man.fight, sex = man.sex, party = man.partyName, pros = man.pros, prosMax = man.prosMax}
						    require("app.dialog.PlayerDetailDialog").new(DIALOG_FOR_FRIEND, player):push()
						else
							return true
	                    end
					 end, nil, nil, true)
				end
			end
			local labPosX,labPosY
			if index == 1 then
				labPosX = 100
			else
				labPosX = labList[index - 1]:getPositionX() + labList[index - 1]:getContentSize().width
				local labEndX = labPosX + lab:getContentSize().width
				if labEndX > 480 then
					labPosX = 100
					newline[#newline + 1] = index
				end
			end
			lab:setPosition(labPosX,bg:getContentSize().height / 2 + 30)
			labList[#labList + 1] = lab
		end	
		gdump(newline,"newline===")
		gdump(labList,"labList===")

		for index = 1,#labList do
			local lab = labList[index]

			if #newline == 1 then
				if index < newline[1] then
					lab:setPosition(lab:getPositionX(),self.m_cellSize.height / 2 + 15)
				else
					lab:setPosition(lab:getPositionX(),self.m_cellSize.height / 2 - 15)
				end
			elseif #newline == 2 then
				if index < newline[1] then
					lab:setPosition(lab:getPositionX(),self.m_cellSize.height / 2 + 20)
				elseif index < newline[2] then
					lab:setPosition(lab:getPositionX(),self.m_cellSize.height / 2)
				else
					lab:setPosition(lab:getPositionX(),self.m_cellSize.height / 2 - 20)
				end
			else
				lab:setPosition(lab:getPositionX(),self.m_cellSize.height / 2)
			end
		end

		--分享按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_share_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_share_selected.png")
		local shareBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.shareHandler))
		cell:addButton(shareBtn, self.m_cellSize.width - 62, self.m_cellSize.height / 2)
		shareBtn.index = index
		shareBtn.labList = labList
	end

	return cell
end

function PartyTrendTableView:shareHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	--分享到聊天频道
	local labList = sender.labList
	local msg = ""
	for index = 1,#labList do
		local lab = labList[index]
		msg = msg .. lab:getString()
	end
	local cell = self:cellAtIndex(sender.index)
	local pos = {}
	local offect = self:getContentOffset()

	pos.x = self.m_cellSize.width - 100
	pos.y = offect.y + cell:getPositionY() + 110

	local ShareDialog = require("app.dialog.ShareDialog").new(SHARE_TYPE_PARTY_TREND, msg, pos):push()
end

function PartyTrendTableView:getNextHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	PartyBO.asynGetPartyTrend(function()
		Loading.getInstance():unshow()
		end, sender.page,self.trendType)
end


function PartyTrendTableView:updateListHandler(event)
	-- gdump(event,"eventeventeventevent")
	if self.trendType == PARTY_TREND_TYPE_1 then
		self.trends = PartyMO.trends_1
	else
		self.trends = PartyMO.trends_2
	end
	self:reloadData()
	if event.obj and event.obj.page > 0 then
		self:setContentOffset(cc.p(0,-event.obj.count * 90))
	end
end



function PartyTrendTableView:onExit()
	PartyTrendTableView.super.onExit(self)
	if self.m_updateListHandler then
		Notify.unregister(self.m_updateListHandler)
		self.m_updateListHandler = nil
	end
end



return PartyTrendTableView