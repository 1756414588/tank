--
--
-- 显示红包 及 列表
--
--
local TookRedPacketTableView = class("TookRedPacketTableView",TableView)

function TookRedPacketTableView:ctor(size,datalist, maxNum)
	TookRedPacketTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 80)
	self.m_datalist = datalist
	self.m_maxNum = maxNum 
-- 	//抢红包信息
-- message GrabRedBag{
-- 	optional string lordName = 1;               //抢红包的玩家名
	-- optional int32 portrait = 2;               //玩家角色头像
 --    optional int32 grabMoney = 3;               //抢到的金额
 --    optional int64 grabTime = 4;                //抢红包时间(单位:ms)
-- }
end

function TookRedPacketTableView:onEnter()
	TookRedPacketTableView.super.onEnter(self)

	self.m_kingIndex = 0

	local function mysort(a, b)
		if a.grabTime == b.grabTime then
			return a.grabMoney > b.grabMoney
		else
			return a.grabTime < b.grabTime
		end
	end

	table.sort(self.m_datalist, mysort)

	if self:numberOfCells() >= self.m_maxNum then
		local coin = 0
		for index = 1, self:numberOfCells() do
			local _d = self.m_datalist[index]
			if _d.grabMoney > coin then
				coin = _d.grabMoney
				self.m_kingIndex = index
			end
		end
	end

	self:reloadData()
end

function TookRedPacketTableView:numberOfCells()
	return #self.m_datalist
end

function TookRedPacketTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function TookRedPacketTableView:createCellAtIndex(cell, index)
	TookRedPacketTableView.super.createCellAtIndex(self, cell, index)
	local _data = self.m_datalist[index]
	-- dump(_data)
	local portrait = _data.portrait

	if portrait >= 100 then
		local q, p = UserBO.parsePortrait(portrait)  -- 有头像和挂件
		portrait = q
	end

	-- 头像
	local item = UiUtil.createItemSprite(ITEM_KIND_PORTRAIT, portrait):addTo(cell)
	item:setScale(0.40)
	item:setPosition(40, self.m_cellSize.height * 0.5)


 	-- 名字
	local namelb = ui.newTTFLabel({text = _data.lordName , font = G_FONT, size = 20, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(0, 0, 0)}):addTo(cell)
	namelb:setAnchorPoint(cc.p(0,0.5))
    namelb:setPosition(85 , self.m_cellSize.height * 0.5 + 15)

    -- 时间
	local timeStr = os.date("%m-%d %H:%M:%S", math.floor(_data.grabTime / 1000))
	local timelb = ui.newTTFLabel({text = tostring(timeStr), font = G_FONT, size = 16, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(0, 0, 0)}):addTo(cell)
	timelb:setAnchorPoint(cc.p(0, 0.5))
    timelb:setPosition(85 , self.m_cellSize.height * 0.5 - 15)

    -- 金额 
    local coinsp = display.newSprite(IMAGE_COMMON .. "icon_coin.png"):addTo(cell)
    coinsp:setPosition(self.m_cellSize.width - 60 , self.m_cellSize.height * 0.5 + 20 - 3 )
    coinsp:setScale(0.75)

    local getCoinLabel = ui.newBMFontLabel({text = "", font = "fnt/num_3.fnt", x = coinsp:x() + 15 , y = self.m_cellSize.height * 0.5 + 20, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	getCoinLabel:setAnchorPoint(cc.p(0, 0.5))
	getCoinLabel:setScale(0.6)
	getCoinLabel:setString(_data.grabMoney)

    -- 运气王
    local luckyking = display.newSprite(IMAGE_COMMON .. "toplucky.png"):addTo(cell)
    luckyking:setPosition(self.m_cellSize.width - luckyking:width() * 0.5 , self.m_cellSize.height * 0.5 - 10)
    luckyking:setScale(0.85)
    if self.m_kingIndex ~= index then luckyking:setVisible(false) end

    -- line
    local line = display.newSprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
    line:setPosition(self.m_cellSize.width * 0.5, 0)
    line:setScaleX(self.m_cellSize.width / line:width())

	return cell
end







--------------------------------------------------------------

local Dialog = require("app.dialog.DialogEx")
local RedPacketInfoDialog = class("RedPacketInfoDialog",Dialog)

function RedPacketInfoDialog:ctor(data)
	RedPacketInfoDialog.super.ctor(self)
	self.m_packetData = data
	
	if self.m_packetData.grabMoney > 0 then
		self.__cname = "RedPacketInfoDialogTake"
		if UiDirector.getTopUiName() == self.__cname then
			UiDirector.pop()
		end
	else
		self.__cname = "RedPacketInfoDialogList"
	end
end


function RedPacketInfoDialog:onEnter()
	RedPacketInfoDialog.super.onEnter(self)

	if self.m_packetData.grabMoney > 0 then
		-- 打开红包
		self:showTakeRedPacketContainer()
	else
		-- 查看红包列表
		self:showtookListRedPacketContainer()
	end
end
-------------------------------------------------------- 获得红包
function RedPacketInfoDialog:showTakeRedPacketContainer()
	-- body
	armature_add(IMAGE_ANIMATION .. "effect/tk_kaihongbao.pvr.ccz", IMAGE_ANIMATION .. "effect/tk_kaihongbao.plist", IMAGE_ANIMATION .. "effect/tk_kaihongbao.xml")

	local effect = armature_create("tk_kaihongbao", display.cx,display.cy, function (movementType, movementID, armature) 
			if movementType == MovementEventType.COMPLETE then
				self:getRedPacketAction()
			end
		end):addTo(self)
	effect:getAnimation():playWithIndex(0)

	self:showTakeRedPacket()
end

function RedPacketInfoDialog:getRedPacketAction()
	-- body
	if self.m_viewbg then
		self.m_viewbg:setVisible(true)
	end

	if self.m_packetData.statsAward then
		UiUtil.showAwards(self.m_packetData.statsAward)
		self.m_packetData.statsAward = nil
	end
end

function RedPacketInfoDialog:showTakeRedPacket()
	local viewbg = display.newNode():addTo(self, 5)
	viewbg:setVisible(false)
	self.m_viewbg = viewbg
	local showbg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_84.png"):addTo(viewbg)
	showbg:setPreferredSize(cc.size(265, 220))
	showbg:setPosition(display.cx, display.cy - showbg:height() * 0.4 )


	local desclb = ui.newTTFLabel({text = CommonText[1030][1] , font = G_FONT, size = 26, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(showbg)
    desclb:setPosition(showbg:width() * 0.5 , showbg:height() - 30)

    local desclb2 = ui.newTTFLabel({text = UserMO.nickName_ .. CommonText[381] .. " " .. self.m_packetData.grabMoney, font = G_FONT, size = 20, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(showbg)
    desclb2:setPosition(showbg:width() * 0.5 , desclb:y() - 30)

    local coinsp = display.newSprite(IMAGE_COMMON .. "icon_coin.png"):addTo(showbg)
    coinsp:setAnchorPoint(cc.p(0,0.5))
    coinsp:setPosition(desclb2:x() + desclb2:width() * 0.5, desclb2:y())

    local function closeCallback()
    	self:close()
    end

	local nomal = display.newSprite(IMAGE_COMMON .. "btn_66_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_66_selected.png")
	local getbtn = MenuButton.new(nomal,selected,nil,closeCallback):addTo(showbg)
	getbtn:setScaleX(275 / getbtn:width())
	getbtn:setScaleY(0.8)
	getbtn:setPosition(showbg:width() * 0.5 , showbg:height() - 140)


	local btnLb = ui.newTTFLabel({text = CommonText[1787], font = G_FONT, size = 24, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(showbg)
    btnLb:setPosition(getbtn:x() , math.floor(getbtn:y() + 8))

	self.m_outOfBgClose = true

end

----------------------------------------------------- 红包列表
function RedPacketInfoDialog:showtookListRedPacketContainer()
	local viewbg = display.newSprite(IMAGE_COMMON .. "info_bg_136.jpg"):addTo(self, 5)
	viewbg:setPosition(display.cx,display.cy)
	self.m_viewbg = viewbg

	local theData = self.m_packetData.redBag 				-- 数据

	local portrait = theData.portrait
	local datalist = PbProtocol.decodeArray(theData.grab)	-- 列表
	local allPeople = theData.grabCnt 						-- 总人数
	local sendTime = theData.sendTime 						-- 发送时间

	local curPeople = #datalist

	if portrait >= 100 then
		local q, p = UserBO.parsePortrait(portrait)  -- 有头像和挂件
		portrait = q
	end
	-- touxiang
	local item = UiUtil.createItemSprite(ITEM_KIND_PORTRAIT, portrait):addTo(viewbg)
	item:setScale(0.65)
	item:setPosition(viewbg:width() * 0.5, viewbg:height() - 130)

	-- name 
	local namelb = ui.newTTFLabel({text = theData.lordName, font = G_FONT, size = 24, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 255, 255)}):addTo(viewbg)
    namelb:setPosition(viewbg:width() * 0.5 , viewbg:height() - 50)

    -- 人数
    local peoplelb = ui.newTTFLabel({text = curPeople .. "/" .. allPeople .. "人", font = G_FONT, size = 20, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(0, 0, 0)}):addTo(viewbg)
    peoplelb:setAnchorPoint(cc.p(0,0.5))
    peoplelb:setPosition(10 , viewbg:height() - 210)

    -- time
    local timeStr = os.date("%m-%d %H:%M:%S", math.floor(sendTime / 1000))
    local timelb = ui.newTTFLabel({text = tostring(timeStr), font = G_FONT, size = 20, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(0, 0, 0)}):addTo(viewbg)
    timelb:setAnchorPoint(cc.p(1,0.5))
    timelb:setPosition(viewbg:width() - 10 , viewbg:height() - 210)

    -- list
	local size = cc.size(self.m_viewbg:width() - 2, 366)
	local view = TookRedPacketTableView.new(size, datalist, allPeople):addTo(viewbg)
	view:setPosition(1,0)
	view:drawBoundingBox()

	self.m_outOfBgClose = true
end

function RedPacketInfoDialog:onExit()
	RedPacketInfoDialog.super.onExit(self)
	if self.m_packetData.grabMoney > 0 then
		armature_remove(IMAGE_ANIMATION .. "effect/tk_kaihongbao.pvr.ccz", IMAGE_ANIMATION .. "effect/tk_kaihongbao.plist", IMAGE_ANIMATION .. "effect/tk_kaihongbao.xml")
	end
end

function RedPacketInfoDialog:close()
	if self.m_packetData.grabMoney > 0 then
		if self.m_packetData.statsAward then
			UiUtil.showAwards(self.m_packetData.statsAward)
			self.m_packetData.statsAward = nil
		end
	end

	Notify.notify("LOCAL_REDPACKET_UPDATE_HANDLER") -- 重新刷新红包列表
	RedPacketInfoDialog.super.close(self)
end

return RedPacketInfoDialog