#include<bits/stdc++.h>
using namespace std;
typedef long long ll;
bool st[100500];
ll prime[100000];
//ll minprime[100500];//最小质因子
ll cnt=1;
void oula(ll o){
	
	st[1]=1;
	//minprime[1]=1;
	for(int i=2;i<=o;i++){
		if(!st[i]){
			prime[cnt++]=i;
//			minprime[i]=i;
		}
		for(int j=1;i*prime[j]<=o;j++){
			st[prime[j]*i]=1;
			//minprime[prime[j]*i]=prime[j];
			if(i%prime[j]==0){
				break;
			}
		}
	}
}
int main(){
	oula(1000);
	for(int i=1;i<=cnt;i++){
		cout<<prime[i]<<endl;
	}
	
	return 0;
}
