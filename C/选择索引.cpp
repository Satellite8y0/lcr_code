#include<stdio.h>
int main()
{
	int a[6],b[6],x,t;
	a[0]=25;a[1]=10;a[2]=21;a[3]=9;a[4]=14;a[5]=54;
	for(int i=0;i<=5;i++)
	{
		b[i]=i;
	}
	for(int i=0;i<5;i++)
	{
		t=i;
		for(int j=i+1;j<=5;j++)
		{
			if(a[b[t]]<a[b[j]])/*选择索引*/
			{
				t=j;
			}
		}
		x=b[i];
		b[i]=b[t];
		b[t]=x;	
	}
	for(int i=0;i<=5;i++)
	{
		printf("%d",b[i]);
	}
	return 0;
} 
