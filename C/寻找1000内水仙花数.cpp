#include<stdio.h>
int main()
{
	float b;
	float c;
	float d;
	int a=1;
	while (a<=1000)
	{
		b=a/100%100;
		c=a/10%10;
		d=a%10;
		if(a==b*b*b+c*c*c+d*d*d)
			printf("%d,",a);
		a++;
	}
	return 0;
}

	
