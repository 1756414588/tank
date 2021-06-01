package com.account.plat.interfaces;

import com.account.domain.form.RoleLog;

/**
 * 创建角色时将角色信息发送到sdk
 */
public interface LogRoleLogin2sdk {
    /**
     * 对应logevent中的subject
     */
    public final static String EVENT_SUBJECT = "LOG_ROLE_LOGIN_2_GDPS";

    public void logRoleLogin2sdk(RoleLog role);
}
