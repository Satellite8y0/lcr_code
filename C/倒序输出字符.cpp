#include<stdio.h>
int main()
{
	char a[10],t;
	int i=0;
	gets(a);
	puts(a);
		while(a[i]!='\0')
		{
			i++;
		}
		i=i-1;
		for(int j=0;j<=i;j++)
		{
		t=a[i];
		a[i]=a[j];
		a[j]=t;
		i--;
		}
	puts(a);
	return 0;
}
