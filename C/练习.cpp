#include<bits/stdc++.h>
using namespace std;
#define ll long long
const ll N=1e7;
ll a[N],b[3000][3000],c[N],n,m,sum,summ;
int main()
{
	cin>>n;
	for(int i=1;i<=n;i++){
		cin>>a[i];
		for(int j=1;j<=a[i];j++){
			cin>>b[i][j];
		}
		sum+=a[i];
	}
	cin>>m;
	for(int i=1;i<=n;i++){
		ll t=m-sum+a[i],maxx;
		if(sum-a[i]>=m){
			t=1;
		}
		maxx=min(a[i],m);
		for(int j=t;j<=maxx;j++){
			summ+=b[i][j];
			summ%=1000000007;
		}
	}
	summ%=1000000007;
	cout<<summ;
	return 0;
}
