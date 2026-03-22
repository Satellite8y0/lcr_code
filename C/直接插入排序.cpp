#include<bits/stdc++.h>
using namespace std;
#define ll long long
const ll N=3e5+10;
ll a[N],b[N],n;
int main()
{
	int n;
	int i,j,t;
	cin>>n;
	for(int i=0;i<n;i++)
	{
		cin>>a[i];
	}
	for( i=1;i<n;i++)
	{
		if(a[i]<a[i-1])
		{
			t=a[i];
			for( j=i-1;(j>=0)&&(t<=a[j]);j--)
			{
				a[j+1]=a[j];
			}
			a[j+1]=t;
		}
	}
	for(int i=0;i<n;i++) cout<<a[i]<<" ";
}

