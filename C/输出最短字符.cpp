#include<stdio.h>
int main()
{
	char a[5][10];
	int j=0,n=10,c;
	printf("输入5个字符串：\n");
	for(int i=0;i<=4;i++){
		gets(a[i]);
		while(a[i][j]!='\0')
		{
		j++	;
		}
		if(j<n){
			n=j;
			c=i;
		}
		j=0;
	}
	printf("最短字符为：");
	puts(a[c]);
	return 0;
}
