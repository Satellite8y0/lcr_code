#include<stdio.h>
int main()
{
	printf("输入摄氏度\n");
	float s;
	float h;
	scanf("%f",&s);
	h=32+s*1.8;
	printf("%f摄氏度转换为%.2f华氏度",s,h);
	return 0;

}
