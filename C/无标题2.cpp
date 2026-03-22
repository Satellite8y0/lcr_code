#include<bits/stdc++.h>
using namespace std;
const int N=2e5+10;
long long a[N];
int main(){
	int t;
	cin>>t;
	while(t--){
		map<long long,long long> q;
		long long sum=0,ans=0,n;
		cin>>n;
		for(int i=1;i<=n;i++) {
			cin>>a[i];
			q[a[i]]=1;
			sum+=a[i];
			if(sum%2!=0) continue;
			else{
				if(q[sum/2]) cout<<sum<<" "<<sum/2<<endl,ans++;
			}
		}
		cout<<ans<<endl;
	}
	return 0;
}
