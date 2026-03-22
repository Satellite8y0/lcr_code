#include<stdio.h>
int main()
{
	int s;
	float d;
	float e;
	float q;
	printf("超市计费系统\n");
	printf("作者：李聪睿\n");
	printf("请输入商品的数量:");
	scanf("%d",&s);
	printf("请输入商品价格:");
	scanf("%f",&d);
	e=1;
	if(s==2)
		e=0.95;
	else if(s>2&&s<=5)
		e=0.9;
		else if(s>5)
			e=0.85;
	q=s*d*e;
	printf("您好，该种商品你应付:%.2f",q);
	return 0;
}
