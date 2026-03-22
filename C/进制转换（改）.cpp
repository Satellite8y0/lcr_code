#include<stdio.h>
#include<math.h>
int main()
{
	char d[100];
	int a[100],m,n,c=0,b[100],g,i,j;
	printf("输入n(n<=10)进制：");
	scanf("%d",&n);
	printf("请输入位数：\n");
	scanf("%d",&g);
	printf("请输入%d进制整数：\n",n);
	for(i=0;i<=100;i++){
		b[i]=0;
		a[i]=0;
		d[i]='0';
	}
	for(i=0;i<=g-1;i++){
		scanf("%d",&a[i]);
	}
	printf("转换为m进制：");
	scanf("%d",&m);
	for(i=g-1;i>=0;i--){
		c=c+a[i]*pow(n,7-i);
	}
	if(m==10)
	{
		printf("%d",c);
	}
	else if(m<=10){
		for(j=0;j<=100;j++)
		{
			b[i]=c%m;
			c=c/m;
			if(c==0)
			{
				break;
			}
		}
		for( i=j;i>=0;i--)
		{
			printf("%d",b[i]);
		}
	}
	else{
		for(j=0;j<=7;j++)
		{
			if(c%m<10){
				d[i]=c%m;}
			else{d[i]='A'+(c%m-10);}
			c=c/m;
			if(c==0)
			{
				break;
			
		}
		for(i=j;i>=0;i--)
		{
			printf("%c",d[i]);
		}
		
	}
	return 0;
} 
}
