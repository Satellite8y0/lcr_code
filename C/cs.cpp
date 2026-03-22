#include<bits/stdc++.h>
using namespace std;
#define ll long long
ll mod=1e9+7;
ll n,m,k;
int main()
{
	ll a=0;
	for(int i=1;i<=100;i++){
		a=rand()%50;
		cout<<a<<" ";
		if(i%10==0){
			cout<<endl;
		}
	}
	return 0;
}
