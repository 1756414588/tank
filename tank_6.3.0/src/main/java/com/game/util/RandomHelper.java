package com.game.util;

import com.game.domain.sort.IProb;
import org.apache.commons.lang3.RandomUtils;

import java.util.*;
/**
 * 随机数工具类
* @ClassName: RandomHelper 
* @Description: TODO
* @author
 */
public class RandomHelper {
    /**
     * 
    * 计算一个百分比几率 是否赌博成功 （暴击率15%  prob传入15  随机得出有没有产生暴击）
    * @param prob几率
    * @return  
    * boolean
     */
    static public boolean isHitRangeIn100(final int prob) {
        final int seed = randomInSize(100);
        boolean bool = false;
        if (seed < prob) {
            bool = true;
        }
        return bool;
    }
    
    /**
     * 
    * 计算一个千分比几率 是否赌博成功 （暴击率15%  prob传入15  随机得出有没有产生暴击）
    * @param prob
    * @return  
    * boolean
     */
    static public boolean isHitRangeIn1000(final int prob) {
        final int seed = randomInSize(1000);
        boolean bool = false;
        if (seed < prob) {
            bool = true;
        }
        return bool;
    }

    /**
     * 
    *  计算一个万分比几率 是否赌博成功 （暴击率15%  prob传入15  随机得出有没有产生暴击）
    * @param prob
    * @return  
    * boolean
     */
    static public boolean isHitRangeIn10000(final int prob) {
        final int seed = randomInSize(10000);
        boolean bool = false;
        if (seed < prob) {
            bool = true;
        }
        return bool;
    }

    /**
     * 同上 十万分比几率 计算是否赌博成功 （暴击率15%  prob传入15  随机得出有没有产生暴击）
    * 
    * @param prob
    * @return  
    * boolean
     */
    static public boolean isHitRangeIn100000(final int prob) {
        final int seed = randomInSize(100000);
        boolean bool = false;
        if (seed < prob) {
            bool = true;
        }
        return bool;
    }

    /**
     * 
    * 以prob/probMax的几率计算是否赌博成功 
    * @param prob
    * @param probMax
    * @return  
    * boolean
     */
    static public boolean isHitRangeIn(final int prob, int probMax) {
        final int seed = randomInSize(probMax);
        boolean bool = false;
        if (seed < prob) {
            bool = true;
        }
        return bool;
    }

    /**
     * 
    * 根据权重数组 随机出 最终第几个
    * @param arr 权重数组
    * @return  
    * int
     */
    public static int getRandomIndex(int[] arr) {
        if (arr == null) throw new NullPointerException("");
        if (arr.length == 0) return 0;
        int total = 0;
        for (int i : arr) {
            total += i;
        }
        int rs = randomInSize(total);
        int delt = 0;
        for (int i = 0; i < arr.length; i++) {
            if (rs < (delt += arr[i])) return i;
        }
        return 0;
    }

    /**
     * 
    * 同上
    * @param list            权重数组
    * @return  
    * int
     */
    public static int getRandomIndex(List<Integer> list) {
        if (list == null) throw new NullPointerException("");
        if (list.size() == 0) return 0;
        int total = 0;
        for (int v : list) {
            total += v;
        }
        int rs = randomInSize(total);
        int delt = 0;
        for (int i = 0; i < list.size(); i++) {
            if (rs < (delt += list.get(i))) return i;
        }
        return 0;
    }

    /**
     * 根据权重返回选中的对象
     *
     * @param weightList 内部的list 长度必须为4, 且第4位必须为权重
     * @return
     */
    public static List<Integer> getRandomByWeight(List<List<Integer>> randomList) {
        return getRandomByWeight(randomList, 3);
    }

    /**
     * 根据权重返回选中的对象
     *
     * @param randomList
     * @param weightIndex 权重的位置: 0(include) 到 randomList.size() (exclude)
     * @return
     */
    public static List<Integer> getRandomByWeight(List<List<Integer>> randomList, int weightIndex) {
        List<Integer> weightList = new ArrayList<>(randomList.size());
        for (List<Integer> list : randomList) {
            weightList.add(list.get(weightIndex));
        }
        return randomList.get(getRandomIndex(weightList)).subList(0, weightIndex);
    }

