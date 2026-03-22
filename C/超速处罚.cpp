#include<stdio.h>
int main()
{
	float v,x;
	printf("请输入限速：");
	scanf("%f",&v);
	printf("请输入行驶速度：");
	scanf("%f",&x);
	if((x-v)/x<0.1)
	{
		printf("无处罚");
	}
	else if((x-v)/x>0.5)
	{
		printf("吊销驾驶证");
	}
	else
	{
		printf("处200元罚款");
	}
	return 0;
} 


