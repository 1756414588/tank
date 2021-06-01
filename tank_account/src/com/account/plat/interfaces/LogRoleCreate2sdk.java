package com.account.plat.interfaces;

import com.account.domain.form.RoleLog;

/**
 * 登录时将角色信息发送到sdk
 */
public interface LogRoleCreate2sdk {
    /**
     * 对应logevent中的subject
     */
    public final static String EVENT_SUBJECT = "LOG_ROLE_CREATE_2_GDPS";

    public void logRoleCreate2sdk(RoleLog role);
}
