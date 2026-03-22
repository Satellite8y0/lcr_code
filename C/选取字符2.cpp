#include<stdio.h>
int main()
{
	char a[10];
	int i=0;
	FILE*fq;
	fq=fopen("in.txt","r");
	fgets(a,10,fq);
	while(a[i]!='!'){
	
		i++;
	}
	fclose(fq);
	printf("%d",i);
	return 0;
	
} 
