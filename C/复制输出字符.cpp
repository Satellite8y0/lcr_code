#include<stdio.h>
int main()
{
	int i=0,t,d;
	char b[20],a[10];
	gets(a);
	while(a[i]!='\0')
	{
		i++;
	}
	t=i-1;
	d=i*2-1;
	i=0;
	for(int j=0;j<=d;j++)
	{
		b[j]=a[i];
		i++;
		if(i==t+1)
		{
			i=0;
		}
	}
	b[d+1]=a[t+1];
	puts(b);
	return 0;
} 

