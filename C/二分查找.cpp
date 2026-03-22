#include<stdio.h>
int main()
{
	int a[101],l=0,h=100,m,b;
	scanf("%d",&b);
	for(int i=0;i<=200;i=i+2)
	{
		a[i/2]=i;
	}
	while(l<=h)
	{
		m=(l+h)/2;
		if(b>a[m])
		{
			l=m+1;
		}
		else if(b<a[m])
		{
			h=m-1;
		}
		else break;
	}
	printf("%d",m);
	return 0;
} 
