//#pragma GCC optimize(2)
#include<bits/stdc++.h>
#include <ext/rope>
using namespace __gnu_cxx;
using namespace std;

#define ll long long
#define f(x) for(ll i = 1; i <= x; ++ i)
#define f1(x) for(ll j = 1; j <= x; ++ j)
#define lowbit(x) ((-x)&x)
#define PII pair<ll, ll>
#define yes cout << "YES\n";
#define no cout << "NO\n";
ll mod = 998244353;

ll ksm(ll x, ll k)
{
	ll res = 1;
	while(k){
		if(k & 1){
			res = res * x % mod;
			
		}
		x = x * x % mod;
		k >>= 1;
	}
	return res;
}

ll inv(ll x){
	return ksm(x, mod - 2);
}

void solve(){
	ll n, m;
	cin >> n >> m;
	for (ll i = 1; i <= 125; i ++){
		for (ll j = 1; j <= 125; j ++){
			
			if((i*inv(j))%mod==577110017){
				cout << i << ' ' << j << endl;;
			}
		}
	}
}

int main()
{
	ios :: sync_with_stdio(false);
	cin.tie(nullptr);
	
	ll t = 1;
	//    cin >> t;
	
	while(t--){
		solve();
	}
	return 0;
}
