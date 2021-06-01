
-- 展示所有分服

require("app.text.LoginText")

local ServerTableView = class("ServerTableView", TableView)

local COL_NUM = 2

function ServerTableView:ctor(size, pageIndex)
	ServerTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 70)
	self.m_pageIndex = pageIndex

end

function ServerTableView:numberOfCells()
	local cellNum = 0
	local delta = #LoginMO.serverList_ - (self.m_pageIndex - 1) * AREA_PAGE_SERVER_NUM
	if delta >= AREA_PAGE_SERVER_NUM then -- 此页可以显示所有的服务器
		cellNum = math.ceil(AREA_PAGE_SERVER_NUM / COL_NUM)
	else
		cellNum = math.ceil(delta / COL_NUM)
	end
	-- gprint("cellNum:", cellNum)
	return cellNum
end

function ServerTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ServerTableView:createCellAtIndex(cell, index)
	ServerTableView.super.createCellAtIndex(self, cell, index)

	local totalNum = 0
	local delta = #LoginMO.serverList_ - (self.m_pageIndex - 1) * AREA_PAGE_SERVER_NUM
	if delta >= AREA_PAGE_SERVER_NUM then -- 此页可以显示所有的服务器
		totalNum = AREA_PAGE_SERVER_NUM
	else
		totalNum = #LoginMO.serverList_ - (self.m_pageIndex - 1) * AREA_PAGE_SERVER_NUM
	end

	local startIndex = (self.m_pageIndex - 1) * AREA_PAGE_SERVER_NUM + 1
	local endIndex = startIndex + totalNum - 1

	local firstIndex = endIndex - (index - 1) * COL_NUM
	local secondIndex = firstIndex - 1

	-- gprint("firstIndex:", firstIndex, "secondIndex:", secondIndex, "cellIndex:", index, "startIndex:", startIndex, "endIndex:", endIndex)

	local normal = display.newSprite(IMAGE_COMMON .. "login/btn_server_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "login/btn_server_selected.png")
	local btn = CellMenuButton.new(normal ,selected, nil, handler(self, self.onChoseServerCallback))
	btn.serverIndex = firstIndex
	cell:addButton(btn, 130, self.m_cellSize.height / 2)

	local server = LoginMO.serverList_[firstIndex]
	-- gdump(server, "ServerTableView first server")
	
	-- 名称
    local lab = ui.newTTFLabel({text = server.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 20, y = btn:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(btn)
    lab:setAnchorPoint(cc.p(0, 0.5))

   	local tag = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = btn:getContentSize().width - 20, y = btn:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
    
    if server.stop and server.stop == 1 then --维护
    	tag:setString(LoginText[59])
    	tag:setColor(COLOR[3])
    	lab:setColor(COLOR[11])
    elseif server.hot and server.hot == 1 then -- 热
    	tag:setString(LoginText[27])
    	tag:setColor(cc.c3b(235, 64, 100))
    	lab:setColor(COLOR[1])
	elseif server.new and server.new == 1 then -- 新
    	tag:setString(LoginText[28])
    	tag:setColor(cc.c3b(59, 219, 4))
    	lab:setColor(COLOR[1])
    end

    local hasRole = LoginBO.hasRoleInServer(server.id) -- 在这个服务器上有角色
    if hasRole then
    	local roleTag = display.newSprite(IMAGE_COMMON .. "icon_people.png"):addTo(btn)
    	roleTag:setPosition(4, btn:getContentSize().height - 6)
    	roleTag:setScale(0.8)
    end

	local server = LoginMO.serverList_[secondIndex]
	if server and secondIndex >= startIndex then
		local normal = display.newSprite(IMAGE_COMMON .. "login/btn_server_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "login/btn_server_selected.png")
		local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onChoseServerCallback))
		btn.serverIndex = secondIndex
		cell:addButton(btn, self.m_cellSize.width - 130, self.m_cellSize.height / 2)

		-- gdump(server, "ServerTableView second server")

        local lab = ui.newTTFLabel({text = LoginMO.serverList_[secondIndex].name, font = G_FONT, size = FONT_SIZE_SMALL, x = 20, y = btn:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER,color = COLOR[1]}):addTo(btn)
        lab:setAnchorPoint(cc.p(0, 0.5))
        
	   	local tag = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = btn:getContentSize().width - 20, y = btn:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
	    if server.stop and server.stop == 1 then --维护
	    	tag:setString(LoginText[59])
	    	tag:setColor(COLOR[3])
	    	lab:setColor(COLOR[11])
	    elseif server.hot and server.hot == 1 then -- 热
	    	tag:setString(LoginText[27])
	    	tag:setColor(cc.c3b(235, 64, 100))
	    	lab:setColor(COLOR[1])
		elseif server.new and server.new == 1 then -- 新
	    	tag:setString(LoginText[28])
	    	tag:setColor(cc.c3b(59, 219, 4))
	    	lab:setColor(COLOR[1])
	    end

	    local hasRole = LoginBO.hasRoleInServer(server.id) -- 在这个服务器上有角色
	    if hasRole then
	    	local roleTag = display.newSprite(IMAGE_COMMON .. "icon_people.png"):addTo(btn)
	    	roleTag:setPosition(4, btn:getContentSize().height - 6)
	    	roleTag:setScale(0.8)
	    end
	end

	return cell
end

function ServerTableView:onChoseServerCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self:dispatchEvent({name = "CHOSEN_SERVER_EVENT", serverIndex = sender.serverIndex})
end

return ServerTableView
