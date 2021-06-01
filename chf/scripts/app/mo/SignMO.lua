--
-- Author: gf
-- Date: 2015-09-21 11:54:07
--

local s_sign = require("app.data.s_sign")
local s_sign_login = require("app.data.s_sign_login")

SignMO = {}

SignMO.signData_ = {}

SignMO.dailyLogin_ = {}

local db_sign_ = nil
local db_sign_login_ = nil

function SignMO.init()
	SignMO.signData_ = {}
	db_sign_ = nil

	if not db_sign_ then
		db_sign_ = {}

		local records = DataBase.query(s_sign)
		for index = 1, #records do
			local sign = records[index]
			db_sign_[sign.signId] = sign
		end
	end

	if not db_sign_login_ then
		db_sign_login_ = {}
		local records = DataBase.query(s_sign_login)
		for index = 1, #records do
			local data = records[index]
			db_sign_login_[data.loginId] = data
		end
	end
end

function SignMO.getSignData()
	return db_sign_
end

function SignMO.querySign(signId)
	return db_sign_[signId]
end

function SignMO.querySignLoginById(loginId)
	return db_sign_login_[loginId]
end

function SignMO.querySignLoginsByGrid(grid)
	local ret = {}
	for index = 1, #db_sign_login_ do
		local data = db_sign_login_[index]
		if data.grid == grid then
			ret[#ret + 1] = data
		end
	end
	return ret
end
