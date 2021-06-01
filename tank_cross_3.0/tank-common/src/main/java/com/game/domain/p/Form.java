package com.game.domain.p;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Form {
    private int type;
    private AwakenHero awakenHero;
    private int commander;
    public int[] p = new int[6];
    public int[] c = new int[6];
    private List<Integer> tacticsKeyId = new ArrayList<>();

    private List<TowInt> tacticsList = new ArrayList<>();

    public int getCommander() {
        return commander;
    }

    public void setCommander(int commander) {
        this.commander = commander;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public AwakenHero getAwakenHero() {
        return awakenHero;
    }

    public void setAwakenHero(AwakenHero awakenHero) {
        this.awakenHero = awakenHero;
    }

    public Form(Form form) {
        type = form.type;
        awakenHero = form.awakenHero;
        commander = form.commander;
        System.arraycopy(form.p, 0, p, 0, 6);
        System.arraycopy(form.c, 0, c, 0, 6);
        this.tacticsKeyId = new ArrayList<>(form.tacticsKeyId);
        this.tacticsList = new ArrayList<>(form.tacticsList);
    }

    public Form() {
    }

    @Override
    public String toString() {
        return "Form [type="
                + type
                + ", commander="
                + commander
                + ", p="
                + Arrays.toString(p)
                + ", c="
                + Arrays.toString(c)
                + "]";
    }

    public List<TowInt> getTacticsList() {
        return tacticsList;
    }

    public void setTacticsList(List<TowInt> tacticsList) {
        this.tacticsList = tacticsList;
    }

    public List<Integer> getTacticsKeyId() {
        return tacticsKeyId;
    }

    public void setTacticsKeyId(List<Integer> tacticsKeyId) {
        this.tacticsKeyId = tacticsKeyId;
    }

    public int getTankCount() {
        int count = 0;
        for (int cnt : c) {
            if (cnt > 0) {
                count += cnt;
            }
        }
        return count;
    }

    /**
     * 部队中的坦克是否已经被打光了
     *
     * @return
     */
    public boolean hasTank() {
        for (int cnt : c) {
            if (cnt > 0) {
                return true;
            }
        }
        return false;
    }

    public int getHero() {
        return awakenHero != null ? awakenHero.getHeroId() : commander;
    }

}
