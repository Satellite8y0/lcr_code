#include<bits/stdc++.h>
#include<windows.h>
using namespace std;
#define ll long long
const ll N=1e7;
ll a[N],n,l,h,mid;
void search1(ll b,ll num){
	h=num;
	l=1;
	while(l<=h)
	{
		mid=(l+h)/2;
		n++;
		if(b>a[mid])
		{
			l=mid+1;
		}
		else if(b<a[mid])
		{
			h=mid-1;
		}
		else break;
	}
}
void search2(ll b,ll num){
	for(int i=1;i<=num;i++){
		n++;
		if(a[i]==b){
			break;
		}
	}
}
int main()
{
	ll num,i=1;
	cout<<"输入数据量"<<endl;
	cin>>num;
	time_t t;
	srand((unsigned) time(&t));
	while(num>=i){
		a[i]=rand() % num;
		i++;
	}
	a[0]=a[1];
	sort(a+1,a+1+num);
	cout<<"二分查找"<<endl;
	search1(a[0],num);
	cout<<"时间复杂度为O(log'2'n)"<<endl;
	cout<<"查找次数:"<<n<<endl;
	cout<<"***************************************"<<endl;
	cout<<"枚举查找"<<endl;
	n=0;
	search2(a[0],num);
	cout<<"时间复杂度为O(n)"<<endl;
	cout<<"查找次数:"<<n<<endl;
	cout<<"***************************************"<<endl;
	return 0;
	
}
