#include<stdio.h>
#include<string.h>
int main()
{
	int l;
	char a[10],b[10];
	FILE*fq;
	fq=fopen("in.txt","r");
		fgets(a,10,fq);
	fclose(fq);
	l=strlen(a);
	for(int i=0;i<=l-1;i++)
	{
		b[i]=a[i]-32;
	}
	b[l]='\0';
	fq=fopen("out.txt","w+");
	fputs(b,fq);
	fclose(fq);
	return 0;
} 
