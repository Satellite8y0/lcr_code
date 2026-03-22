#include <bits/stdc++.h>
typedef  long long ll;
typedef unsigned long long  ULL;
using namespace std;
const ll N = 3e6+10;

typedef struct bba{
	ll l,r;
}nd;
ll n,k;
nd ans[N];
ll mod=998244353;
ll diff[N];
typedef struct cnm{
	ll l,r;
	ll sum=0;
	ll laz=0;
	ll mx=0;
}node;
node tr[N];
ll mp[N];
void push_down(ll p)
{
	if(tr[p].laz){
		tr[p].mx=(tr[p].mx+tr[p].laz)%mod;
		//cal_lazy(p);  计算懒标记
		if(tr[p].l!=tr[p].r){
			ll lc=2*p,rc=2*p+1;
			tr[lc].laz=(tr[lc].laz+tr[p].laz)%mod;
			tr[rc].laz=(tr[rc].laz+tr[p].laz)%mod;
			///union_lazy(p,lc);  //懒标记下沉
			//union_lazy(p,rc);
		}
		tr[p].laz=0;
		//init_lazy(p);  //懒标记初始化
	}
}
void update(ll p)
{
	push_down(2*p);
	push_down(2*p+1);
	tr[p].mx=max(tr[2*p].mx,tr[2*p+1].mx);
}
void build(ll p,ll l,ll r)
{
	tr[p].l=l,tr[p].r=r;
	if(l!=r){
		ll mid=(l+r)/2;
		ll lc=2*p,rc=2*p+1;
		build(lc,l,mid);
		build(rc,mid+1,r);
		update(p);
	}
	else{
		tr[p].mx=0;
	}
}
ll query(ll p,ll l,ll r)  //查询
{
	push_down(p);
	if(tr[p].l>=l && tr[p].r<=r)  return tr[p].mx;
	
	ll mid=(tr[p].l+tr[p].r)/2;
	ll lc=2*p,rc=2*p+1;
	if(r<=mid) return query(lc,l,r);  //只查左半区
	else if(l>mid)  return query(rc,l,r); //只查右半区
	else return max(query(lc,l,mid),query(rc,mid+1,r));
	//if(l<=mid)   s+=query(lc,x,y);
	//if(r>mid)  s+=query(rc,x,y);
}
void change(ll p,ll l,ll r,ll k) //区间修改
{
	push_down(p);
	if(tr[p].l==l && tr[p].r==r)
	{
		//tr[p].sum+=(tr[p].r-tr[p].l+1)*k;
		tr[p].laz=(tr[p].laz+k)%mod;
		return ;
	}
	ll mid=(tr[p].l+tr[p].r)/2;
	ll lc=2*p,rc=2*p+1;
	if(r<=mid)  change(lc,l,r,k);
	else if(l>mid)  change(rc,l,r,k);
	else{
		change(lc,l,mid,k);
		change(rc,mid+1,r,k);
	}
	update(p);
}
bool cmp(nd x,nd y)
{
	if(x.l==y.l)  return x.r<y.r;
	return x.l<y.l;
}
void solve()
{
	cin>>n>>k;
	for(int i=0;i<=2*n+10;i++) {
		tr[i].l=tr[i].r=tr[i].sum=tr[i].laz=tr[i].mx=0;
	}
	vector<ll> g;
	g.push_back(-1);
	for(int i=1;i<=n;i++){
		cin>>ans[i].l>>ans[i].r;
		g.push_back(ans[i].l),g.push_back(ans[i].r);
	}
	//离散化
	sort(g.begin(),g.end());
	map<ll,ll> mapp;
	for(ll i=0;i<g.size();i++){
		if(!mapp.count(g[i]))  mapp[g[i]]=i;
	}
	for(int i=1;i<=n;i++){
		ans[i].l=mapp[ans[i].l];
		ans[i].r=mapp[ans[i].r];
	}
	//不能离线做
	sort(ans+1,ans+n+1,cmp);
	build(1,1,2*n+5);
    ll res=1;
	for(int i=1;i<=n;i++){
		//cout<<"l="<<ans[i].l<<" "<<ans[i].r<<endl;
		change(1,ans[i].l,ans[i].r,1);
		//cout<<"mx="<<query(1,ans[i].l,ans[i].r)<<endl;
		
		res=res*max(0ll,k-query(1,ans[i].l,ans[i].r)+1)%mod;
		//cout<<"i="<<i<<endl;
		//for(int i=1;i<=7;i++)  cout<<tr[i].mx<<" ";
		//cout<<endl;
	}
	cout<<ll(res)<<endl;
}
int main()
{
	std::ios::sync_with_stdio(false);
	cin.tie(0); 
	cout.tie(0);
	ll t=1;
	cin>>t;
	while(t--){
		solve();
	}
}

