package com.game.domain.sort;

/**
 * @author zhangdh
 * @ClassName: HeroSort
 * @Description:
 * @date 2017-07-05 17:14
 */
public class HeroSort extends IntValueSort{
    private int heroId;
    public HeroSort(int heroId, int v){
        super(v);
        this.heroId = heroId;
    }

    public int getHeroId() {
        return heroId;
    }

    public void setHeroId(int heroId) {
        this.heroId = heroId;
    }
}
