#include <bits/stdc++.h>   
using namespace std;
#define ll long long
ll ans,n,m;
ll a[500500];
int main() {  
	cin>>n>>m;
	ll i=0,j=0,k=n;
	while(k){
		if(a[i%n]==0){
			j++;
		}
		if(j==m){
			k--;
			cout<<i%n+1<<" "; 
			a[i%n]=1;
			j=0;
		}
		i++;
	}
	return 0;  
}
