package com.account.plat.interfaces;

import com.account.domain.form.RoleLog;

/**
 * 角色升级时将角色信息发送到sdk
 */
public interface LogRoleUp2sdk {
    /**
     * 对应logevent中的subject
     */
    public final static String EVENT_SUBJECT = "LOG_ROLE_UP_2_GDPS";

    public void logRoleUp2sdk(RoleLog role);
}
