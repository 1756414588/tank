package com.game.domain.s;

import java.util.List;

/**
 * @author yeding
 * @create 2019/3/26 17:44
 */
public class StaticCoreMaterial {

    private int id;

    private int level;


    private int loc;

    private List<List<Integer>> material;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public int getLoc() {
        return loc;
    }

    public void setLoc(int loc) {
        this.loc = loc;
    }

    public List<List<Integer>> getMaterial() {
        return material;
    }

    public void setMaterial(List<List<Integer>> material) {
        this.material = material;
    }

    @Override
    public String toString() {
        return "StaticCoreMaterial{" +
                "id=" + id +
                ", loc=" + loc +
                ", material=" + material +
                '}';
    }
}
