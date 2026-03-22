#include<bits/stdc++.h>
using namespace std;
#define ll long long
const ll N=1e7;
struct t{
	ll x;
	ll y;
	ll z;
	ll w;
};
bool cmp(t a,t b){
	return a.x<b.x;
}
ll dp[100005][50],n,m,ans,x,y;
int main()
{	
	
	
	
	return 0;
}
/*
  ll dp[2000][2000];//i到j构成回文要插入多少字符
  string s ;
  void solve(){
  cin>>s;
  ll len=s.length();
  s=' '+s;
  for(ll l=2;l<=len;l++){//枚举当前字符的长度，长度为1的自己就是回文
  for(ll start=1;start<=len;start++){//枚举开头
  ll end=l+start-1;//计算出结尾
  if(s[start]==s[end]){
  dp[start][end]=dp[start+1][end-1];// 如果现在加入的元素一样答案不变
  }
  else {
  dp[start][end]=min(dp[start+1][end]+1,dp[start][end-1]+1);//如果不一样则需要插入2个元素
  }
  }
  }
  cout<<dp[1][len];//输出
  
  }
 */
/*
  ll dp[2000][2000];//dp[i][j]代表i个苹果放j个盘子时的方案数
  string s ;
  void solve(){
  cin>>n>>m;
  for(int i=0;i<=n;i++){
  for(int j=0;j<=m;j++){
  dp[i][j]=0;
  }
  }
  for(int i=0;i<=n;i++){
  dp[i][1]=1;//只有一个盘子时就一种方案
  }
  for(int i=0;i<=m;i++){
  dp[1][i]=dp[0][i]=1;//只有0个或1个苹果时只有一种方案
  }
  for(int i=2;i<=n;i++){
  for(int j=2;j<=m;j++){
  if(i>=j){//苹果数大于盘子数时
  dp[i][j]=dp[i-j][j]+dp[i][j-1];//每次有两种选择一种是每个盘子放一个，，或者拿掉一个盘子（这个盘子不放）
  }
  else dp[i][j]=dp[i][i];//苹果数小于盘子数时，和j个盘子放i个苹果是一样的
  }
  }
  cout<<dp[n][m]<<endl;
  
  }
 */
/*cin>>n>>m;
  for(int i=1;i<=n;i++){
  cin>>dp[i][0];
  }
  for(int i=1;i<=20;i++){
  //cout<<i<<endl;
  //ll t=pow(2,i);
  if((1<<i)>n){
  break;
  }
  for(int j=1;j<=n;j++){
  if((j+(1<<i)-1)<=n){
  //cout<<j<<"||";
  dp[j][i]=min(dp[j][i-1],dp[j+(1<<(i-1))][i-1]);
  //cout<<dp[j][i]<<" ";
  }
  }
  //cout<<endl;
  }
  for(int i=1;i<=m;i++){
  cin>>x>>y;
  ll k=log2(y-x+1);
  //ll t=pow(2,k);
  ans=min(dp[x][k],dp[y-(1<<k)+1][k]);
  cout<<ans<<" ";
  }*/
/*cin>>n>>m;
  for(int i=0;i<m;i++){
  cin>>b[i].w>>b[i].x>>b[i].y;
  }
  sort(b,b+m,cmp);
  for(int i=0;i<m;i++){
  dp[i]=1;
  for(int j=0;j<i;j++){
  if((abs(b[i].x-b[j].x)+abs(b[i].y-b[j].y))<=(b[i].w-b[j].w)){
  dp[i]=max(dp[i],dp[j]+1);
  }
  }
  }
  for(int i=0;i<m;i++){
  ans=max(ans,dp[i]);
  }
  cout<<ans;P2285 [HNOI2004] 打鼹鼠*/
