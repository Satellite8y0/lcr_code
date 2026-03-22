#include<stdio.h>
int main()
{  
	int j=1;
	int i=1;
	int a;
	while(i<9)
	{
		if(j==10)
		{
			j=i+1;
			i++;
			printf("\n");
		}
		a=i*j;
		printf("%5d*%d=%d",i,j,a);
		j++;
	}
	return 0;
} 
