#include<bits/stdc++.h>
using namespace std;
#define ll long long
const ll N=3e5+10;
ll a[N],b[N],n;
using namespace std;
void merge(ll a[], int start, int mid, int end)
{
	int *tmp=new int[end-start+1];
	int i=start;
	int j=mid+1;
	int k=0;
	while(i<=mid&&j<=end)
	{
		if(a[i]<=a[j])
			tmp[k++]=a[i++];
		else
			tmp[k++]=a[j++];
	}
	while(i<=mid)
		tmp[k++]=a[i++];
	while(j<=end)
		tmp[k++]=a[j++];
	for(i=0;i<k;i++)
		a[start+i]=tmp[i];
}
void mergeSortUp2Down(ll a[],int start,int end)
{
	if (a == NULL || start >= end)
		return;
	int mid = (end + start) / 2;
	mergeSortUp2Down(a, start, mid);
	mergeSortUp2Down(a, mid + 1, end);
	merge(a, start, mid, end);
}
int main()
{
	int i;
	int n;
	cin>>n;
	for(int i=0;i<n;i++){
		cin>>a[i];
	}
	mergeSortUp2Down(a,0,n-1);
	for(i=0;i<n;i++)
		cout<<a[i]<<" ";
	cout<<endl;
	return 0;
}
