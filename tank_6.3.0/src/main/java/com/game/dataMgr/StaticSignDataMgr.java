package com.game.dataMgr;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticMonthSign;
import com.game.domain.s.StaticSign;
import com.game.domain.s.StaticSignLogin;
import com.game.util.LogUtil;
import com.game.util.RandomHelper;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-21 上午10:44:09
 * @Description: 签到相关配置
 */
@Component
public class StaticSignDataMgr extends BaseDataMgr {

	@Autowired
	private StaticDataDao staticDataDao;

	private Map<Integer, StaticSign> signMap = new HashMap<Integer, StaticSign>();

	private Map<Integer, List<StaticSignLogin>> signLoginMap = new HashMap<Integer, List<StaticSignLogin>>();

	//每月签到,KEY0:月份,KEY1:累计天数,签到奖励信息
	private Map<Integer, Map<Integer, StaticMonthSign>> monthSignMap = new HashMap<>();

	@Override
	public void init() {
		this.signMap = staticDataDao.selectSign();
		this.iniSignLogin();
		this.iniMonthSign();
	}

	public void iniSignLogin() {
		List<StaticSignLogin> signLogins = staticDataDao.selectSignLogin();
		Map<Integer, List<StaticSignLogin>> signLoginMap = new HashMap<Integer, List<StaticSignLogin>>();
		for (StaticSignLogin e : signLogins) {
			int grid = e.getGrid();
			List<StaticSignLogin> loginList = signLoginMap.get(grid);
			if (loginList == null) {
				loginList = new ArrayList<StaticSignLogin>();
				signLoginMap.put(grid, loginList);
			}
			loginList.add(e);
		}
		this.signLoginMap = signLoginMap;
	}

    /**
     * 加载每月签到数据
     */
	private void iniMonthSign() {
        Map<Integer, Map<Integer, StaticMonthSign>> monthMap = new TreeMap<>();
        Map<Integer, StaticMonthSign> dataMap = staticDataDao.selectMonthSign();
        for (Map.Entry<Integer, StaticMonthSign> entry : dataMap.entrySet()) {
            StaticMonthSign data = entry.getValue();
            Map<Integer, StaticMonthSign> dayMap = monthMap.get(data.getMonth());
            if (dayMap == null) monthMap.put(data.getMonth(), dayMap = new TreeMap<Integer, StaticMonthSign>());
            dayMap.put(data.getDay(), data);
        }
        Map<Integer, Map<Integer, StaticMonthSign>> monthSignMap0 = this.monthSignMap;
        this.monthSignMap = monthMap;
        monthSignMap0.clear();
    }

	public Map<Integer, StaticSign> getSignMap() {
		return signMap;
	}

	public StaticSign getSign(int signId) {
		return signMap.get(signId);
	}

	public StaticSignLogin getSignLoginByGrid(int grid) {
		List<StaticSignLogin> list = signLoginMap.get(grid);
		int seeds[] = { 0, 0 };
		for (StaticSignLogin e : list) {
			seeds[0] += e.getProbability();
		}
		seeds[0] = RandomHelper.randomInSize(seeds[0]);
		for (StaticSignLogin e : list) {
			seeds[1] += e.getProbability();
			if (seeds[0] <= seeds[1]) {
				return e;
			}
		}
		return null;
	}

    /**
     * 每月签到
     * @param month 月份
     * @param day 天数
     * @return
     */
	public StaticMonthSign getStaticMonthSign(int month, int day) {
        Map<Integer, StaticMonthSign> dayMap = monthSignMap.get(month);
        StaticMonthSign sign = dayMap != null ? dayMap.get(day) : null;
        if (sign == null) {
            LogUtil.error(String.format("not found month :%d, day :%d, sign info", month, day));
        }
        return sign;
    }

}