/*cin>>n>>m;
  vector<ll>ve[n+1];
  for(int i=1;i<=m;i++){
  cin>>x>>y;
  ve[x].push_back(y);
  a[y]++;
  }
  for(int i=1;i<=n;i++){
  if(a[i]==0){
  dp[i]=1;
  que.push(i);
  }
  }
  while(!que.empty()){
  ans=que.front();
  //cout<<ans<<endl;
  que.pop();
  if(ve[ans].empty()){
  anss=(anss+dp[ans])%80112002;
  }
  for(auto i:ve[ans]){
  //cout<<i<<" ";
  dp[i]=(dp[i]+dp[ans])%80112002;
  a[i]--;
  if(a[i]==0){
  que.push(i);
  }
  }
  //cout<<endl;
  //for(int i=1;i<=n;i++){
  //	cout<<dp[i]<<" ";
  //}
  //cout<<endl;
  }
  anss=anss%80112002;
  cout<<anss;P4017 最大食物链计数*/
/*cin>>n>>k>>m;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  }
  sort(a+1,a+1+n);
  dp[0]=1;
  l=1;
  for(r=1;r<=n;r++){
  if(r<k){
  dp[r]=0;
  }
  else {
  if(r-l+1>=k){
  if(a[r]-a[l]<=m){
  dp[r]=1;
  }
  else {
  if(dp[r-k]&&a[r]-a[r-k]<=m){
  dp[r]=1;
  }
  else {
  dp[r]=0;
  l=r;
  }
  }
  }
  else {
  if(a[r]-a[l]<=m){
  if(dp[r-k]&&a[r]-a[r-k]<=m){
  dp[r]=1;
  }
  else dp[r]=0;
  }
  else  {
  cout<<"NO";
  return 0;
  }
  }
  }
  }
  for(int i=0;i<=n;i++){
  cout<<dp[i]<<" ";
  }
  cout<<endl;
  if(dp[n]){
  cout<<"YES";
  }
  else cout<<"NO";段坤大盗*/

/*cin>>n;
  for(int i=1;i<=n;i++){
  if(i==1){
  cin>>a[i]>>c[i];
  b[i][0]=c[i]-1+c[i]-a[i];
  b[i][1]=c[i]-1;
  }
  else {
  cin>>a[i]>>c[i];	
  b[i][0]=min(b[i-1][0]+abs(c[i]-a[i-1]),b[i-1][1]+abs(c[i-1]-c[i]))+c[i]-a[i]+1;
  b[i][1]=min(b[i-1][0]+abs(a[i-1]-a[i]),b[i-1][1]+abs(c[i-1]-a[i]))+c[i]-a[i]+1;
  }
  }
  cout<<min(b[n][0]+n-a[n],b[n][1]+n-c[n]);P3842线段*/
/*cin>>n>>m;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  }
  b[0][0]=1;
  for(ll i=1;i<=n;i++){
  for(ll j=0;j<=m;j++){
  minx=min(j,a[i]);
  for(ll p=0;p<=minx;p++){
  b[i][j]=(b[i][j]+b[i-1][j-p])%1000007;
  }
  }
  }
  for(int i=0;i<=n;i++){
  for(int j=0;j<=m;j++){
  cout<<b[i][j];
  }
  cout<<endl;
  }
  cout<<b[n][m];P1077摆花*/

/*a[0][1]=1;
  cin>>n>>m;
  for(int i=1;i<=m;i++){
  for(int j=1;j<=n;j++){
  if(j==1)
  a[i][j]=a[i-1][n]+a[i-1][2];
  else if(j==n)
  a[i][j]=a[i-1][1]+a[i-1][n-1];
  else
  a[i][j]=a[i-1][j-1]+a[i-1][j+1];
  }
  }
  cout<<a[m][1];
  P1057 传球游戏*/
/*cin>>n>>m;
  for(int i=1;i<=n;i++){
  cin>>a[i]>>b[i]>>c[i];
  for(int j=m;j>=c[i];j--){
  dp[j]=max(dp[j]+a[i],dp[j-c[i]]+b[i]);
  }
  for(int j=c[i]-1;j>=0;j--){
  dp[j]+=a[i];
  }
  }
  cout<<5*dp[m];P1802	5倍经验日*/
