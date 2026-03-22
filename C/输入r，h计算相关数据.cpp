#include<stdio.h>
int main()
#define PI 3.1415926
{
	float r;
	float h;
	printf("输入半径：");
	scanf("%f",&r);
	printf("输入高：");
	scanf("%f",&h);
	printf("圆周长C1=%.2f\n",2*r*PI);
	printf("圆面积Sa=%.2f\n",PI*r*r);
	printf("球面积Sb=%.2f\n",4*PI*r*r);
	printf("球体积Va=%.2f\n",4/3*PI*r*r*r);
	printf("圆柱体体积Vb=%.2f\n",PI*r*r*h);
	return 0;
}
