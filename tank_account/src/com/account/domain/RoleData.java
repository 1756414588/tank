package com.account.domain;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import com.account.util.CheckNull;
import com.alibaba.fastjson.JSON;

/**
 * @author TanDonghai
 * @ClassName RoleData.java
 * @Description TODO
 * @date 创建时间：2016年7月20日 下午6:27:37
 */
public class RoleData {
    private int accountKey;// 对应p_account表中的keyId字段

    private String roles;// 玩家的所有已创建的角色信息

    private boolean searched;// 是否已经全服查找过玩家的角色信息，如果为true，以后将不再查找

    private List<Role> roleList;

//	private Set<String> lordIdSet = new HashSet<>();// 记录所有角色的lordId

    private Set<String> serverIdSet = new HashSet<>();// 记录所有角色的区服

    public int getAccountKey() {
        return accountKey;
    }

    public void setAccountKey(int accountKey) {
        this.accountKey = accountKey;
    }

    public String getRoles() {
        return roles;
    }

    public void setRoles(String roles) {
        this.roles = roles;
    }

    public boolean isSearched() {
        return searched;
    }

    public void setSearched(boolean searched) {
        this.searched = searched;
    }

    /**
     * 新增角色信息记录
     *
     * @param role
     */
    public void addRole(Role role) {
        if (serverIdSet.contains(role.getServer_id())) {
            return;
        }

        if (getRoleList().size() > 100) {
            getRoleList().clear();
        }
        getRoleList().add(role);
        serverIdSet.add(role.getServer_id());
        roles = JSON.toJSONString(roleList);
    }

    public List<Role> getRoleList() {
        if (null == roleList) {
            roleList = new ArrayList<>();
            if (!CheckNull.isNullTrim(roles)) {
                roleList.addAll(JSON.parseArray(roles, Role.class));
                for (Role role : roleList) {
                    serverIdSet.add(role.getServer_id());
                }
            }
        }
        return roleList;
    }

    public void setRoleList(List<Role> roleList) {
        this.roleList = roleList;

        serverIdSet.clear();
        for (Role role : roleList) {
            serverIdSet.add(role.getServer_id());
        }
    }


    public Set<String> getServerIdSet() {
        getRoleList();
        return serverIdSet;
    }

    public Role getRoleByServerId(String serverId) {
        for (Role role : roleList) {
            if (role.getServer_id().equalsIgnoreCase(serverId)) {
                return role;
            }
        }
        return null;
    }

    public void updateRoles() {
        if (!CheckNull.isEmpty(roleList)) {
            roles = JSON.toJSONString(roleList);
        }
    }
}
