#include<bits/stdc++.h>
#include<windows.h>
using namespace std;
#define ll long long
const ll N=1e7;
ll a[N],n,t,m,b[N],d[N],ans=999999;
void dfs1(ll x,ll n1,ll t1)
{
	if(x>m){
		if(n1==1&&t1==0)return;
		ans=min(abs(n-t),ans);
		return;
	}
	dfs1(x+1,n1*a[x],t1+b[x]);
	dfs1(x+1,n1,t1); 
}
void dfs2(){
	ll u=1<<m;
	for(int i=1; i<u; i++) {
		t=1,n=0;
		for(int j=0; j<=m; j++) {
			if(i&(1<<j)) {
				t*=a[j];
				n+=b[j];
			}
		}
		ans = min(ans,abs(t-n));
	}
}
int main()
{
	DWORD time_start, time_end;
	ll i=1;
	cout<<"题目取自洛谷：P2036 [COCI2008-2009#2] PERKET"<<endl;
	cout<<"输入数据量m:"<<endl;
	cin>>m;
	while(m>=i){
		a[i]=rand() % m;
		i++;
	}
	i=1;
	while(m>=i){
		b[i]=rand() % m;
		i++;
	}
	cout<<"搜索"<<endl;
	time_start=GetTickCount();
	dfs1(1,1,0);
	time_end=GetTickCount();
	cout<<"时间复杂度为O (2^n)"<<endl;
	cout<<"运行时间:"<<(time_end-time_start)<<endl;
	cout<<"***********************************"<<endl;
	cout<<"枚举"<<endl;
	time_start=GetTickCount();
	dfs2();
	time_end=GetTickCount();
	cout<<"时间复杂度为O(n^2)"<<endl;
	cout<<"运行时间:"<<(time_end-time_start)<<endl;
	cout<<"***********************************";
	return 0;
}
