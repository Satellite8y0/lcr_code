#include<bits/stdc++.h>
using namespace std;
#define ll long long
const ll N=1e7;
ll a[N],b[N],n;
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
void sort1(){
	ll num;
	time_t t;
	srand((unsigned) time(&t));
	cout<<"归并排序"<<endl;
	cout<<"输入数据量"<<endl;
	cin>>num;
	while(num--){
		a[num]=rand() % 1000;
	}
	mergeSortUp2Down(a,0,n-1);
	cout<<"时间复杂度O(nlog'n)"<<endl;
	memset(a,0,num);
	cout<<"冒泡排序"<<endl;
	cout<<"输入数据量"<<endl;
	cin>>num;
	while(num--){
		a[num]=rand() % 1000;
	}
	for(int i=0;i<n-1;i++)
	{
		for(int j=0;j<n-i;j++)
		{
			if(a[j]>a[j+1])
			{
				t=a[j+1];
				a[j+1]=a[j];
				a[j]=t;
			}
		}
	}
	cout<<"时间复杂度O(n^2)"<<endl;
}
int main()
{	
	sort1();
	return 0;


}
