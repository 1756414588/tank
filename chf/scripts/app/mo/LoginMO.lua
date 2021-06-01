
-- LoginMO保留服务器的分服，以及登录的信息，进入游戏后只会加载一次

LoginMO = {}



NAME_MAX_LEN = 8
NAME_MIN_LEN = 2

-- 保存所有账号的文件
LoginMO.accountsFileName = "tank_acounts"

-- 本地保存的所有账号
local localAccounts_ = {}

local email_ = nil
local password_ = nil

-- local loginData_ = {} -- 登录数据
-- local registerData_ = {}  -- 注册数据

LoginMO.recentLogin_ = {}

LoginMO.baseVersion_ = ""
LoginMO.serverList_ = {}

LoginMO.roleNames_ = nil

LoginMO.isInLogin_ = false -- 表示当前是否是登录进了游戏中

LoginMO.blackList = {}

function LoginMO.getServerById(serverId)
	for _, server in pairs(LoginMO.serverList_) do
		if server.id == serverId then
			return server
		end
	end
end

function LoginMO.setLocalAccounts(accounts)
	if accounts then
		localAccounts_ = accounts
	end
end

function LoginMO.getLocalAccounts()
	return localAccounts_
end

function LoginMO.setEmail(email)
	email_ = email
end

function LoginMO.getEmail()
	return email_
end

function LoginMO.setPassword(password)
	password_ = password
end

function LoginMO.getPassword()
	return password_
end

-- function LoginMO.setLoginData(email, password)
-- 	loginData_.email = email
-- 	loginData_.password = password
-- end

-- function LoginMO.getLoginData()
-- 	return loginData_
-- end

-- function LoginMO.setRegisterData(registerData)
-- 	registerData_ = registerData
-- end

-- function LoginMO.getRegisterData()
-- 	return registerData_
-- end
