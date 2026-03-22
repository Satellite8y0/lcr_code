#include<bits/stdc++.h>
using namespace std;
#define ll long long
const ll N=1e6+1;
int a[N],b[N];
void swap(int* a,int* b)
{
	int temp;
	temp=*a;
	*a=*b;
	*b=temp;
}
void Heap(int n,int i)
{
	int largest=i;
	int lchild=2*i+1;
	int rchild=2*i+2;
	if(lchild<n&&a[largest]<a[lchild])
	{
		largest=lchild;
	}
	if(rchild<n&&a[largest]<a[rchild]) 
	{
		largest=rchild;
	}
	if(largest!=i)
	{
		swap(&a[largest],&a[i]);
		Heap(n,largest);
	}
}
void Heapsort(int n)
{
	int i;
	for(i=n/2-1;i>=0;i--)
	{
		Heap(n,i);
	}
	for(int i=n-1;i>0;i--)
	{
		swap(&a[i],&a[0]);
		Heap(i,0);
	}
}
int main()
{
	int n;
	cin>>n;
	for(int i=0;i<n;i++)
	{
		cin>>a[i];
	}
	Heapsort(n);
	for(int i=0;i<n;i++) cout<<a[i]<<" ";
}
