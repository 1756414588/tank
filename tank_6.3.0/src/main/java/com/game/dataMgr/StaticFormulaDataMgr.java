package com.game.dataMgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticFormula;
import com.game.util.LogUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * @author zhangdh
 * @ClassName: StaticFormulaDataMgr
 * @Description: 合成相关的静态数据
 * @date 2017/4/24 11:07
 */
@Component
public class StaticFormulaDataMgr extends BaseDataMgr {

    @Autowired
    private StaticDataDao staticDataDao;

    private Map<Integer, StaticFormula> flaMap;

    @Override
    public void init() {
        flaMap = staticDataDao.selectFormula();
    }

    /**
     * 获取指定ID的合成公式
     * @param fid
     * @return
     */
    public StaticFormula getFormula(int fid) {
        StaticFormula data = flaMap.get(fid);
        if (data == null) {
            LogUtil.error(String.format("not found formula id :%d", fid));
        }
        return data;
    }
}
