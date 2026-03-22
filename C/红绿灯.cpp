#include<stdio.h>
int main()
{
	printf("输入状态：");
	int a;
	scanf("%d",&a);
	switch (a) 
	{
	case 1:
		printf("停车\n");
		break;
	case 2:
		printf("即将停车\n");
		break;
	default:
		printf("可通行");
	
	}
	return 0;
}
