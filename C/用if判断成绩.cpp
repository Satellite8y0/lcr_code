#include<stdio.h>
int main()
{
	printf("输入学生成绩:");
	int a;
	scanf("%d",&a);
	printf("学生等级为:");
	if(a>=90&&a<=100)
	{
		printf("优秀");
	}
	else if(a>80&&a<90)
	{
		printf("良好");
	}
	else if(a>=60&&a<80)
	{
		printf("中等");
	}
	else if(a<60)
	{
		printf("差");
	}
	else
	{
		printf("请输入正确分数");
	}
	return 0;
} 

