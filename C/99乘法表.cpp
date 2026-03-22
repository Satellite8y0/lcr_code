#include<stdio.h>
int main()
{  
	int j;
    int i;
    int a;
   for(i=1;i<=9;i++)
   {
	   for(j=i;j<=9;j++)
	   {
		   a=i*j;
		   printf("%5d*%d=%d",i,j,a);
	   }
	   printf("\n");
   }
	
	return 0;
} 

