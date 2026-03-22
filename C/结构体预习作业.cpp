#include <stdio.h>
int main() {
	typedef struct shangpin {
		char name[10], lb[10];
		int dj, sl;
		struct date {
			int y, m, d;
		} date;
	} LIU;
	LIU t;
	printf("请输入商品名称,单价,生产日期,库存数量,所属类别\n");
	scanf("%s %s %d %d %d %d %d",  t.name, t.lb, &t.dj, &t.sl, &t.date.y, &t.date.m,&t.date.d);
	FILE*fq;
	fq=fopen("out.txt","w+");
	fprintf(fq,"名称为%s,种类为%s,单价为%d,库存数量为%d,生产日期为%d-%d-%d", t.name, t.lb, t.dj, t.sl, t.date.y, t.date.m, t.date.d);
	fclose(fq);
	return 0;
}

















