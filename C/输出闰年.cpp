#include<stdio.h>
int main()
{
	int b;
	b=1000;
	FILE*fq;
	fq=fopen("out.txt","w+");
	while(b<=3000)
	{   
		if((b%4==0&&b%100!=0)||(b%400==0))
		{
			fprintf(fq,"%5d",b);
		}
		b++;
	}
	fclose(fq);
	return 0;
} 
