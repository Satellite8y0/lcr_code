#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<time.h>
#include<math.h>
int main()
{
	int m,n,a,b,c,count=0;
	printf("输入m:");
	scanf("%d",&m);
	int i[n],j,k,sum;
	printf("输入n:");
	scanf("%d",&n);
	b=pow(10,n-1);
	a=pow(10,n);
	while(b<a){
		c=b;
		k=0;
		sum=0;
		j=0;
		while(n-j){
		j++;
		i[n-j]=c%10;
		sum=sum+i[n-j];
		c=c/10;
		}
		while(j)
		{
			if((j)%2==i[j-1]%2){
				k++;
			}
			j--;
		}
		if((k==n)&&(sum<=m)){
			count++;
		}
		b++;
	}
	printf("%d\n",count);
	return 0;
} 
