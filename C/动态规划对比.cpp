#include<bits/stdc++.h>
#include<windows.h>
using namespace std;
#define ll long long
const ll N=1e7;
ll a[N],n,t,m,b[N],d[N];
void dp1(ll c,ll num){
	for(int i=0;i<num;i++){
		for(int j=c;j>=a[i];j--){
			if(d[j]<d[j-a[i]]+b[i]){
				d[j]=d[j-a[i]]+b[i];
			}
		}
	}
}
void dp2(ll p,ll l,ll ta){
	if(p>=m&&l<=t){
		if(ta>n){
			n=ta;
		}
	}
	if(p>=m||l>t){
		return;
	}
	dp2(p+1,l+b[p],ta+a[p]);
	dp2(p+1,l,ta);
}
int main()
{
	DWORD time_start,time_end;
	ll i=1;
	cout<<"题目取自洛谷：P1048 [NOIP2005 普及组] 采药"<<endl;
	cout<<"输入数据 t，m:"<<endl;
	cin>>t>>m;
	while(m>=i){
		a[i]=rand() % m;
		i++;
	}
	i=1;
	while(m>=i){
		b[i]=rand() % m;
		i++;
	}
	cout<<"DP解法"<<endl;
	time_start=GetTickCount();
	dp1(t,m);
	time_end=GetTickCount();
	cout<<"时间复杂度为O(V*m)"<<endl;
	cout<<"运行时间:"<<(time_end-time_start)<<endl;
	cout<<"***************************************"<<endl;
	/*cout<<"暴力搜索解法"<<endl;
	time_start=GetTickCount();
	dp2(0,0,0);
	time_end=GetTickCount();
	cout<<"时间复杂度为O(2^m)"<<endl;
	cout<<"运行时间:"<<(time_end-time_start)<<endl;
	cout<<"***************************************";*/
	return 0;
	
}
