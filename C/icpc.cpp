#include <bits/stdc++.h>
using namespace std;
const long long N = 1e8+ 10;
typedef long long ll;
ll mod =1e9+7;
ll n,m;
ll a[500500];

void solve() {
	cin>>n;
	for(int i=0;i<=1000;i++){
		a[i]=0;
	}
	for(int i=1;i<=n;i++){
		cin>>a[i];
	}
	
	ll cnt=0;
	pair<ll,ll>p[n/2+10];
	for(int i=1;i<=n;i++){
		if(a[i]==i){
			continue;
		}
		ll jl=n+10;
		for(int j=n;j>=i;j--){
			if(a[j]<a[i]){
				p[++cnt]={i,j};
				//cout<<i<<" "<<j<<endl;
				jl=j;
				break;
			}
		}
		if(jl==n){
			break;
		}
		sort(a+i,a+jl);
	}
	cout<<cnt<<endl;
	for(int i=1;i<=cnt;i++){
		cout<<p[i].first<<" "<<p[i].second<<endl;
	}
	cout<<endl;
	/*1
	  9
	  6 1 2 3 8 9 4 5 7*/
}
int main() {
	ios::sync_with_stdio(false);
	cin.tie(0);
	cout.tie(0);
	int t = 1;
	cin >> t; 
	while (t--) {
		solve();
	}
	return 0;
}

