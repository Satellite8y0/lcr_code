#include <bits/stdc++.h>
using namespace std;
const long long N = 1e8+ 10;
typedef long long ll;
ll mod =1e9+7;
ll n,m;
ll a[100500];
ll dp[100500];
void solve() {
	cin>>n>>m;
	for(int i=1;i<=m;i++){
		dp[i]=100500;
	}
	for(ll i=1;i<=n;i++){
		cin>>a[i];
		for(ll j=a[i];j<=m;j++){
			dp[j]=min(dp[j-a[i]]+1,dp[j]);
		}
	}
	cout<<dp[m]<<endl;
}
int main() {
	ios::sync_with_stdio(false);
	cin.tie(0);
	cout.tie(0);
	int t = 1;
	//cin >> t; 
	while (t--) {
		solve();
	}
	return 0;
}

