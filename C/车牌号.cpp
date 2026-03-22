#include<stdio.h>
int main()
{
	for(int x=1;x<=9;x++)
	{
	for(int y=1;y<=9;y++)
	{
	for(int z=1;z<=100;z++)
	{
	if(x*1100+y*11==z*z)
	{
		printf("%d",x*1100+y*11);
	}
	}
	}
	}
	return 0;
} 
