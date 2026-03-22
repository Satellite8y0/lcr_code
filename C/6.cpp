#include<stdio.h>
#include<string.h>
char *fun(char a[][20]);
int main()
{ char a[5][20];
	int  i;
	char (*s)[20];
	s=a;
	FILE*fq;
	fq=fopen("in.txt","r");
	for(i=0;i<5;i++)
	{
		fscanf(fq,"%s",*s); 
		s++;
	}
	fclose(fq);
	puts(fun(a));
	
	
	return 0; 
}

char *fun(char a[5][20])
{
	char (*r)[20],(*p)[20];
	int  i,max,l;
	r=&a[0];
	p=&a[1];
	max=strlen(*r);
	for(i=1;i<5;i++)
	{
		l=strlen(*p);
		if( max <l  )
		{
			max=l;
			r=p;
			p++;
		} 
		
	}
	return *r;
}

