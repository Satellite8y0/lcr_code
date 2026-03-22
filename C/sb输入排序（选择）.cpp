#include<stdio.h>
int main()
{
	int a[10],i,j,t,x;
	FILE*fq;
	fq=fopen("in.txt","r");
	for(i=0;i<=9;i++){
		fscanf(fq,"%d\n",&a[i]);
	}
	fclose(fq);
	for(i=0;i<10;i++)
	{
		t=i;
		for(j=i;j<10;j++)
		{
			if(a[j]>a[t])
			{
				t=j;
			}
		}
		x=a[t];
		a[t]=a[i];
		a[i]=x;
	}
	fq=fopen("out.txt","w+");
	for(i=0;i<=9;i++)
	{
		fprintf(fq,"%d\n",a[i]);
	}
	fclose(fq);
	return 0;
} 
