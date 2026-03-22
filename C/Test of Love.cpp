#include<bits/stdc++.h>
using namespace std;
#define ll long long
ll dp[500500];
ll n,m,k;
string s;
void solve(){
	cin>>n>>m>>k;
	cin>>s;
	s='L'+s;//在岸上也可以看作是可跳跃的木头
	for(int i=0;i<=n+20;i++){
		//dp存放的是到当前位置需要在水里游的最小距离
		dp[i]=1e9;//给超大初值，如果游不到就会被判定为太冷了
	}
	dp[0]=0;
	for(int i=0;i<=n;i++){
		if(s[i]=='L'){
			//木头可以跳m格
			for(int j=i;j<=i+m;j++){
				dp[j]=dp[i];//因为后面m格肯定还没遍历到所以直接赋值就好
			}
		}
		if(s[i]=='W'){
			dp[i+1]=min(dp[i+1],dp[i]+1);//当前格的下一格要么是之前跳过去的，要么当前格是游过去的
		}
	}
	if(dp[n+1]>k){//如果水里游太久，或者是开始赋的初值，都会判定成游太久
		cout<<"NO"<<endl;
	}
	else cout<<"YES"<<endl;
}
int main()
{
	int t=1;
	cin >> t;
	while(t--){
		solve();
	}
	return 0;
}
