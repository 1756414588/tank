package com.game.dataMgr;

import java.util.List;
/**
 * 
* @ClassName: BaseDataMgr 
* @Description: 数据处理基类
* @author
 */public abstract class BaseDataMgr {
    /**
     * 
    * @Title: init 
    * @Description:   数据初始化方法 init方法会将所有数据加载到内存中
    * void   
     */
//	@PostConstruct
	abstract public void init();
	
	/**
	 * 
	* @Title: calcProbWeights 
	* @Description: 计算出[type,id,count]组中某个属性的和
	* @param list  List<List<Integer>> 来记录数据库中[[type,id,count],[type,id,count],[type,id,count]]格式的数据
	* @param pos  0,1,2对应type,id,count
	* @return  
	* int   
	 */
	protected int calcProbWeights(List<List<Integer>> list, int pos) {
		int weights = 0;
		for (int i = 0; i < list.size(); i++) {
			weights += list.get(i).get(pos);
		}
		return weights;
	}

	/**
	 * 重新加载数据，用于热加载
	 */
	public void reload() {
		init();
	}
}
