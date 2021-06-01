--
-- Author: Xiaohang
-- Date: 2016-08-31 17:05:03
--
-- 公告框
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, UI_ENTER_NONE)
	self.contentSize = size
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	local posY = self.m_cellSize.height - 5
	local text = self.data
	for i = 1, #text do
		local label = UiUtil.label(text[i].content,text[i].size,text[i].color,cc.size(self.m_cellSize.width-10, 0),ui.TEXT_ALIGN_LEFT)
			:addTo(cell,100):align(display.LEFT_TOP,4,posY)
		posY = posY - label:height() - 6
	end

	return cell
end

function ContentTableView:numberOfCells()
	return 1
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:updateUI(data)
	self.data = data
	local h = 0
	for i = 1, #data do
		local label = UiUtil.label(data[i].content,data[i].size,data[i].color,cc.size(self.contentSize.width-10, 0),ui.TEXT_ALIGN_LEFT)
		h = h + label:height() + 6
	end
	self.m_cellSize = cc.size(self.contentSize.width,h)
	self:reloadData()
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local NoticeDialog = class("NoticeDialog", Dialog)
local URL = "http://cdn.tank.hundredcent.com/faq/notice/%s/%s/category.json" --平台，渠道
-- tankId: 需要改装的tank
function NoticeDialog:ctor()
	NoticeDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(570, 570)})
	self:size(570,570)
end

function NoticeDialog:onEnter()
	NoticeDialog.super.onEnter(self)
	self:setTitle(CommonText[455])
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(540, 540))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	local bg = self:getBg()
	bg:y(bg:y()-50)
	display.newSprite(IMAGE_COMMON.."guide/role_1.png")
		:addTo(bg):align(display.LEFT_BOTTOM,22,bg:height())
	local tag = display.newSprite(IMAGE_COMMON .. "info_bg_27.jpg"):addTo(bg):pos(bg:width()/2,bg:height()-84)
	if not UserMO.noticeContent then
		self:httpRequest(string.format(URL,device.platform,LOGIN_PLATFORM_PARAM),function(data)
				local temp = json.decode(data)
				UserMO.noticeContent = {}
				for k,v in ipairs(temp) do
					local text = {content = v.title,url=v.cdn_address}
					UserMO.noticeContent[k] = {title = text}
				end
				self:getTitle()
			end)
	else
		self:getTitle()
	end
	self:setOutOfBgClose(true)
end

function NoticeDialog:getTitle()
	local bg = self:getBg()
	local view = ContentTableView.new(cc.size(510, self:getBg():height()-152),self.tankId,self.data)
		:addTo(bg,100):pos(37,36)
	local size = cc.size(500, 64)
	local pages = {}
	for i=1,4 do
		local temp = UserMO.noticeContent[i]
		if temp then
			pages[i] = temp.title.content
		else
			pages[i] = ""
		end
	end

	local function createYesBtnCallback(index)
		local button = nil
		if index == 1 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 - 182, size.height/2)
		elseif index == 2 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_12_selected.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_12_selected.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 - 70, size.height/2)
		elseif index == 3 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_12_selected.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_12_selected.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 + 70, size.height/2)
		elseif index == 4 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 + 182, size.height/2)
		end
		button:setLabel(pages[index])
		if index == 2 then
			button:getLabel():setPositionX(button:getLabel():getPositionX() + 10)
		elseif index == 3 then
			button:getLabel():setPositionX(button:getLabel():getPositionX() - 10)
		end
		button:addTouchHeight(30)
		return button
	end
	local function createNoBtnCallback(index)
		local button = nil
		if index == 1 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 - 182, size.height/2)
		elseif index == 2 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_12_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_12_normal.png")
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 - 70, size.height/2)
		elseif index == 3 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_12_normal.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_12_normal.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 + 70, size.height/2)
		elseif index == 4 then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
			normal:setScaleX(-1)
			local selected = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
			selected:setScaleX(-1)
			button = MenuButton.new(normal, selected, nil, nil)
			button:setPosition(size.width / 2 + 182, size.height/2)
		end
		button:setLabel(pages[index], {color = COLOR[11]})
		if index == 2 then
			button:getLabel():setPositionX(button:getLabel():getPositionX() + 10)
		elseif index == 3 then
			button:getLabel():setPositionX(button:getLabel():getPositionX() - 10)
		end
		button:addTouchHeight(30)
		if pages[index] == "" then
			button:setEnabled(false)
		end
		return button
	end

	local function createDelegate(container, index)
		-- require("app.text.DetailText")
		-- view:updateUI(DetailText.heroImprove)
		if not UserMO.noticeContent[index].content then
			self:httpRequest(UserMO.noticeContent[index].title.url,function(data)
					UserMO.noticeContent[index].content = {}
					local temp = json.decode(data)
					local text = nil
					for k,v in ipairs(temp) do
						if v[1] == "\r\n" or k == #temp then
							table.insert(UserMO.noticeContent[index].content,text)
							text = nil
						else
							if not text then
								text = {content=v[1],size=v[2],color=v[3] and cc.c3b(v[3][1], v[3][2], v[3][3]) or nil}
							else
								text.content = text.content .. v[1]
							end
						end
					end
					view:updateUI(UserMO.noticeContent[index].content)
				end)
		else
			view:updateUI(UserMO.noticeContent[index].content)
		end
	end

	local function clickDelegate(container, index)
	end

	local pageView = MultiPageView.new(MULTIPAGE_STYLE_DIY, size, pages, {x = bg:width()/2, y = bg:height()-82,
		createDelegate = createDelegate, clickDelegate = clickDelegate, styleDelegates = {createYesBtnCallback = createYesBtnCallback, createNoBtnCallback = createNoBtnCallback}, hideDelete = true}):addTo(bg, 2)
	pageView:setPageIndex(1)	
end

-- function NoticeDialog:onReturnCallback()
-- 	ManagerSound.playNormalButtonSound()
-- 	UiDirector.reset()
-- 	self:removeSelf()
-- end

function NoticeDialog:pop()
	ManagerSound.playNormalButtonSound()
	UiDirector.reset()
	self:removeSelf()
end

function NoticeDialog:httpRequest(url,rhand)
    local request = network.createHTTPRequest(function(event)
        	local request = event.request
        	Loading.getInstance():unshow()
        	if event.name == "completed" then
        	    if request:getResponseStatusCode() ~= 200 then
        	        local t = Toast.show("response code error " .. request:getResponseStatusCode())
        	    	t:setLocalZOrder(100000)
        	    else
        	        rhand(request:getResponseData())
        	    end
        	else
        	    local t = Toast.show("request error " .. request:getErrorCode())
        	    t:setLocalZOrder(100000)
        	end
        end, url, "GET")
    if request then
    	Loading.getInstance():show()
        request:setTimeout(30)
        request:start()
    end
end

function NoticeDialog:onExit()
	NoticeDialog.super.onExit(self)
end

return NoticeDialog
