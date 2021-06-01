package com.account.service;

import com.account.dao.impl.SaveBehaviorDao;
import com.account.domain.SaveBehavior;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * Created by pengshuo on 2019/3/11 11:50
 * <br>Description:
 * <br>Modified By:
 * <br>Version:
 *
 * @author pengshuo
 */
public class SaveBehaviorService {

    @Autowired
    private SaveBehaviorDao saveBehaviorDao;

    /**
     * insert
     * @param sb
     */
    public void insertBehavior(SaveBehavior sb) {
        saveBehaviorDao.save(sb);
    }
}
