#include<stdio.h>
void hnt(int n,char a,char b,char c)
{
	if(n==1)
	{
		printf("将%c移到%c\n",a,b);
	}
	else
	{
		hnt(n-1,a,c,b);
		printf("将%c移到%c\n",a,b);
		hnt(n-1,c,b,a);
	}
}
int main()
{
	
	int n;
	printf("请输入盘子数量：");
	scanf("%d",&n);
	hnt(n,'A','B','C');
	return 0;
}
