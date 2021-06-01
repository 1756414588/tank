package com.game.datamgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticSign;
import com.game.domain.s.StaticSignLogin;
import com.game.util.RandomHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class StaticSignDataMgr extends BaseDataMgr {

    @Autowired
    private StaticDataDao staticDataDao;

    private Map<Integer, StaticSign> signMap = new HashMap<Integer, StaticSign>();

    private Map<Integer, List<StaticSignLogin>> signLoginMap =
            new HashMap<Integer, List<StaticSignLogin>>();

    @Override
    public void init() {
        signMap = staticDataDao.selectSign();

        this.iniSignLogin();
    }

    public void iniSignLogin() {
        List<StaticSignLogin> signLogins = staticDataDao.selectSignLogin();
        for (StaticSignLogin e : signLogins) {
            int grid = e.getGrid();
            List<StaticSignLogin> loginList = signLoginMap.get(grid);
            if (loginList == null) {
                loginList = new ArrayList<StaticSignLogin>();
                signLoginMap.put(grid, loginList);
            }
            loginList.add(e);
        }
    }

    public Map<Integer, StaticSign> getSignMap() {
        return signMap;
    }

    public StaticSign getSign(int signId) {
        return signMap.get(signId);
    }

    public StaticSignLogin getSignLoginByGrid(int grid) {
        List<StaticSignLogin> list = signLoginMap.get(grid);
        int seeds[] = {0, 0};
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
}
