package com.game.domain.s;

/**
 * @ClassName:StaticActQuinn
 * @author 丁文渊
 * @Description:对应s_act_Quinn表 超时空财团面板刷新消耗
 * @date 2017年9月11日
 */
public class StaticActQuinnRefresh {
    /** 编号*/
    private int id;
    /**类型，1-4对应贸易界面中的1-4号道具栏。100，对应兑换界面中的道具栏*/
    private int type;

    /**价钱 [刷新...次以内,刷新价格]*/
    private Integer[][]  price;
    
    


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

    public Integer[][] getPrice() {
        return price;
    }

    public void setPrice(Integer[][] price) {
        this.price = price;
    }
    
    public Integer givePrice(int  number) {
        int reprice=price[price.length-1][1];
        for (Integer[] integers : price) {
             if(integers[0].intValue() >= number + 1){
                 reprice = integers[1];
                 break;
             }
        }
        return reprice;
    }
  
}