package com.game.domain.s;

public class StaticAltarBossStar {
//	CREATE TABLE `s_altar_boss_star` (
//			  `id` int(11) NOT NULL,
//			  `star` int(11) NOT NULL COMMENT 'star：boss星级',
//			  `amount` int(11) NOT NULL COMMENT 'amount:星级对应的boss数量',
//			  `cost` int(11) NOT NULL COMMENT 'cost:召唤该星级boss额外消耗的建设度',
//			  `exp` int(11) NOT NULL COMMENT 'exp：boss升级所需的星级经验',
//			  PRIMARY KEY (`id`)
//			) ENGINE=InnoDB DEFAULT CHARSET=utf8;\
		private int id;
		private int star;
		private int amount;
		private int cost;
		private int exp;
		public int getId() {
			return id;
		}
		public void setId(int id) {
			this.id = id;
		}
		public int getStar() {
			return star;
		}
		public void setStar(int star) {
			this.star = star;
		}
		public int getAmount() {
			return amount;
		}
		public void setAmount(int amount) {
			this.amount = amount;
		}
		public int getCost() {
			return cost;
		}
		public void setCost(int cost) {
			this.cost = cost;
		}
		public int getExp() {
			return exp;
		}
		public void setExp(int exp) {
			this.exp = exp;
		}
		@Override
		public String toString() {
			return "StaticAltarBossStar [id=" + id + ", star=" + star + ", amount=" + amount + ", cost=" + cost
					+ ", exp=" + exp + "]";
		}
		
		
		

}
