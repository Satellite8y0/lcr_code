#include<bits/stdc++.h>
#include<windows.h>
using namespace std;
#define ll long long
const ll N=1e7;
int num;
ll a[N],b[N],n;
void merge(int start, int mid, int end)
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
void mergeSort(int start,int end)
{
	if (a == NULL || start >= end)
		return;
	int mid = (end + start) / 2;
	mergeSort(start, mid);
	mergeSort(mid + 1, end);
	merge(start, mid, end);
}
void sort1(){
	DWORD time_start, time_end;
	ll n,i=0;
	time_t t;
	cout<<"输入数据量"<<endl;
	cin>>n;
	srand((unsigned) time(&t));
	cout<<"归并排序"<<endl;
	while(n>i){
		a[i]=rand() % n;
		i++;
	}
	time_start=GetTickCount();
	mergeSort(0,n-1);
	time_end=GetTickCount();
	cout<<"时间复杂度O(nlog'n)"<<endl;
	cout<<"运行时间:"<<(time_end-time_start)<<endl;
	cout<<"***************************************"<<endl;
	memset(a,0,n);
	cout<<"冒泡排序"<<endl;
	time_start=GetTickCount();
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
	time_end=GetTickCount();
	cout<<"时间复杂度O(n^2)"<<endl;
	cout<<"运行时间:"<<(time_end-time_start)<<endl;
	cout<<"***************************************"<<endl;
}
int main()
{
	sort1();
	return 0;

}
