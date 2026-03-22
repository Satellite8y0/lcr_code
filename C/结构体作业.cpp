#include<stdio.h>
int main()
{
	typedef struct toupiao{
		char name[10];
		int n,x;
	}T;
	FILE*fq;
	T a[5];
	int t=0;
	fq=fopen("in.txt","r");
	for(int i=0;i<=4;i++){
		fscanf(fq,"%d %s %d",&a[i].x,a[i].name,&a[i].n);
	}
	for(int j=0;j<5;j++)
	{
		if(a[j].n>a[t].n)
		{
			t=j;
		}
	}
	printf("%s同学总分最高为%d",a[t].name,a[t].n);
	fclose(fq);
	return 0;
}