    /**
     * 
    * IProb类型的getProb为权重  根据权重从IProb数组中取得对象
    * @param randomList
    * @return  
    * T
     */
    public static <T extends IProb> T getRandomByProb(List<T> randomList) {
        List<Integer> weightList = new ArrayList<>(randomList.size());
        for (T prob : randomList) {
            weightList.add(prob.getProb());
        }
        return randomList.get(getRandomIndex(weightList));
    }

    /**
     * 
    * 取一个0到size的随机数
    * @param size
    * @return  
    * int
     */
    static public int randomInSize(final int size) {
        return RandomUtils.nextInt(0, size);
    }

    /**
     * 
    * 取一个0到size的随机数
    * @param size
    * @return  
    * long
     */
    static public long randomInSize(final long size) {
        return RandomUtils.nextLong(0, size);
    }
    
    /**
     * 获取随机数 [ start, end ] 
     * @param start
     * @param end
     * @return
     */
    static int getRandomBetween(final int start, final int end) {
    	 return RandomUtils.nextInt(start, end);
    }
    
    /**
	 * 从 [min, max]中取出一组不重复的随机数
	 * @param min
	 * @param max
	 * @param num 个数
	 * @return 可能包含min及max，左闭右闭
	 */
    static public List<Integer> getRandomValues(int min, int max, int num) {
    	final List<Integer> list = new java.util.LinkedList<Integer>();
    	if (max < 0 || num <= 0 || max < min) {
    		return list;
    	}
    	if (num > (max - min + 1)) {
			num = max - min + 1;
		}
    	for (int i = 0; i < num; ++i) {
			int val = getRandomBetween(min, max);
			while (list.contains(val)) {
				val = min + ((val + 1 - min) % (max - min + 1));
			}

			list.add(val);
		}
    	return list;
    }
    
	/**
	 * 从一个集合中，随机选取几个，构成一个新的List
	 * 
	 * @param collection 源集合
	 * @param num 随机选取的个数
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public static <T> List<T> getRandomList(Collection<T> collection, int num) {
		//如果集合小于需要的个数，则直接返回一个乱序的list
		if(collection.size() <= num)
		{
			List<T> result = new LinkedList<T>();
			result.addAll(collection);
			randomlizeList(result);
			return result;
		}
		
		int[] tmpArray = new int[collection.size()];
		for (int i = 0; i < tmpArray.length; i++) 
			tmpArray[i] = i;
		int[] chosen = getRandomArray(tmpArray, num);
		List<T> result = new LinkedList<T>();
		for(int i : chosen){
			result.add((T) collection.toArray()[i]);
		}		
		return result;
	}

	/**
	 * 将一个list打乱
	 * @param <T> 
	 * @param list
	 */
	public static<T> void randomlizeList( java.util.List<T> list ) {
		for ( int i = 1; i < list.size(); i++ ) {
			final int idx = getRandomBetween( 0, i );
			if ( i != idx ) {
				T t = list.get( idx );
				list.set( idx, list.get( i ) );
				list.set( i, t );
			}
		}
	}
	
	/**
	 * 获得一个不重复的随机序列.比如要从20个数中随机出6个不同的数字,可以先把20个数存入数组中,然后调用该方法.注意方法调用完后totals
	 * 里面的elements的顺序是变了的.适用于从一部分数中找出其中的绝大部分
	 * 
	 * @param totals
	 *            所有数据存放在数组中
	 * @param dest
	 *            要返回的序列的长度
	 * @return 生成的序列以数组的形式返回
	 */
	public static int[] getRandomArray(int[] totals, int dest) {
		Random random = new Random();
		if (dest <= 0)
			throw new IllegalArgumentException();
		if (dest > totals.length) //如果要选的数比数组的长度还长,那就直接返回整个数组
			return totals;
		int[] ranArr = new int[dest];
		for (int i = 0; i < dest; i++) {
			// 得到一个位置
			int j = random.nextInt(totals.length - i);
			ranArr[i] = totals[j];
			// 将未用的数字放到已经被取走的位置中,这样保证不会重复
			totals[j] = totals[totals.length - 1 - i];
		}
		return ranArr;
	}

    public static void main(String[] args) {
    	Integer[] a  = new Integer[] {1,2,3,5,4,7,8,9};
    	List<Integer> list = Arrays.asList(a);
    	List<Integer> list2 = getRandomList(list,5);
    	System.out.print(list2);
    	
    }
}
