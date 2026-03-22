#include<bits/stdc++.h>
using namespace std;
#define ll long long
int main()
{
	int t,j,i,x,n;
	cin>>n;
	int a[n],b[n][n]={0},k=0;
	for(int i=0;i<n;i++){
		cin>>a[i];
	}
	for(i=1;i<n+1;i++){
		k=0;
		for(j=0;j<n;j++){
			if(a[j]%10==i%10){
				b[i][k]=j;
				k++;
			}
		}
	}
	i=0;
	j=1;
	while(j<n+1){
		k=0;
		while(b[j][k]){
			t=a[i];
			a[i]=a[b[j][k]];
			a[b[j][k]]=t;
			i++;
			k++;
		}
		j++;
	}
	for(i=0;i<n;i++){
		printf("%d ",a[i]);
	}
	b[11][11]={0};
	printf("\n");
	for(i=1;i<n+1;i++){
		k=0;
		for(j=0;j<n;j++){
			if(a[j]/10==i/10){
				b[i][k]=j;
				k++;
			}
		}
	}
	i=0;
	j=1;
	while(j<n+1){
		k=0;
		while(b[j][k]){
			t=a[i];
			a[i]=a[b[j][k]];
			a[b[j][k]]=t;
			i++;
			k++;
		}
		j++;
	}
	for(i=0;i<n;i++){
		printf("%d ",a[i]);
	}
	printf("\n");
	return 0;
} 
