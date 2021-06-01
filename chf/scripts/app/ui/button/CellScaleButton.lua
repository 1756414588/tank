-- 缩放按钮，touchBegan事件下button会缩放

local CellScaleButton = class("CellScaleButton", ScaleButton)

function CellScaleButton:ctor(touchSprite, tagCallback)
	CellScaleButton.super.ctor(self, touchSprite, tagCallback)
    self:setTouchEnabled(false)
end

function CellScaleButton:onCellTouch(event)
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
function CellScaleButton:onTouch(event, x, y)
	-- 此事件不可使用
	return false
end

function CellScaleButton:onExit()
    -- dump(self:getParent(), "???")
    if self._SCROLL_VIEW_ then
        self._SCROLL_VIEW_:_removeCellButton(self)
    end
end

return CellScaleButton
