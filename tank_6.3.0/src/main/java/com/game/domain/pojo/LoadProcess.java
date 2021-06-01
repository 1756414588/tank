package com.game.domain.pojo;

import com.game.util.LogUtil;

/**
 * 服务器启动时的加载进度信息
 *
 * @author Tandonghai
 * @date 2018-01-19 10:11
 */
public class LoadProcess {
    private int totalLord;
    private int loadedLord;
    private int totalData;
    private int loadedData;
    private int totalAccount;
    private int loadedAccount;

    private boolean canPrint(int loaded) {
        return loaded % 1000 == 0;
    }

    public int getTotalLord() {
        return totalLord;
    }

    public void setTotalLord(int totalLord) {
        this.totalLord = totalLord;
        LogUtil.start(String.format("已从数据库读取所有p_lord数据，total:%d", totalLord));
    }

    public int getLoadedLord() {
        return loadedLord;
    }

    public void setLoadedLord(int loadedLord) {
        this.loadedLord = loadedLord;
        if (canPrint(loadedLord)) {
            LogUtil.start(String.format("Lord数据加载进度, %d / %d", loadedLord, totalLord));
        }
    }

    public int getTotalData() {
        return totalData;
    }

    public void setTotalData(int totalData) {
        this.totalData = totalData;
        LogUtil.start(String.format("已从数据库读取所有p_data数据,total:%d", totalData));
    }

    public int getLoadedData() {
        return loadedData;
    }

    public void setLoadedData(int loadedData) {
        this.loadedData = loadedData;
        if (canPrint(loadedData)) {
            LogUtil.start(String.format("p_data数据加载进度,%d / %d", loadedData, totalData));
        }
    }

    public int getTotalAccount() {
        return totalAccount;
    }

    public void setTotalAccount(int totalAccount) {
        this.totalAccount = totalAccount;
        LogUtil.start(String.format("已从数据库读取所有p_account数据，total:%d", totalAccount));
    }

    public int getLoadedAccount() {
        return loadedAccount;
    }

    public void setLoadedAccount(int loadedAccount) {
        this.loadedAccount = loadedAccount;
        if (canPrint(loadedAccount)) {
            LogUtil.start(String.format("Account数据加载进度,%d / %d", loadedAccount, loadedAccount));
        }
    }
}
