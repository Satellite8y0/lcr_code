#include<stdio.h>
int main()
{
	int a,x;
	a=1000;
	x=0;
	while(a<=3000)
	{   
		if((a%4==0&&a%100!=0)||a%400==0)
		{
			printf("%d,",a);
			x++;
			if(x==5)
			 {   x=0;
				printf("\n");
			 }
			
		}
		
		a++;
	}
	return 0;
} 

