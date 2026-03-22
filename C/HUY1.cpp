#include<bits/stdc++.h>
using namespace std;
typedef long long ll;
typedef double db;
ll n,m,k;
ll robot[500520],spike[500520];
ll robot_spike_left[500520],robot_spike_right[500520];//每个机器人与左右最近刺的距离
void solve(){
	cin>>n>>m>>k;
	map<ll,vector<ll>>dead;//统计离左右最近刺距离为i的机器人数量
	for(int i=1;i<=n;i++){
		cin>>robot[i];
	}
	for(int i=1;i<=m;i++){
		cin>>spike[i];
	}
	sort(robot+1,robot+n+1);
	sort(spike+1,spike+m+1);
	//二分查找每个机器人左右刺
	for(int i=1;i<=n;i++){
		ll l=1,r=m;
		while(l<r){
			ll mid=(l+r)/2;
			if(robot[i]>spike[mid]){
				l=mid+1;
			}
			else r=mid;
 		}
		if(spike[r]>robot[i]){//查找出的刺在机器人右边
			if(r==1){//特判边缘
				robot_spike_left[i]=0;
				robot_spike_right[i]=spike[r]-robot[i];
			}
			else{
				robot_spike_left[i]=spike[r-1]-robot[i];
				robot_spike_right[i]=spike[r]-robot[i];
			}
		}
		else {//刺在左边
			if(r==m){//特判边缘
				robot_spike_left[i]=spike[r]-robot[i];
				robot_spike_right[i]=0;
			}
			else{
				robot_spike_left[i]=spike[r]-robot[i];
				robot_spike_right[i]=spike[r]-robot[i];
			}			
		}
	} 
	for(int i=1;i<=n;i++){
		dead[robot_spike_left[i]].push_back(i);
		dead[robot_spike_right[i]].push_back(i);
	}
    string operation;
	ll deviation=0;//偏离量   左：-1；右：+1
	//ll left_deviation=0,right_deviation=0;//最左最右偏移
	cin>>operation;
	ll ans=n;
	bool alive[500520];
	for(ll i=0;i<operation.length();i++){
		if(operation[i]=='L'){
			deviation--;
		}
		if(operation[i]=='R'){
			deviation++;
		}
		for(ll j:dead[deviation]){
			if(alive[j]){
				continue;
			}
			alive[j]=true;
			ans--;
		}
		dead[deviation].clear();
		
		cout<<ans<<" ";
	}
	cout<<endl;
}
int main(){
	int t=1;
	cin>>t;
	ll h=t;
	while(t--){
		solve();
	}
	return 0;
}

