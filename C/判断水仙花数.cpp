#include<stdio.h>
int main()
{
	printf("输入一个三位数:");
	int a;
	float b;
	float c;
	float d;
	scanf("%d",&a);
	b=a/100%100;
	c=a/10%10;
	d=a%10;
	if(a==b*b*b+c*c*c+d*d*d)
		printf("该数为水仙花数");
	else
		printf("该数不为水仙花数");
	return 0;
}
