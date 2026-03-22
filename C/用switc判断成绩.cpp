#include<stdio.h>
int main()
{
	printf("输入学生成绩:");
	int a;
	
	scanf("%d",&a);

	printf("学生等级为:");
	switch (a/10)
	{
	case 10:
	case 9:
		printf("优秀");
		break;
	case 8:
		printf("良好");
		break;
	case 7:
    case 6:
		printf("中等");
		break;
	default:
		printf("差");
		break;
	}
	return 0;
}
