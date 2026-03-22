#include<stdio.h>
#include<math.h>
int main()
{
	char d[8];
	int a[8],m,n,c=0,b[8];
	printf("输入n进制：");
	scanf("%d",&n);
	printf("请输入8位%d进制整数：\n",n);
	for(int i=0;i<=7;i++){
		b[i]=0;
		a[i]=0;
		d[i]='0';
	}
	for(int i=0;i<=7;i++){
		scanf("%d",&a[i]);
	}
	printf("转换为m进制：");
	scanf("%d",&m);
	for(int i=7;i>=0;i--){
		c=c+a[i]*pow(n,7-i);
	}
	if(m==10)
	{
		printf("%d",c);
	}
	else if(m<=10){
	for(int i=0;i<=7;i++)
	{
		b[i]=c%m;
		c=c/m;
		if(c==0)
		{
			break;
		}
	}
	for(int i=7;i>=0;i--)
	{
		printf("%d",b[i]);
	}
	}
	else{
		for(int i=0;i<=7;i++)
		{
			if(c%m<10){
			d[i]=c%m;}
			else{d[i]='A'+(c%m-10);}
			c=c/m;
			if(c==0)
			{
				break;
			}
		}
		for(int i=7;i>=0;i--)
		{
			printf("%c",d[i]);
		}
		
	}
	return 0;
} 
