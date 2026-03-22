#include <stdio.h>
#include <math.h>
#include <string.h>
int main()
{float a[5],b=0,c=0,Sx,ua,uj,ud,Ed;
	int i,n;
	printf("游标卡尺为1，直尺为2，千分尺为3\n");
	scanf("%d",&n);
	printf("输入数据\n");
	for(i=0;i<5;i++)
	{scanf("%f",&a[i]);	
	}	
	printf("输入平均值\n");
	scanf("%f",&b);
	for(i=0;i<5;i++)
	{c=(a[i]-b)*(a[i]-b)+c;
	}
	Sx=sqrt(c/4);	
	ua=(Sx*1.14)/sqrt(5);
	switch (n) {
	case 1:
		uj=0.02/sqrt(3);
		break;
	case 2:
		uj=0.5/sqrt(3);
		break;
	case 3:
		uj=0.00125/sqrt(3);
		break;
	default:
		//TODO
		break;
	}
	ud=sqrt((ua*ua)+(uj*uj));
	Ed=ud/b;
	printf("ux为%.6f\n",Sx);
	printf("uj为%.6f\n",uj);
	printf("ua为%.6f\n",ua);
	printf("ud为%.6f\n",ud);
	printf("ed为%.6f\n",Ed);
}

