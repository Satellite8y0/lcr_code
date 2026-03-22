#include<stdio.h>
int main()
{
	int a[5];
	int n=0;
	int e=0;
	float p;
	printf("输入学生成绩:");
	scanf("%d,%d,%d,%d,%d",&a[0],&a[1],&a[2],&a[3],&a[4]);
	for(int i=0;i<=4;i++)
	{
		e=e+a[i];
		if(a[i]>=60)
		{
			p=p+a[i];
			n++;
		}
	}
	p=p/n;
	printf("该学生总分为:%d\n",e);
	printf("该学生大于60分课程成绩平均分为:%f",p);
	
	return 0;
} 

