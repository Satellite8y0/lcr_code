#include<bits/stdc++.h>
using namespace std;
#define ll long long
struct t{
	ll x;
	ll y;
	ll w;
};
bool cmp(t a,t b){
	return a.w>b.w;
}
ll n,m,ans,p[15][15];
ll a[15][15];
int main()
{
	for(int i=1;i<=13;i++){
		for(int j=1;j<=13;j++){
			cin>>a[i][j];
		}
	}
	for(int i=1;i<=13;i++){
		for(int j=1;j<=13;j++){
			if(a[i-1][j-1]>0){
				p[i][j]=max(p[i-1][j]+a[i-1][j-1],p[i][j-1]);
			}
			else p[i][j]=max(p[i-1][j],p[i][j-1]);
		}
	}
	cout<<p[13][13]<<endl;
	return 0;
}

