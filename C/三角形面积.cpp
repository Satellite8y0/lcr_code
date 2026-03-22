#include<stdio.h>
int main()
{
	float s;
	float a;
	float h;
	printf("输入边长：");
	scanf("%f",&a);
	printf("输入高：");
	scanf("%f",&h);
	s=a*h/2;
	printf("边长为%.2f高为%.2f的三角形面积为%.2f",a,h,s);
	return 0;
}

