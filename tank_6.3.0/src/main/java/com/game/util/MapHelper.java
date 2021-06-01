package com.game.util;

import java.util.ArrayList;
import java.util.List;

/**
 * 
 * @ClassName MapHelper.java
 * @Description 世界地图计算相关工具
 * @author zhangdh
 * @date 创建时间：2017年3月22日
 *
 */
public final class MapHelper {

	/**
	 * 世界地图上某个区域对应的格子列表
	 * 
	 * @param area
	 * @return
	 */
	public static List<Integer> getAreaPosList(int area) {
		int xBegin = area % 40 * 15;
		int xEnd = xBegin + 15;
		int yBegin = area / 40 * 15;
		int yEnd = yBegin + 15;
		List<Integer> posList = new ArrayList<>();
		for (int i = xBegin; i < xEnd; i++) {
			for (int j = yBegin; j < yEnd; j++) {
				posList.add(i + j * 600);
			}
		}
		return posList;
	}
	
	/**
	 * 
	 * Method: slot
	 * 
	 * @Description: 15 x 15 的客户端拉区区域
	 * @param pos
	 * @return
	 * @return int
	 * @throws
	 */
	public static int area(int pos) {
		Tuple<Integer, Integer> xy = reducePos(pos);
		return xy.getA() / 15 + xy.getB() / 15 * 40;
	}

	/**
	 * 
	* 数字坐标转成 x， y的坐标对象
	* @param pos 数字坐标
	* @return  
	* Turple<Integer,Integer>
	 */
	public static Tuple<Integer, Integer> reducePos(int pos) {
		Tuple<Integer, Integer> turple = new Tuple<Integer, Integer>(pos % 600, pos / 600);
		return turple;
	}

	/**
	 * 
	*  x， y的坐标转成数字坐标
	* @param x
	* @param y
	* @return  
	* int
	 */
    public static int pos(int x, int y) {
        return x + 600 * y;
    }

    public static void main(String[] args) {
        //LogUtil.info(pos(74, 599));
    }
}
