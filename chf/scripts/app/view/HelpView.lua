--
-- Author: Xiaohang
-- Date: 2016-08-25 15:51:19
--
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, UI_ENTER_NONE)
	self.contentSize = size
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	if self.kind == 1 then
		local t = display.newSprite(IMAGE_COMMON.."star_3.png")
			:addTo(cell):pos(12,self.m_cellSize.height/2)
		local msg = RichLabel.new(self.data[index].title, cc.size(self.m_cellSize.width, 0)):addTo(cell,100)
			:align(display.LEFT_CENTER,50,self.m_cellSize.height/2+12)
		local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
		line:setPreferredSize(cc.size(580, line:getContentSize().height))
		line:setPosition(self.m_cellSize.width / 2, 0)
	else
		local posY = self.m_cellSize.height - 5
		local text = self.data
		for i = 1, #text do
			local label = UiUtil.label(text[i].content,text[i].size,text[i].color,cc.size(self.m_cellSize.width-10, 0),ui.TEXT_ALIGN_LEFT)
				:addTo(cell,100):align(display.LEFT_TOP,14,posY)
			posY = posY - label:height() - 6
		end
	end
	return cell
end

function ContentTableView:numberOfCells()
	return self.kind == 1 and #self.data or 1
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:updateUI(data,kind)
	self.kind = kind
	self.data = data
	if kind == 1 then
		self.m_cellSize = cc.size(self.contentSize.width,60)
	else
		local h = 0
		for i = 1, #data do
			-- local label = RichLabel.new(data[i], cc.size(self.m_cellSize.width, 0))
			local label = UiUtil.label(data[i].content,data[i].size,data[i].color,cc.size(self.m_cellSize.width-10, 0),ui.TEXT_ALIGN_LEFT)
			h = h + label:height() + 6
		end
		self.m_cellSize = cc.size(self.contentSize.width,h)
	end
	self:reloadData()
end
---------------------------

local HelpView = class("HelpView", UiNode)
local URL = "http://cdn.tank.hundredcent.com/faq/FAQ/category.json"
function HelpView:ctor()
	HelpView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
end

function HelpView:onEnter()
	HelpView.super.onEnter(self)
	self:setTitle(CommonText[20108])
	self.close = UiUtil.button("btn_close_normal.png","btn_close_selected.png",nil,handler(self, self.back))
		:addTo(self):pos(display.width - 27,display.height - 42)
	self.close:setVisible(false)
	local t = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(self):pos(display.cx,display.height-100)
	self.title = UiUtil.label(CommonText[20108]):addTo(t):center()

	self.view = ContentTableView.new(cc.size(584, display.height-150))
		:addTo(self):pos(33,30)
	if not UserMO.helpContent then
		self:httpRequest(URL,function(data)
				local temp = json.decode(data)
				UserMO.helpContent = {}
				for k,v in ipairs(temp) do
					local text = {{content = v.title[1],color = cc.c3b(v.title[3][1], v.title[3][2], v.title[3][3]),size = v.title[2],underline=true,url=v.cdn_address,click = function()
							self:goto(v.cdn_address,v.title[1],k)
						end}}
					UserMO.helpContent[k] = {title = text}
				end
				self.view:updateUI(UserMO.helpContent,1)
			end)
	else
		for k,v in ipairs(UserMO.helpContent) do
			v.title[1].click = function()
				self:goto(v.title[1].url,v.title[1].content,k)
			end
		end
		self.view:updateUI(UserMO.helpContent,1)
	end
end

function HelpView:goto(url,name,index)
	self.title:setString(name)
	self.close:show()
	if not UserMO.helpContent[index].content then
		self:httpRequest(url,function(data)
				UserMO.helpContent[index].content = {}
				local temp = json.decode(data)
				local text = nil
				for k,v in ipairs(temp) do
					if v[1] == "\r\n" or k == #temp then
						table.insert(UserMO.helpContent[index].content,text)
						text = nil
					else
						-- table.insert(text,{content=v[1],size=v[2],color=v[3] and cc.c3b(v[3][1], v[3][2], v[3][3]) or nil})
						if not text then
							text = {content=v[1],size=v[2],color=v[3] and cc.c3b(v[3][1], v[3][2], v[3][3]) or nil}
						else
							text.content = text.content .. v[1]
						end
					end
				end
				self.view:updateUI(UserMO.helpContent[index].content,2)
			end)
	else
		self.view:updateUI(UserMO.helpContent[index].content,2)
	end
end

function HelpView:back()
	self.close:hide()
	self.view:updateUI(UserMO.helpContent,1)
end

function HelpView:httpRequest(url,rhand)
    local request = network.createHTTPRequest(function(event)
        	local request = event.request
        	Loading.getInstance():unshow()
        	if event.name == "completed" then
        	    if request:getResponseStatusCode() ~= 200 then
        	        Toast.show("response code error " .. request:getResponseStatusCode())
        	    else
        	        rhand(request:getResponseData())
        	    end
        	else
        	    Toast.show("request error " .. request:getErrorCode())
        	end
        end, url, "GET")
    if request then
    	Loading.getInstance():show()
        request:setTimeout(30)
        request:start()
    end
end

return HelpView