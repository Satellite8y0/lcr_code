#include<stdio.h>
int main()
{
	typedef struct toupiao{
		char name[10],cbs[10];
		int n;
	}T;
	FILE*fq;
	T a[5],t;
	fq=fopen("in.txt","r");
	for(int i=0;i<=4;i++){
		fscanf(fq,"%s %s %d",a[i].cbs,a[i].name,&a[i].n);
	}
	for(int i=0;i<5;i++)
	{
		for(int j=0;j<5-i;j++)
		{
			if(a[j].n>a[j+1].n)
			{
				t=a[j+1];
				a[j+1]=a[j];
				a[j]=t;
			}
		}
	}
	fclose(fq);
	fq=fopen("out.txt","w+");
	for(int i=0;i<=4;i++){
	fprintf(fq,"%s %s %d\n",a[i].cbs,a[i].name,a[i].n);
	}
	fclose(fq);
	return 0;
}