/*t d[10010];
  cin>>n>>m;
  for(int i=0;i<=n+1;i++){
  0	for(int j=0;j<=m+1;j++){
  if(i==0||j==0||i==n+1||j==m+1){
  b[i][j]=N;
  }
  else {
  cin>>b[i][j];
  dp[i][j]=1;
  d[x].x=i;
  d[x].y=j;
  d[x].num=b[i][j];
  x++;
  }
  }
  }
  sort(d,d+x,cmp);
  for(int i=0;i<n+1;i++){
  for(int j=0;j<m+1;j++){
  cout<<dp[i][j]<<" ";
  }
  cout<<endl;
  }
  for(int i=0;i<x;i++){
  maxx=0;
  if(b[d[i].x][d[i].y]>b[d[i].x-1][d[i].y]){
  maxx=max(maxx,dp[d[i].x-1][d[i].y]);
  }
  if(b[d[i].x][d[i].y]>b[d[i].x][d[i].y-1]){
  maxx=max(maxx,dp[d[i].x][d[i].y-1]);
  }
  if(b[d[i].x][d[i].y]>b[d[i].x+1][d[i].y]){
  maxx=max(maxx,dp[d[i].x+1][d[i].y]);
  }
  if(b[d[i].x][d[i].y]>b[d[i].x][d[i].y+1]){
  maxx=max(maxx,dp[d[i].x][d[i].y+1]);
  }
  dp[d[i].x][d[i].y]+=maxx;
  maxxx=max(dp[d[i].x][d[i].y],maxxx);
  }
  for(int i=0;i<n+1;i++){
  for(int j=0;j<m+1;j++){
  cout<<dp[i][j]<<" ";
  }
  cout<<endl;
  }
  cout<<maxxx;P1434滑雪*/
/*cin>>n;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  c[i]=a[i];
  }
  for(int i=1;i<n;i++){
  for(int j=i+1;j<=n;j++){
  cin>>b[i][j];
  }
  }
  maxx=a[1];
  x=1;
  for(int i=2;i<=n;i++){
  for(int j=1;j<i;j++){
  if(b[j][i]){
  if(c[i]<c[j]+a[i]){
  c[i]=c[j]+a[i];
  d[i]=j;
  }
  }
  if(maxx<c[i]){
  maxx=c[i];
  x=i;
  }
  }
  }
  int i=25;
  while(x){
  a[i]=x;
  i--;
  x=d[x];
  }
  for(int j=i+1;j<=25;j++){
  cout<<a[j]<<" ";
  }
  cout<<endl;
  cout<<maxx;P2196挖地雷*/
/*while(cin>>n){
  minx=1e9+10;
  for(int i=0;i<4;i++){
  for(int j=1;j<=n;j++){
  c[j][i]=1e9+10;
  }
  }
  for(int i=1;i<=n;i++){
  cin>>a[i];
  }
  for(int i=1;i<=n;i++){
  cin>>c[i][0];
  }
  for(int i=0;i<3;i++){
  for(int j=i;j<=n;j++){
  for(int p=1;p<=j;p++){
  if(a[j]>a[p]){
  c[j][i]=min(c[p][i-1]+c[j][0],c[j][i]);
  }
  }
  }
  
  }
  for(int i=3;i<=n;i++){
  minx=min(minx,c[i][2]);
  }
  if(minx==1e9+10){
  cout<<"-1"<<endl;
  }
  else cout<<minx<<endl;
  }sustoj 创客更新装备*/
/*cin>>n;
  for(int i=1;i<=n;i++){
  cin>>m;
  a[m]=i;
  }
  for(int i=1;i<=n;i++){
  cin>>b[i];
  c[i]=1e8;
  }
  c[0]=0;
  for(int i=1;i<=n;i++){
  ll l=0,r=maxx,mid;
  if(a[b[i]]>c[maxx]){
  maxx++;
  c[maxx]=a[b[i]];
  }
  else{
  while(l<r){
  mid=(l+r)/2;
  if(c[mid]>a[b[i]]){
  r=mid;
  }
  else l=mid+1;
  }
  c[l]=min(a[b[i]],c[l]);
  }
  }
  cout<<maxx<<endl;
  P1439 【模板】最长公共子序列*/
/*maxx=1;
  cin>>n;
  for(int i=1;i<=n;i++){
  cin>>b[i];
  a[i]=1;
  for(int j=1;j<=i-1;j++){
  if(b[i]>b[j]){
  a[i]=max(a[i],a[j]+1);
  maxx=max(maxx,a[i]);
  }
  }
  }
  cout<<maxx<<endl;B3637	最长上升子序列*/
