#include<stdio.h>
int main()
{   int b;
	int a;
	printf("输入整数：");
	scanf("%d",&a);
	b=a;
	while(b>1)
	{   
		a=a*(b-1);
		b--;
	}
	printf("%d",a);
	return 0;
}
