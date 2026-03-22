#include<bits/stdc++.h>
#include<windows.h>
using namespace std;
#define ll long long
const ll N=1e7;
ll a[N],n,t,m,b[N],d[N];
void bag1(ll c,ll num){
	for(int i=0;i<num;i++){
		for(int k=0;k<=d[i];k++){
			for(int j=c;j>=a[i];j--){
				if(b[j]<b[j-a[i]]+a[i]){
					b[j]=b[j-a[i]]+a[i];
				}
			}
		}
	}
}
void bag2(ll c,ll num){
	for(int i=0;i<num;i++){
		for(int j=a[i];j<=c;j++){
			if(b[j]<b[j-a[i]]+a[i]){
				b[j]=b[j-a[i]]+a[i];
			}
		}
	}
}
int main()
{
	DWORD time_start, time_end;
	ll i=1;
	cout<<"题目取自洛谷：P1048 [NOIP2005 普及组] 采药"<<endl;
	cout<<"输入数据 t，m:"<<endl;
	cin>>t>>m;
	while(n>=i){
		a[i]=rand() % m;
		i++;
	}
	i=1;
	while(m>=i){
		b[i]=rand() % m;
		i++;
	}
	i=1;
	while(m>=i){
		d[i]=rand() % 100;
		i++;
	}
	cout<<"多重背包"<<endl;
	time_start=GetTickCount();
	bag1(t,m);
	time_end=GetTickCount();
	cout<<"时间复杂度为O (V*∑ ni=1 log2 (ki))"<<endl;
	cout<<"运行时间:"<<(time_end-time_start)<<endl;
	cout<<"***********************************";
	cout<<"完全背包"<<endl;
	time_start=GetTickCount();
	bag2(t,m);
	time_end=GetTickCount();
	cout<<"时间复杂度为O(m*V)"<<endl;
	cout<<"运行时间:"<<(time_end-time_start)<<endl;
	cout<<"***********************************";
	return 0;
}
