#include<stdio.h>
int main()
{
	char a[10];
	int i=0;
	FILE*fq;
	fq=fopen("in.txt","r");
	fgetc(fq);
	while(a[i]!='!'&&!feof(fq)){
		fgetc(fq);
		i++;
	}
	fclose(fq);
	printf("%d",i);
	return 0;
	
} 
