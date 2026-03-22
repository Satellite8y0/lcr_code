#include<stdio.h>
int main()
{
	int a,n,c=1;
	float b,z,y;
	printf("请输入商品种类:");
	scanf("%d",&n);
	while(c<=n)
	{printf("输入第%d个商品的单价:",c);
		scanf("%f",&b);
		printf("输入第%d个商品的数量:",c);
		scanf("%d",&a);
		if(a==1){y=1;}
		else if(a==2){y=0.95;}
		else if(a>=3&&a<=5){y=0.9;}
		else y=0.85;
		z=a*b;
		printf("商品总额为：%f\n",z*y);
		c++;
	}
	
	return 0;
}
