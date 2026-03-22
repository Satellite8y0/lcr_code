#include <bits/stdc++.h>
using namespace std;
const long long N = 2e5+ 10;
typedef long long ll;
const ll mod =1e9+7;
ll n;
string res;
map<char,char>mapp;
ll r[N], l[N];


void solve2() {
	string tmp;
	cin >> tmp;
	char c = tmp[0];
	res += c;
	for (int i = 0; i < tmp.size(); i ++) {
		if (tmp[i] != c) {
			res += tmp[i];
			c = tmp[i];
		}
	}
	
	for (int i = 1; i < res.size(); i ++) {
		l[i] = i -1;
	}
	for (int i = 0; i < res.size() - 1; i ++) {
		r[i] = i + 1;
	}
	
	for (int i = 0; r[i] != 0; i = r[i]) {
	}
	
	
}
char check(char a,char b){
	if(a==mapp[b]){
		return a;
	}
	else return b;
}
void solve() {
	cin>>n;
	cout<<2*n<<endl;
	for(int i=1;i<=2*n;i++){
		cout<<i<<" "<<i<<endl;
	}
	
	
	
	
}
int main() {
	mapp['R']='P';
	mapp['P']='S';
	mapp['S']='R';
	ios::sync_with_stdio(false);
	cin.tie(0);
	cout.tie(0);
	int t = 1;
	//cin >> t; 
	while (t--) {
		solve();
	}
	return 0;
}
/*
  4 3 0
  1 2
  1 3
  1 4
 */

