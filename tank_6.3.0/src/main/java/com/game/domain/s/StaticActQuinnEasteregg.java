package com.game.domain.s;

/**
 * @ClassName:StaticActQuinn
 * @author 丁文渊
 * @Description:对应s_act_Quinn表 超时空财团消费彩蛋
 * @date 2017年9月11日
 */
public class StaticActQuinnEasteregg {
    /** 编号*/
    private int id;

    /**类型，1代表贸易，2代表兑换*/
    private int type;
    
    /**刷新累积金币数量*/
    private int number;
    
    /**奖励内容*/
    private Integer[][] awards;



    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public int getNumber() {
        return number;
    }

    public void setNumber(int number) {
        this.number = number;
    }

    /**
     * @return the awards
     */
    public Integer[][] getAwards() {
        return awards;
    }

    /**
     * @param awards the awards to set
     */
    public void setAwards(Integer[][] awards) {
        this.awards = awards;
    }


}