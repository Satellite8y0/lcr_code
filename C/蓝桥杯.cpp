#include <bits/stdc++.h>
using namespace std;
#define ll long long
ll ans=0;
ll mod=998244353;
struct root {
	ll x;
	ll y;
};
ll n,m;
ll x[5005000];
ll y[5005000];
ll z[5005000];
map<ll, ll>maps;
bool cmp(root a,root b){
	if(a.x==b.x){
		return a.y<b.y;
	}
	return a.x<b.x;
}
ll k;
void solve(){
	cin>>n>>k;
	ll minx=n-(k-1)/2;
	ll res=(k+1)/2;
	ll maxx;
	if(n>=res){
		maxx=n+k-res;
	}
	else {
		maxx=n*2;
	}
	cout<<minx<<" "<<maxx<<endl;
}
int main()
{
	ios :: sync_with_stdio(0); 
	cin.tie(0);
	ll temp=1;
	cin>>temp;
	while(temp--){
		solve();
	}
	return 0;
}
/*
  1 3
  0.3333
  
  
  
  
 */
