#include<stdio.h>
int main()
{/*假设成兔每个月都生幼兔*/
	int n=2,m=0,p=0,z;
	for(int i=0;i<=19;i++)
	{
		p=p+m;
		m=n;
		n=p;
		z=n+m+p;
		printf("第%d个月兔子数为：%d\n",i+1,z);
	}
	return 0;
} 
