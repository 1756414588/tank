--
--
-- 作战实验室
-- 
-- MYS

local LaboratoryView = class("LaboratoryView",UiNode)

function LaboratoryView:ctor(buildingId)
	LaboratoryView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_buildingId = buildingId
end

function LaboratoryView:onEnter()
	LaboratoryView.super.onEnter(self)
	-- 物资
	local buildinfo = BuildMO.queryBuildById(self.m_buildingId)
	self:setTitle(buildinfo.name)


	local function createDelegate(container, index)
		if index == 1 then
			self:onContainer1(container)
		elseif index == 2 then
			self:onContainer2(container)
		elseif index == 3 then
			self:onContainer3(container)
		elseif index == 4 then
			self:onContainer4(container)
		end
	end

	local function clickDelegate(container, index)

	end

	local function clickBaginDelegate(index)
		if index == 2 then
			if not UserMO.queryFuncOpen(UFP_LABORATORY_2) then
				Toast.show(CommonText[1722])
				return false
			end
		elseif index == 3 then
			if not UserMO.queryFuncOpen(UFP_LABORATORY_3) then
				Toast.show(CommonText[1722])
				return false
			end
		end
		return true
	end

	-- 
	local pages = CommonText[1761]
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, clickBaginDelegate = clickBaginDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView

	TriggerGuideMO.currentStateId = 92
	Notify.notify(LOCAL_SHOW_NEWER_GUIDE_TRIGGER_EVENT)

end

-- 研究院
function LaboratoryView:onContainer1(container)
	local LaboratoryForAcademeView = require("app.view.LaboratoryForAcademeView")
	local size = cc.size(container:width(), container:height())
	local view = LaboratoryForAcademeView.new(size, self):addTo(container, 1)
	self.m_view1 = view
end

-- 兵种调配所
function LaboratoryView:onContainer2(container)
	local LaboratoryForDeployment = require("app.view.LaboratoryForDeployment")
	local size = cc.size(container:width(), container:height())
	local view = LaboratoryForDeployment.new(size, self):addTo(container, 1)
end

-- 谍报机构
function LaboratoryView:onContainer3(container)
	local LaboratoryForLurkView = require("app.view.LaboratoryForLurkView")
	local size = cc.size(container:width() + 8, container:height() + 34)
	local view = LaboratoryForLurkView.new(size, self):addTo(container, 1)
	view:setPosition( -4,-34)

	local canReward = false
	LaboratoryBO.GetFightLabSpyInfo(function (data)
		local spys = PbProtocol.decodeArray(data["spyinfo"])
		for k , v in pairs(spys) do
			if v.state == 4 then
				canReward = true
				break
			end
		end
	end)

	local function fresh()
		if view then
			self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
			canReward = false
		end
	end

	--一键领取
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local btn = MenuButton.new(normal, selected, disabled, function ()
		ManagerSound.playNormalButtonSound()
		if canReward then
			LaboratoryBO.getAllTaskReward(function (data)
				require("app.dialog.LaboratoryAwardDialog").new(data, fresh):push()		
			end)
		else
			Toast.show(CommonText[1149])
		end
	end):addTo(container,10)
	btn:setPosition(container:width() / 2, 20)
	btn:setLabel(CommonText[100026])
end

-- 储物间
function LaboratoryView:onContainer4(container)
	-- body 
	local LaboratoryForStorageView = require("app.view.LaboratoryForStorageView")
	local size = cc.size(container:width(), container:height())
	local view = LaboratoryForStorageView.new(size, self):addTo(container, 1)
end

function LaboratoryView:TriggerGuideOpenPerson()
	if self.m_view1 then
		self.m_view1:OpenPersonnelAllotment()
	end
end

function LaboratoryView:TriggerGuideConstruction()
	if self.m_view1 then
		self.m_view1:OpenConstructionImprovement()
	end
end

return LaboratoryView