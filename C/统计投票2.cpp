#include<stdio.h>
int main()
{
	int a[10],b[10];
	for(int i=0;i<=9;i++){
		scanf("%d",&a[i]);
		b[a[i]]++;
	}
	for(int i=0;i<=9;i++){
	    printf("%d",b[i]);
	}
	
	return 0;
} 
