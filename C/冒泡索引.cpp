#include<stdio.h>
int main()
{
	int a[6],b[6],t;
	a[0]=25;a[1]=10;a[2]=21;a[3]=9;a[4]=14;a[5]=54;
	for(int i=0;i<=5;i++)
	{
		b[i]=i;
	}
	for(int i=0;i<5;i++)
	{
		for(int j=0;j<5-i;j++)
		{
			if(a[b[j]]<a[b[j+1]])/*冒泡索引*/
			{
				t=b[j+1];
				b[j+1]=b[j];
				b[j]=t;
			}
		}
	}
	for(int i=0;i<=5;i++)
	{
		printf("%d,",a[b[i]]);
	}
	return 0;
} 
