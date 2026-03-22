#include<bits/stdc++.h>
using namespace std;
#define ll long long
ll dp[500][500];//n和m最大才30随便开
ll n,m;
int main()
{
	dp[0][1]=1;//dp[i][j]的含义是传第i次时，刚好传到第j个人的方案数。
	cin>>n>>m;
	for(int i=1;i<=m;i++){
		for(int j=1;j<=n;j++){
			if(j==1){//特判一下1可以被n传过来
				dp[i][j]=dp[i-1][2]+dp[i-1][n];//能从传第i-1次刚好传到两边的两个状态转移到当前状态
			}
			else if(j==n){//特判一下n可以被1传过来
				dp[i][j]=dp[i-1][1]+dp[i-1][n-1];
			}
			else dp[i][j]=dp[i-1][j+1]+dp[i-1][j-1];
		}
	}
	cout<<dp[m][1]<<endl;//返回传了n次后回到1手中的方案数
	return 0;
}
