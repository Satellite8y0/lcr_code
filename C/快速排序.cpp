#include<bits/stdc++.h>
using namespace std;
#define ll long long
const ll N=3e5+10;
ll a[N],b[N],n;
int find(ll a[],int low,int high)
{
	int key,n=1;
	key=a[low];
	while(low<high)
	{
		while(low<high&&n==1)
		{
			if(a[high]<key)
			{
				a[low]=a[high];
				n=2;
				break;
			}
			else high--;
		}
		while(low<high&&n==2)
		{
			if(a[low]>key)
			{
				a[high]=a[low];
				n=1;
				break;
			}
			else low++;
		}
	}
	a[low]=key;
	return high;
}
void sort(ll a[],int low,int high)
{
	int key;
	if(low<high)
	{
		key=find(a,low,high);
		sort(a,low,key-1);
		sort(a,key+1,high);
	}
}
int main()
{
	int n;
	cin>>n;
	int low=0,high=n-1;
	for(int i=0;i<n;i++)
	{
		cin>>a[i];
	}
	sort(a,low,high);
	for(int i=0;i<n;i++) cout<<a[i]<<' ';
}
