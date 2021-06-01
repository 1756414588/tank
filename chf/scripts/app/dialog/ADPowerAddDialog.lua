
local Dialog = require("app.dialog.Dialog")
local ADPowerAddDialog = class("ADPowerAddDialog", Dialog)


function ADPowerAddDialog:ctor()
	ADPowerAddDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 360)})

end

function ADPowerAddDialog:onEnter()
	ADPowerAddDialog.super.onEnter(self)
	self:setOutOfBgClose(true)

	local bgm = display.newSprite(IMAGE_COMMON.."guide/role_1.png"):addTo(self:getBg()):align(display.LEFT_BOTTOM,22,self:getBg():height() - 10)

	local titLab = ui.newTTFLabel({text = CommonText.MuzhiAD[3][1], font = G_FONT, size = 28, 
		 color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	titLab:setAnchorPoint(cc.p(0.5, 0.5))
	titLab:setPosition(self:getBg():getContentSize().width / 2,310)

	local adLab = ui.newTTFLabel({text = "", font = G_FONT, size = 24, 
		 color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	adLab:setAnchorPoint(cc.p(0, 0.5))
	adLab:setString(string.format(CommonText.MuzhiAD[4][1],MZAD_ADD_POWER_MAX))
	adLab:setPosition(70,230)

	--提示
	local adLab1 = ui.newTTFLabel({text = "", font = G_FONT, size = 24, 
		 color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	adLab1:setAnchorPoint(cc.p(0, 0.5))
	adLab1:setPosition(70,180)
	adLab1:setString(string.format(CommonText.MuzhiAD[4][4],MZAD_ADD_POWER_MAX - MuzhiADMO.AddPowerADTime))
	self.adLab1 = adLab1


	-- 播放广告按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	self.m_adBtn = MenuButton.new(normal, selected, disabled, handler(self, self.playAdHandle)):addTo(self:getBg())  -- 确定
	self.m_adBtn:setLabel(CommonText.MuzhiAD[1][2])
	self.m_adBtn:setPosition(self:getBg():getContentSize().width / 2 , 80)
	self.m_adBtn.m_label:setPositionX(self.m_adBtn.m_label:getPositionX() + 20)
	display.newSprite(IMAGE_COMMON.."free.png"):addTo(self.m_adBtn):pos(45,58)
	display.newSprite(IMAGE_COMMON.."playAD.png"):addTo(self.m_adBtn):pos(75,50)

	self.m_adBtn:setVisible(MuzhiADMO.AddPowerADTime < MZAD_ADD_POWER_MAX)
	
end

function ADPowerAddDialog:playAdHandle()
	ServiceBO.playMzAD(MZAD_TYPE_VIDEO,function()
		Loading.getInstance():show()
		MuzhiADBO.PlayAddPowerAD(function()
			Loading.getInstance():unshow()
			self.adLab1:setString(string.format(CommonText.MuzhiAD[4][4],MZAD_ADD_POWER_MAX - MuzhiADMO.AddPowerADTime))
			self.m_adBtn:setVisible(MuzhiADMO.AddPowerADTime < MZAD_ADD_POWER_MAX)
		end)
		
	end)
end



return ADPowerAddDialog

