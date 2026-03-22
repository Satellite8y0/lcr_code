#include<bits/stdc++.h>
using namespace std;
#define ll long long
int main()
{
	int t,j,i,x,n;
	cin>>n;
	int a[n];
	for(i=0;i<n;i++)
	{
		cin>>a[i];
	}
	for(i=0;i<n;i++)
	{
		t=i;
		for(j=i;j<n;j++)
		{
			if(a[j]<a[t])
			{
			t=j;
			}
		}
	 x=a[t];
	 a[t]=a[i];
	 a[i]=x;
	}
	for(i=0;i<n;i++)
	{
		cout<<a[i]<<" ";
	}
	return 0;
} 
