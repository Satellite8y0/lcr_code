#include<stdio.h>
int main()
{
	int a,b=1;
	int n=0;
	int e=0;
	float p;
	while(b<=5)
	{
	printf("输入学生第%d科成绩:",b);
	scanf("%d",&a);
	
		if(a>=60)
		{
			n++;
			p=p+a;
		}
		b++;
		e=e+a;
	}
	p=p/n;
	
	printf("该学生总分为:%d\n",e);
	printf("该学生大于60分课程成绩平均分为:%f",p);
	
	return 0;
} 

