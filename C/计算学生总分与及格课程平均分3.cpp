#include<stdio.h>
int main()
{
	int a;
	int n=0;
	int e=0;
	float p;
	printf("输入学生成绩:");
	while(scanf("%d",&a)!=EOF)
	{
		if(a>=60)
		{
			n++;
			p=p+a;
		}
		printf("输入学生成绩:");
		e=e+a;
	}
	p=p/n;
	printf("该学生总分为:%d\n",e);
	printf("该学生大于60分课程成绩平均分为:%f",p);
	
	return 0;
} 

