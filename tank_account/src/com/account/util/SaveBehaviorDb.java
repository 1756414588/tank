package com.account.util;

import java.util.List;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.account.dao.impl.SaveBehaviorDao;

@Component
public class SaveBehaviorDb {

	@Autowired
	private SaveBehaviorDao saveBehaviorDao;

	@PostConstruct
	public void init() {
		String tableName = "s_bahavior_save";
		List<String> list = saveBehaviorDao.showTables();
		if (!list.contains(tableName)) {
			String creaTableSql = getCreaTableSql(tableName);
			saveBehaviorDao.createTable(creaTableSql);
		}
	}

	/**
	 * 获取创建表sql
	 *
	 * @param tableName
	 * @return
	 */
	public String getCreaTableSql(String tableName) {
		String creaTableSql = "CREATE TABLE `s_bahavior_save` (\n" +
                "  `deviceNo` varchar(255) DEFAULT NULL,\n" +
                "  `platName` varchar(255) DEFAULT NULL,\n" +
                "  `areaId` varchar(255) DEFAULT NULL,\n" +
                "  `lordId` varchar(255) DEFAULT NULL,\n" +
                "  `content` varchar(255) DEFAULT NULL\n" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8;";
		return creaTableSql;
	}

}