/*cin>>n;
  for(int i=1;i<=n;i++){
  cin>>m;
  a[m]=i;
  }
  for(int i=1;i<=n;i++){
  cin>>m;
  b[i]=a[m];
  }
  maxx=1;
  
  for(int i=1;i<=n;i++){
  c[i]=1;
  for(int j=1;j<=i-1;j++){
  if(b[i]>b[j]){
  c[i]=max(c[i],c[j]+1);
  maxx=max(maxx,c[i]);
  }
  }
  }
  cout<<maxx<<endl;P1439 最长公共子序列（非dp 有错AC2个）*/

/*cin>>n>>m;
  for(int i=1;i<=m;i++){
  cin>>x>>y>>z;
  int flag=1;
  while(flag){
  if(z==0){
  for(int j=x;j<=n;j++){
  a[j]=max(a[j-x]+y,a[j]);
  }
  flag=0;
  }
  else {
  for(int p=1;p<=z;p++){
  for(int j=n;j>=x;j--){
  a[j]=max(a[j-x]+y,a[j]);
  }
  }
  flag=0;
  }
  }
  }
  cout<<a[n];算法实验*/

/*cin>>m;
  for(int i=1;i<=m;i++){
  cin>>a[i];
  }
  for(int i=1;i<=m;i++){
  cin>>b[i];
  }
  for(int i=1;i<=m;i++){
  for(int j=1;j<=m;j++){
  c[i][j]=max(c[i-1][j],c[i][j-1]);
  if(a[i]==b[j]){
  c[i][j]=max(c[i][j],c[i-1][j-1]+1);
  }
  }
  }
  cout<<c[m][m]<<endl;算法实验*/
/*cin>>n>>m;
  for(int i=1;i<=n;i++){
  for(int j=1;j<=m;j++){
  cin>>a[i][j].num;
  }
  }
  for(int i=1;i<=n;i++){
  for(int j=1;j<=m;j++){
  for(int p=1;p<=n;p++){
  for(int q=1;q<=m;q++){
  b[i][j][p][q]=max(max(b[i-1][j][p-1][q],b[i-1][j][p][q-1]),max(b[i][j-1][p-1][q],b[i][j-1][p][q-1]))+a[i][j].num+a[p][q].num;
  if(i==p&&q==j)b[i][j][p][q]-=a[i][j].num;
  }
  }
  }
  }
  cout<<b[n][m][n][m];P1006传纸条*/
/*cin>>n;
  cin>>x>>y;
  cin>>a[x][y].num;
  while(a[x][y].num||x||y){
  cin>>x>>y;
  cin>>a[x][y].num;
  }
  for(int i=1;i<=n;i++){
  for(int j=1;j<=n;j++){
  for(int p=1;p<=n;p++){
  for(int q=1;q<=n;q++){
  b[i][j][p][q]=max(max(b[i-1][j][p-1][q],b[i-1][j][p][q-1]),max(b[i][j-1][p-1][q],b[i][j-1][p][q-1]))+a[i][j].num+a[p][q].num;
  if(i==p&&q==j)b[i][j][p][q]-=a[i][j].num;
  }
  }
  }
  }
  cout<<b[n][n][n][n];p1004方格取数*/
/*int i,j,k,l;
  for(i=1;i<=4;i++){
  cin>>a[i];
  }
  for(i=1;i<=4;i++){
  sum=0;
  for(j=1;j<=a[i];j++){
  cin>>b[j];
  sum+=b[j];
  }
  for(k=1;k<=a[i];k++){
  for(l=sum/2;l>=b[k];l--){
  c[l]=max(c[l],c[l-b[k]]+b[k]);
  }
  }
  m+=(sum-c[sum/2]);
  memset(c,0,sizeof(c));
  }
  cout<<m;P2392 kkksc03考前临时抱佛脚*/
/*cin>>n;
  for(int i=1;i<=n;i++){
  cin>>b[i];
  c[i]=c[i-1]+b[i];
  }
  if(c[n]<0){
  cout<<"Impossible";
  return 0;
  }
  for(int i=1;i<=n;i++){
  if(c[i]<0){
  i++;
  }
  for(int j=0;j<=i-1;j++){
  if(c[i]-c[j]>=0){
  a[i]=max(a[j]+1,a[i]);
  
  }
  }
  }
  cout<<a[n];P1569 Generic Cow Protests*/
