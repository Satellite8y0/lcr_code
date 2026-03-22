#include<stdio.h>
int main()
{
	typedef struct toupiao{
		int name[10];
		int n=0;
	}T;
	FILE*fq;
	T a[10];
	int j;
	fq=fopen("in.txt","r");
	for(int i=0;i<=9;i++){
	j=fscanf(fq,"%d",a[i].name);
	a[j-1].n++;}
	for(int i=0;i<=7;i++){
		printf("第%d号栏目的票数为%d\n",i+1,a[i].n);
	}
	fclose(fq);
	return 0;
} 
