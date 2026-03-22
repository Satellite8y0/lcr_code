#include<stdio.h>
int main()
{
	int a[4][4];
	printf("请输入3名学生的学号及每门课成绩\n");
	printf("=================================\n");
	printf("学号  英语  大物  C语言\n");
	for(int i=0;i<=2;i++)
	{
	scanf("%d %d %d %4d",&a[i][0],&a[i][1],&a[i][2],&a[i][3]);
	}
	printf("=================================\n");
	printf("平均分");
	for(int j=1;j<=3;j++){
	printf("%4d",(a[1][j]+a[2][j]+a[0][j])/3);
	}
	return 0;
} 
