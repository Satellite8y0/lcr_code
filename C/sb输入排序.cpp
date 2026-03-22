#include<stdio.h>
int main()
{
	int a[10],i,j,t;
	FILE*fq;
	fq=fopen("in.txt","r");
	for(i=0;i<=9;i++){
		fscanf(fq,"%d\n",&a[i]);
	}
	fclose(fq);
	for(i=0;i<9;i++)
	{
		for(j=0;j<8-i;j++)
		{
			if(a[j]>a[j+1])
			{
				t=a[j+1];
				a[j+1]=a[j];
				a[j]=t;
			}
		}
	}
	fq=fopen("out.txt","w+");
	for(i=0;i<=9;i++)
	{
		fprintf(fq,"%d\n",a[i]);
	}
	fclose(fq);
	return 0;
} 
