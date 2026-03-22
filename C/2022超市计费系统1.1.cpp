#include<stdio.h>
int main()
{
	int a[3];
	float b[3],z,y;
	printf("输入3个商品的单价:");
	scanf("%f,%f,%f",&b[0],&b[1],&b[2]);
    printf("输入3个商品的数量:");
	scanf("%d,%d,%d",&a[0],&a[1],&a[2]);
	if(a[0]+a[1]+a[2]==1){y=1;}
	else if(a[0]+a[1]+a[2]==2){y=0.95;}
	else if(a[0]+a[1]+a[2]>=3&&a[0]+a[1]+a[2]<=5){y=0.9;}
	else y=0.85;
	for(int i=0;i<=2;i++)
	{
		z=z+a[i]*b[i];
	}
	printf("商品总额为：%f",z*y);
	return 0;
}
