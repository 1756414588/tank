/**
 * @Title: Form.java
 * @Package com.game.domain
 * @Description:
 * @author ZhangJun
 * @date 2015年7月16日 上午11:45:29
 * @version V1.0
 */
package com.game.domain.p;

import java.util.*;

/**
 * @author ZhangJun
 * @ClassName: Form
 * @Description: 部队阵型
 * @date 2015年7月16日 上午11:45:29
 */
public class Form {
    private int type;
    private AwakenHero awakenHero;
    private int commander;
    public int[] p = new int[6];
    public int[] c = new int[6];
    private String formName;

    //战术
    private List<Integer> tactics = new ArrayList<>();

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

    public int getHero() {
        return awakenHero != null ? awakenHero.getHeroId() : commander;
    }

    public String getFormName() {
        return formName;
    }

    public void setFormName(String formName) {
        this.formName = formName;
    }

    public Form(Form form) {
        type = form.type;
        awakenHero = form.awakenHero;
        commander = form.commander;
        System.arraycopy(form.p, 0, p, 0, 6);
        System.arraycopy(form.c, 0, c, 0, 6);
        formName = form.formName;
        tactics = new ArrayList<>(form.getTactics());
        tacticsList = new ArrayList<>(form.getTacticsList());
    }

    public Form(AwakenHero awakenHero, int commander) {
        this.awakenHero = awakenHero;
        this.commander = commander;
    }

    public Form() {

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

    public int getTankCount() {
        int count = 0;
        for (int cnt : c) {
            if (cnt > 0) {
                count += cnt;
            }
        }
        return count;
    }

    @Override
    public String toString() {
        return "Form [type=" + type + ", commander=" + getHero() + ", p=" + Arrays.toString(p) + ", c="
                + Arrays.toString(c) + "]";
    }

    public List<Integer> getTactics() {
        return tactics;
    }

    public void setTactics(List<Integer> tactics) {
        this.tactics = tactics;
    }

    public List<TowInt> getTacticsList() {
        return tacticsList;
    }

    public void setTacticsList(List<TowInt> tacticsList) {
        this.tacticsList = tacticsList;
    }
}