/*int h,t,hx,tx,k,hj,tj;
  cin>>h>>t;
  cin>>n;
  for(int i=1;i<=n;i++){
  cin>>hx>>tx>>k;
  hj=h;
  while(hj>=hx){
  tj=t;
  while(tj>=tx){
  
  a[hj][tj]=max(a[hj-hx][tj-tx]+k,a[hj][tj]);
  tj--;
  }
  hj--;
  
  }
  
  }
  cout<<a[h][t];P1507NASA的食物计划*/
/*cin>>m;
  for(int i=1;i<m;i++){
  for(int j=i+1;j<=m;j++){
  cin>>a[i][j];
  }
  b[i]=1e9;
  }
  for(int i=m-1;i>=1;i--){
  for(int j=i+1;j<=m;j++){
  b[i]=min(b[i],b[j]+a[i][j]);
  }		
  }
  cout<<b[1];P1359租用游艇*/
/*cin>>n>>m;
  a[0][1]=1;
  for(ll i=1;i<=10000;i++){
  for(ll j=1;j<=101;j++){
  a[i][j]=a[i-1][j-1]+a[i-1][j];
  a[i][j]%=10007;
  }
  }
  for(ll i=0;i<m;i++){
  cin>>b[i];
  sum*=a[n][b[i]+1];
  sum%=10007;
  n-=b[i];
  }
  if(n<0){
  cout<<"0";
  return 0;
  }
  cout<<sum;P1358扑克牌*/
/*int n,m;
  cin>>n>>m;
  for(int i=0;i<=m;i++){
  a[0][i]=i+1;
  for(int j=1;j<=n;j++){
  a[j][i]=a[j-1][i]+a[j-1][i];
  } 
  }
  cout<<a[n][m];P1244青蛙过河*/
/*string a;
  int n,i,j,ir,il,sl,rl;
  cin>>n;
  cin>>a;
  a=' '+a+a+a;
  for(int i=n+1;i<=2*n;i++){
  il=i-1;
  ir=i;
  b[i]=2;
  for(j=i-2;j>=1;j--){
  if(a[il]=='w'){
  il--;
  b[i]++;
  }
  else if(a[j]==a[il]||a[j]=='w'){
  b[i]++;
  }
  else break;
  }
  for(j=i+1;j<=3*n;j++){
  if(a[ir]=='w'){
  ir++;
  b[i]++;
  }
  else if(a[j]==a[ir]||a[j]=='w'){
  b[i]++;
  }
  else break;
  }
  }
  sort(b+n+1,b+n+1+n);
  if(b[2*n]>n){
  cout<<n;
  }
  else cout<<b[2*n];P1203坏掉的项链*/
/*int n,m;
  cin>>n>>m;
  c[0]=1;
  for(int i=0;i<n;i++){
  cin>>b[i];
  for(int j=m;j>=b[i];j--){
  c[j]=c[j]+c[j-b[i]];
  }
  }
  cout<<c[m];P1164 小A点菜*/
/*ll n,m,minx=1e7;
  cin>>n>>m;
  for(int i=0;i<m;i++){
  for(int j=0;j<n;j++){
  cin>>a[i][j];
  }
  }
  for(int i=1;i<n;i++){
  for(int j=0;j<m;j++){
  if(!j){
  a[j][i]=min(a[m-1][i-1],a[j][i-1])+a[j][i];
  }
  else a[j][i]=min(a[j-1][i-1],a[j][i-1])+a[j][i];
  }
  }
  for(int i=0;i<m;i++){
  minx=min(minx,a[i][n-1]);
  }
  cout<<minx;P1130 红牌*/
/*int n;
  cin>>n;
  a[0]=1;
  for(int i=1;i<=n;i++){
  for(int j=0;j<i;j++){
  a[i]=a[i]+a[j];
  }
  }
  cout<<a[n]<<endl;青蛙跳台阶*/
