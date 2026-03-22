#include<stdio.h>
int main()
{
	for(int x=1;x<=100;x++)
	{
		for(int y=1;y<=100;y++)
		{
			for(int z=1;z<=100;z++)
			{
				if((x*3+y*2+z*0.5==100)&&(x+y+z==100))
			{
					printf("%d,%d,%d\n",x,y,z);
			}
			}
		}
	}
	return 0;
} 
