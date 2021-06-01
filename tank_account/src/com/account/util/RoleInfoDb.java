package com.account.util;

import java.util.List;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.account.dao.impl.RoleInfoDao;

/**
 * @author yeding
 * @create 2019/3/22 13:51
 */

@Component
public class RoleInfoDb {

    @Autowired
    private RoleInfoDao roleInfoDao;

    @PostConstruct
    public void init() {
        String tableName = "role_info";
        List<String> list = roleInfoDao.showTables();
        if (!list.contains(tableName)) {
            String creaTableSql = getCreaTableSql(tableName);
            roleInfoDao.createTable(creaTableSql);
        }
    }

    /**
     * 获取创建表sql
     *
     * @param tableName
     * @return
     */
    public String getCreaTableSql(String tableName) {
        String creaTableSql = "CREATE TABLE `role_info` (\n" +
                "  `roleId` bigint(20) NOT NULL COMMENT '玩家id',\n" +
                "  `accountKey` int(255) DEFAULT NULL COMMENT '账号服key',\n" +
                "  `roleName` varchar(255) DEFAULT NULL COMMENT '玩家昵称',\n" +
                "  `platNo` int(11) NOT NULL COMMENT '渠道号',\n" +
                "  `childNo` int(11) DEFAULT NULL COMMENT '子渠道',\n" +
                "  `serverId` int(128) DEFAULT NULL COMMENT '服务器id',\n" +
                "  `platId` varchar(128) NOT NULL COMMENT '渠道id',\n" +
                "  `level` int(255) DEFAULT NULL COMMENT '等级',\n" +
                "  `vip` int(255) DEFAULT NULL COMMENT 'vip',\n" +
                "  `topop` int(255) DEFAULT NULL COMMENT '总充值金额',\n" +
                "  `createTime` bigint(20) DEFAULT NULL COMMENT '创建时间',\n" +
                "  `loginDate` bigint(20) DEFAULT NULL COMMENT '最后登陆时间',\n" +
                "  UNIQUE KEY `roleId` (`roleId`) USING BTREE,\n" +
                "  KEY `platNo_platId` (`platNo`,`platId`)\n" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8;";
        return creaTableSql;
    }
}