/*int n,m;
  cin>>n>>m;
  for(int i=0;i<m;i++){
  cin>>a[i]>>b[i];
  for(int j=n;j>=a[i];j--){
  if(c[j]<c[j-a[i]]+a[i]*b[i]){
  c[j]=c[j-a[i]]+a[i]*b[i];
  }
  }
  }
  cout<<c[n];P1060开心的金明*/

/*int n;
  cin>>n;
  a[1][1]=1;
  for(int i=2;i<=n+1;i++){
  for(int j=1;j<=i;j++){
  a[i][j]=a[i-1][j]+a[i][j-1];
  }
  }
  cout<<a[n+1][n+1];p1044栈*/
/*int n,m,a,b;
  cin>>n>>m>>a>>b;
  n+=2;m+=2;a+=2;b+=2;
  int x[9]={1,2,2,1,-1,-2,-2,-1,0};
  int y[9]={2,1,-1,-2,2,-1,1,-2,0};
  t t[9];
  f[2][1]=1;
  for(int i=0;i<9;i++){
  s[a+x[i]][b+y[i]]=1;
  }
  for(int i=2;i<=n;i++){
  for(int j=2;j<=m;j++){
  if(s[i][j]){
  continue;
  }
  f[i][j]=f[i-1][j]+f[i][j-1];
  }
  }
  cout<<f[n][m];过河卒p1002*/
/*int V,n;
  cin>>V;
  cin>>n;
  int a[n],l=0,k;
  for(int i=0;i<n;i++){
  cin>>a[i];
  }
  sort(a,a+n);
  for(int i=0;i<n;i++){
  if(a[i]<=V){
  b[l]=a[i];
  k=l;
  for(int j=0;j<k;j++){
  if((b[l-1]<(b[j]+a[i]))and((b[j]+a[i])<=V)){
  l++;
  b[l]=b[j]+a[i];
  }
  }
  l++;
  }
  }
  sort(b,b+l);
  cout<<V-b[l-1];装箱p1049（非dp解*/
/*int r;
  cin>>r;
  for(int i=1;i<=r;i++){
  for(int j=1;j<=i;j++){
  cin>>a[i][j];
  }
  }
  for(int i=r-1;i>0;i--){
  for(int j=1;j<=i;j++){
  if(a[i+1][j]>a[i+1][j+1]){
  a[i][j]=a[i][j]+a[i+1][j];
  }
  else a[i][j]=a[i][j]+a[i+1][j+1];
  }
  }
  cout<<a[1][1];数字金字塔p1216*/
/*ll n,sum=-1e4,b=0;
  cin>>n;
  for(ll i=1;i<=n;i++){
  cin>>a[i];
  if(b<0){
  b=a[i];
  }
  else{
  b+=a[i];
  }
  if(sum<b){
  sum=b;
  }
  }
  cout<<sum; 最大子段和p1115*/
/*int t,m;
  cin>>t>>m;
  for(int i=0;i<m;i++){
  cin>>a[i]>>c[i];
  for(int j=t;j>=a[i];j--){
  if(b[j]<b[j-a[i]]+c[i]){
  b[j]=b[j-a[i]]+c[i];
  }
  }
  }
  sort(b,b+t);
  cout<<b[t];采药p1048(装箱p1049dp同理*/
/*ll T,m;
  cin>>T>>m;
  for(int i=0;i<m;i++) 
  {
  cin>>a[i]>>b[i];
  }
  for(int i=0;i<m;i++)
  {
  for(int j=a[i];j<=T;j++)
  {
  c[j]=max(c[j],c[j-a[i]]+b[i]);
  }
  }
  cout<<c[T];疯狂的采药p1616(dp*/
/*ll T,m,minx=1e5,n=0,sum=0;
  cin>>T>>m;
  for(int i=0;i<m;i++){
  cin>>a[i].x>>a[i].y;
  a[i].z=a[i].y/a[i].x;
  a[i].k=T/a[i].x;
  minx=min(a[i].x,minx);
  }
  sort(a,a+m,cmp);
  while(T>=minx&&n<m){
  if(T>=a[n].x){
  T=T-a[n].x;
  sum+=a[n].y;
  }
  else{ n++;}
  }
  cout<<sum;疯狂的采药p1616(非dp*/
