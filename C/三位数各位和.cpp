#include<stdio.h>
int main()
{
	printf("输入一个三位数:");
	int a;
	float b;
	float c;
	float d;
	int e;
	scanf("%d",&a);
	b=a/100%100;
	c=a/10%10;
	d=a%10;
	e=c+b+d;
	printf("该三位数各位数之和为：%d",e);
	return 0;
}
