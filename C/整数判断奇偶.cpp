#include<stdio.h>
int main()
{
	printf("输入一个整数:");
	int a;
	scanf("%d",&a);
	int b;
	b=a%2;
	if(b==0)
		printf("该整数为偶数");
	else printf("该整数为奇数");
	return 0;
}
