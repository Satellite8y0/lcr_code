#include<stdio.h>

int main()
{
	char a[500];
	int i=0,j=0;
	FILE*fq;
	fq=fopen("in.txt","r");
	fgets(a,500,fq);
	while(a[i]!='\0')
	{
		if(!((a[i]>='A'&&a[i]<='Z')||(a[i]>='a'&&a[i]<='z')))
		{
			j++;
		}
		i++;
	}
	fclose(fq);
	printf("%d",j);
	return 0;
} 
