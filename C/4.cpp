#include<bits/stdc++.h>
using namespace std;
typedef long long ll;
typedef double db;
const ll mod=998244353;
struct t{
	ll id;
	ll x;
};
const ll N=2e6+10;
ll n,m,p,q,k;
ll a[1000100];
void solve(){
    string s;
	cin>>s;
	ll res=s.length();
	if(s[0]==')'||s[res-1]=='('){
		cout<<1<<endl;
		return ;
	}
	for(int i=0;i<res;i++){
		if(s[i]=='('){
			n++;
		}
		else m++;
	}
	if(n==m){
		cout<<0<<endl;
		return ;
	}
	s=' '+s;
	ll ans=0;
	if(n>m){
		n=0,m=0;
		ll jl=1;
		for(int i=1;i<=res;i++){
			if(s[i]=='('){
				n++;
			}
			else {
				m++;
				if(i==res||s[i+1]=='('){
					
					if(n>m+1){
						ans+=n-jl;
						jl=n;
					}
					else {
						jl=n;
					}
				}
			}
			if(n==m){
				ans=0;
				jl=n+1;
			}
		}
		cout<<ans<<endl;
	}
	else {
		n=0,m=0;
		ll jl=1;
		for(int i=res;i>=1;i--){
			if(s[i]=='('){
				n++;
				if(i==1||s[i-1]==')'){
					if(n+1<m){
						ans+=m-jl;
						jl=m;
					}
					else jl=m;
				}
			}
			else {
				m++;
			}
			if(n==m){
				ans=0;
				jl=m+1;
			}
		}
		cout<<ans<<endl;
	}
}
int main(){
	int t=1;
	//cin >> t;
	while(t--){
		solve();
	}
	return 0;
}
