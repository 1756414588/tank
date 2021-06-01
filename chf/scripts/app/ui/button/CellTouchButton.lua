-- 只能用于ScrollView中的cell内部的菜单按钮

local CellTouchButton = class("CellTouchButton", TouchButton)

function CellTouchButton:ctor(touchSprite, beganCallback, movedCallback, endedCallback, tagCallback)
	CellTouchButton.super.ctor(self, touchSprite, beganCallback, movedCallback, endedCallback, tagCallback)
    self:setTouchEnabled(false)
end

function CellTouchButton:onCellTouch(event)
	if not self:isVisible() or not self:isEnabled() then return false end

    if event.name == "began" then
        return self:onTouchBegan(event)
    elseif event.name == "moved" then
        self:onTouchMoved(event)
    elseif event.name == "ended" then
        self:onTouchEnded(event)
    else -- cancelled
        self:onTouchCancelled(event)
    end
end

-- 此事件不可使用
function CellTouchButton:onTouch(event, x, y)
	-- 此事件不可使用
	return false
end

function CellTouchButton:onExit()
    -- dump(self:getParent(), "???")
    if self._SCROLL_VIEW_ then
        self._SCROLL_VIEW_:_removeCellButton(self)
    end
end

return CellTouchButton
