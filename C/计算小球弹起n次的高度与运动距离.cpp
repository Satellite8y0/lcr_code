#include<stdio.h>
int main()
{
	int H=100;
	int N;
	int n;
	float l=100;
	float h;
	printf("请输入落地的次数:");
	scanf("%d",&n);
	N=n;
	while(n>0)
	{   
		l=l+h*2;
		H=H/2;
		h=H;
		n--;
	}
	printf("第%d次落地在空中运动的距离为：%4f",N,l);
	printf("第%d次落地弹起的高度为：%4f",n,h);
	return 0;
} 

