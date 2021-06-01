
SecretaryBO = {}

function SecretaryBO.updateWild()
	if not SecretaryBO.isOpen() then return end

	SecretaryMO.emptyWildTip_ = {}

	for index = 1, #HomeBuildWildConfig do
		-- print("index:", index, BuildBO.isWildOpen(index), "has:", BuildMO.hasMillAtPos(index))
		if BuildBO.isWildOpen(index) and not BuildMO.hasMillAtPos(index) then  -- 有空位
			SecretaryMO.emptyWildTip_[index] = {pos = index, ingore = false}
		end
	end
	gdump(SecretaryMO.emptyWildTip_, "SecretaryBO.updateWild")
end

function SecretaryBO.isOpen()
	if UserMO.level_ < SECRETARY_OPEN_LEVEL then return true
	else return false end
end

function SecretaryBO.getWildTip()
	if not SecretaryBO.isOpen() then return end

	for _, tip in pairs(SecretaryMO.emptyWildTip_) do
		if not tip.ingore then  -- 不忽略
			return tip
		end
	end
	return nil
end

function SecretaryBO.ingoreAllWildTip()
	if not SecretaryBO.isOpen() then return end

	for _, tip in pairs(SecretaryMO.emptyWildTip_) do
		tip.ingore = true
	end
end

function SecretaryBO.update()
	if not SecretaryBO.isOpen() then return end

	for index = 1, #HomeBuildWildConfig do
		-- print("index:", index, BuildBO.isWildOpen(index), "has:", BuildMO.hasMillAtPos(index))
		if BuildBO.isWildOpen(index) then
			if not BuildMO.hasMillAtPos(index) then  -- 有空位
				if not SecretaryMO.emptyWildTip_[index] then
					SecretaryMO.emptyWildTip_[index] = {pos = index, ingore = false}
				end
			else
				if SecretaryMO.emptyWildTip_[index] then
					SecretaryMO.emptyWildTip_[index] = nil
				end
			end
		end
	end
end
