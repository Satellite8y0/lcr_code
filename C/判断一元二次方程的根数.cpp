#include<stdio.h>
int main()
{
	float a;
	float b;
	float c;
	float flag;
	printf("输入一元二次方程a*x*x+b*x+c的a,b,c：");
	scanf("%f,%f,%f",&a,&b,&c);
	flag=b*b-4*a*c;
	if(flag==0)
		printf("该方程有两个相同的实数根");
	else if(flag>0)
		printf("该方程有两个不同的实数根");
	else
		printf("该方程没有实数根");
	return 0;
}
