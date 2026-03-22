#include<bits/stdc++.h>
using namespace std;
#define ll long long
ll dp[200000];
ll a[2002000];
ll n;
int main()
{
	cin>>n;
	ll ans=0;
	for(int i=1;i<=n;i++){
		cin>>a[i];
		dp[i]=1;
		for(int j=1;j<=i-1;j++){
			if(a[i]>a[j]){
				dp[i]=max(dp[i],dp[j]+1);
				ans=max(dp[i],ans);
			}
		}
	}
	cout<<ans;
	return 0;
}
