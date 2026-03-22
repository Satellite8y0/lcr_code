#include<bits/stdc++.h>
using namespace std;
#define ll long long
#define ull unsigned long long
const ll N=1e9+7;
struct t{
	ll z;
	ll x;
	ll y;
};
ll phi[500500],prime[500500];
bool st[500500];
void oula(ll n){
	ll cnt=0;
	phi[1]=1;
	for(int i=2;i<=n;i++){
		if(!st[i]){
			prime[cnt++]=i;
			phi[i]=i-1;
		}
		for(int j=0;i*prime[j]<=n;j++){
			st[prime[j]*i]=1;
			if(i%prime[j]==0){
				phi[prime[j]*i]=prime[j]*phi[i];
				break;
			}
			else phi[prime[j]*i]=(prime[j]-1)*phi[i];
		}
	}
}
ll minx=1e18,maxx=-1e18,mod=10007;
ll cnt=0;
ll fa[1005000],in[1005000];
template <typename T>
inline void read(T &x)//快读
{
	char c;
	x = 0;
	int fu = 1;
	c = getchar();
	while(c > 57 || c < 48)
	{
		if(c == 45)
		{
			fu = -1;
		}
		c = getchar();
	}
	while(c <= 57 && c >= 48)
	{
		x = (x << 3) + (x << 1) + c - 48;
		c = getchar();
	}
	x *= fu;
}
ll qpow(ll a,ll b){
	ll res=1;
	while(b){
		if(b&1) res=res*a%mod;
		b>>=1;
		a=a*a%mod;
	}
	return res;
}//快速幂
void pal(ll n){
	fa[0]=1;
	in[0]=1;
	for(ll i=1;i<=n;i++){
		fa[i]=fa[i-1]*i%mod;//i的阶乘
		in[i]=qpow(fa[i],mod-2)%mod;//i的阶乘的逆元
	}
}//预处理fa为阶乘in为阶乘逆元
bool cmp(t a,t b){
	return a.z<b.z;
}
ll gcd(ll a,ll b){
	if(b==0){
		return a;
	}
	return gcd(b,a%b);
}
ll exgcd(ll a,ll b,ll &x,ll &y){
	//拓展欧几里得，res为gcd
	if(b==0){
		x=1,y=0;
		return a;
	}
	else {
		ll x1,y1,res;
		res=exgcd(b,a%b,x1,y1);
		x=y1;
		y=x1-a/b*y1;
		return res;
	}
}
ll lcm(ll a,ll b){
	return a*b/gcd(a,b);
}
ll A(ll a,ll b){
	ll res=1;
	for(ll i=a;i>a-b;i--){
		res*=i;
	}
	return res;
}
ll C(ll a,ll b){
	ll res=1;
	for(int i=a;i>a-b;i--){
		res*=i;
	}
	for(int i=1;i<=b;i++){
		res/=i;
	}
	return res;
}
ll n,m,k;
ll ans,sum,z,x,y,p,q,l,r;
ll a[500][500];
ll c[500][500];
ll b[500]={1,-1,0,0};
ll d[500]={0,0,-1,1};
map<ll,ll>maps;
queue<t>que;
bool panding(string s){
	ll l=0,r=s.length()-1;
	while(l<=r){
		if(s[l]==s[r]){
			l++;
			r--;
		}
		else return false;
	}
	return true;
}
void solve(){
}
int main()
{
	int input=1;
	//cin>>input;
	while(input--){
		solve();
	}
	return 0;
}
/*
  //dp[i][j]在用最多j天到达i城市的最小疲劳值。
  cin >> n >> m ;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  }
  for(int i=1;i<=m;i++){
  cin>>b[i];
  }
  for(int i=1;i<=n;i++){
  dp[i][0]=1e12;//给第0天一个超级大的初值不然都是0了。
  }
  for(int i=1;i<=n;i++){
  for(int j=1;j<=m;j++){
  //第j天在第i个城市，要么是在昨天也在这个城市休息了一天，要么是昨天出发从上一个城市过来。
  dp[i][j]=min(a[i]*b[j]+dp[i-1][j-1],dp[i][j-1]);
  }
  }
  cout<<dp[n][m]<<endl;//输出最多m天到达n城市的最小疲劳值
  return 0;
 */
/*
  cin>>s;
  ll ans=0;
  ll cnt=0;//记录最终左括号一共有多少个
  ll x=0;//记录当前括号状态，左括号数-右括号数，模拟栈的状态
  for(ll i=0;i<s.length();i++){
  if(s[i]=='('){
  x++;//入栈
  cnt++;
  }
  else x--;//出栈
  if(x<0){ //栈空时有右括号
  x=1; //把该右括号转换成左括号
  cnt++;//左括号数量加一
  ans++;//变换了1次
  }
  }
  ans+=cnt-s.length()/2;//最后我们匹配好的左括号和右括号应该相等多出来的左括号全部变换成右括号
  cout<<ans<<endl;
  return 0;

 */
/*
  cin>>n;
  ll ans=0;
  for(ll i=1;i<=n;i++){
  cin>>m;
  while(!st.empty()&&m>=st.top()){
  st.pop();//栈里的牛比这头牛矮的都退出，因为它们都不能看到后面的牛了
  }
  ans+=st.size();//该牛可以被剩下那些比自己高的牛都看到
  st.push(m);
  }
  cout<<ans<<endl;
  return 0;

 */
/*
  #include<bits/stdc++.h>
  using namespace std;
  #define ll long long
  string s;
  int main()
  {
  cin>>s;
  s=' '+s;
  ll jl=0;//记录当前计算的数据
  ll ans1=0,ans2=0;//记录两种短路
  bool skip=false;//判断是否跳过(短路)
  for(ll i=1;i<s.length();i++){
  if(skip){
  //cout<<"0 "<<i<<endl;
  if(s[i]=='('){//跳过括号
  ll cnt=1;//记录当前需要匹配的左括号
  while(cnt){//当所有括号被匹配就停止循环
  i++;
  if(s[i]=='('){
  cnt++;
  }
  if(s[i]==')'){
  cnt--;//没匹配一个右括号需要匹配的左括号就少1
  }
  }
  }
  else if(s[i]==')'){//说明我们跳过的式子本身就在括号中，遇到右括号应该终止跳过
  skip=false;
  }
  else if(s[i]=='|'){
  if(jl==0){//jl=0进入skip说明是0&，当遇到|时值由后面的数据决定,要退出skip去更新jl
  skip=false;
  }
  else ans2++;//另一种情况是1|，又遇到|再跳过一次
  }
  else if(s[i]=='&'){//与上面同理
  if(jl==1){
  //skip=false;因为&的优先级比|高，1|也会把&跳过
  }
  else ans1++;
  }
  }
  else {
  //cout<<"1 "<<i<<endl;
  //记录数据,跳过后值由当前值决定如0|n的情况值是由n决定的，直接赋值就行
  if(s[i]=='1'){
  jl=1;
  }
  if(s[i]=='0'){
  jl=0;
  }
  //只有两种情况会改变jl的值0|1和1&0,以下两种情况jl是不会变的，会变的情况就退出skip更新jl
  if(s[i]=='&'&&jl==0){
  skip=true;//这种情况要跳过后面的表达式
  ans1++;
  }
  if(s[i]=='|'&&jl==1){
  skip=true;//同上
  ans2++;
  }
  }
  //cout<<jl<<endl;
  }
  cout<<jl<<endl;
  cout<<ans1<<" "<<ans2<<endl;
  return 0;
  }

 */
/*
  dp[0][1]=1;//dp[i][j]的含义是传第i次时，刚好传到第j个人的方案数。
  cin>>n>>m;
  //外层循环一定是次数，因为只有把前一次的所有情况都跑完，才能更新这一次的数据
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
 */
/*
  typedef long long ll;
  cin>>n>>k;
  b[0]=0;//前缀和初值赋0
  for(int i=1;i<=n;i++){
  cin>>a[i];
  b[i]=b[i-1]+a[i];//上一个值加上新加入的数，组成前缀和
  }
  //只能操作k次，但是k次用到了k+1个水壶
  //题目说了操作只能选x加到x+1,那么只需要找连续k+1个水壶的和的最大值就行
  ll maxx=0;// 定义最大值，初值赋比数据范围小就行
  for(int i=k+1;i<=n;i++){
  //b[i]-b[i-k]就是以i为结尾的连续k+1个水壶的和
  maxx=max(b[i]-b[i-k-1],maxx);//记录每k+1个水壶的和的最大值
  }
  cout<<maxx<<endl;
  return 0;

 */
/*
  typedef long long ll;
  cin>>n>>k;
  b[0]=0;//前缀和初值赋0
  for(int i=1;i<=n;i++){
  cin>>a[i];
  }
  ll maxx=0,sum=0;//sum存储滑动窗口内的水壶的和
  //先统计第一组数据
  for(int i=1;i<=k+1;i++){
  sum+=a[i];
  }
  maxx=sum;
  for(int i=2;i+k<=n;i++){
  sum+=-a[i-1]+a[i+k];//删去当前水壶中的第一个，加入下一个水壶
  maxx=max(maxx,sum);
  }
  cout<<maxx<<endl;
  return 0;

 */
/*
  //n个挑剔的客人需要n个空房间来隔开
  //如果房间不够，每少一个房间会+2愤怒值，因为有两个相邻了
  cin>>n>>m;
  if(2*n>m){//不够2n个房间
  cout<<2*(2*n-m)<<endl;
  }
  else cout<<0<<endl;//房间足够
  return 0;

 */
/*
  //假设右k*n+m个糖果，n个小朋友每人拿k个糖果多出来的m个(m<n)就是我的
  //我最多能拿到n-1个糖果
  //只有在L~R之间存在m%n=n-1时才能拿n-1个
  cin>>n>>L>>R;
  //可以把m看作是n的周期循环数每个周期由0~n-1组成
  //0 1 2 3……n-2 n-1 0 1 2 3……n-2 n-1 …………
  if(R/n==L/n){//当R和L在n的同一个周期内时谁大就是谁，即R%n
  cout<<R%n<<endl;
  }
  else cout<<n-1<<endl;//LR不在一个周期内肯定存在m%n=n-1
  return 0;

 */
/*
  ll count(string s,char ch){//统计符号ch在s中出现的次数
  ll cnt=0;
  for(ll i=0;i<s.length();i++){
  if(s[i]==ch){
  cnt++;
  }
  }
  return cnt;
  }
  bool check(string s){//检查：是否在.后面
  ll cnt=0;
  for(ll i=0;i<s.length();i++){
  if(cnt<3&&s[i]==':'){
  return false;
  }
  if(s[i]=='.'){
  cnt++;
  }
  
  }
  return true ;
  }
  int main()
  {
  cin>>n;
  for(int i=0;i<n;i++){
  cin>>s>>ss;
  if(count(ss,'.')!=3){//检查.数量
  cout<<"ERR"<<endl;
  continue;
  }
  if(count(ss,':')!=1){//检查：数量
  cout<<"ERR"<<endl;
  continue;
  }
  if(!check(ss)){//检查符号顺序
  cout<<"ERR"<<endl;
  continue;
  }
  ll sum=0,cnt=0,jl=1;//cnt统计字符，jl记录是否是错误
  ss=' '+ss+' ';
  for(ll j=1;j<ss.length();j++){
  //如果连续两个非数字符号如1.1.1.：2
  if((ss[j]<'0'||ss[j]>'9')&&(ss[j-1]<'0'||ss[j-1]>'9')){
  cout<<"ERR"<<endl;
  jl=0;
  break;
  }
  if(ss[j]>='0'&&ss[j]<='9'){
  //如果有前导0
  if(ss[j-1]=='0'&&sum==0){
  cout<<"ERR"<<endl;
  jl=0;
  break;
  }
  sum=sum*10+(ss[j]-'0');
  //防止爆longlong也是判定大小
  if(sum>65535){
  cout<<"ERR"<<endl;
  jl=0;
  break;
  }
  }
  else {
  //超过5个字符直接错误
  if(cnt>4){
  cout<<"ERR"<<endl;
  jl=0;
  break;
  }
  if(cnt==4){
  if(sum>65535||sum<0){
  cout<<"ERR"<<endl;
  jl=0;
  break;
  }
  }
  else if(sum>255||sum<0){
  cout<<"ERR"<<endl;
  jl=0;
  break;
  
  }
  sum=0;
  cnt++;
  }
  }
  //判错误
  if(jl==0){
  continue;
  }
  //如果字符数不是5就是错误(我在ss最后加了“ ”所以是5)
  if(cnt!=5){
  cout<<"ERR"<<endl;
  jl=0;
  continue;
  }
  if(s==s1){
  //如果地址没被用过就可以连接
  if(maps[ss]==0){
  cout<<"OK"<<endl;
  maps[ss]=i+1;
  }
  else {
  cout<<"FAIL"<<endl;
  }
  }
  if(s==s2){
  //如果这个地址有机器就可以连接
  if(maps[ss]){
  cout<<maps[ss]<<endl;
  }
  else {
  cout<<"FAIL"<<endl;
  }
  }
  }
  return 0;
  }

 */
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
/*
  bool panding(string s){
  ll l=0,r=s.length()-1;
  while(l<=r){
  if(s[l]==s[r]){
  l++;
  r--;
  }
  else return false;
  }
  return true;
  }
  void solve(){
  string s1,s;
  cin>>n>>s1;
  ll pos=0;
  ll cnt=0;
  s=s1;
  if(n==16){
  while(!panding(s)||cnt==0){
  s1=s;
  pos=0;
  cnt++;
  ll tmp=s1.length();
  for(int i=s1.length()-1;i>=0;i--){
  if(s1[i]>='0'&&s1[i]<='9'){
  if(s1[tmp-i-1]>='0'&&s1[tmp-i-1]<='9'){
  p=int(s1[i]-48)+int(s1[tmp-i-1]-48)+pos;
  }
  else p=int(s1[i]-48)+int(s1[tmp-i-1]-65)+pos;
  }
  else{
  if(s1[tmp-i-1]>='0'&&s1[tmp-i-1]<='9'){
  p=20+int(s1[i]-65)+int(s1[tmp-i-1]-48)+pos;
  }
  else p=20+int(s1[i]-65)+int(s1[tmp-i-1]-65)+pos;
  }
  if(p/n){
  pos=1;
  }
  else pos=0;
  p%=n;
  if(p>=0&&p<=9){
  s[i]=p+48;
  }
  else s[i]=p+55;
  }
  if(pos==1){
  s="1"+s;
  }
  if(cnt>30){
  cout<<"Impossible!"<<endl;
  return ;
  }
  }
  cout<<"STEP="<<cnt<<endl;
  return ;
  }
  while(!panding(s)){
  s1=s;
  pos=0;
  cnt++;
  ll tmp=s1.length();
  for(int i=s1.length()-1;i>=0;i--){
  p=int(s1[i]-48)+int(s1[tmp-i-1]-48)+pos;
  if(p/n){
  pos=1;
  }
  else pos=0;
  p%=n;
  s[i]=p+48;
  
  }
  if(pos==1){
  s="1"+s;
  }
  if(cnt>30){
  cout<<"Impossible!"<<endl;
  return ;
  }
  
  }
  cout<<"STEP="<<cnt<<endl;
  
  }
 */
/*
  bool panding(string s){
  ll l=0,r=s.length()-1;
  while(l<=r){
  if(s[l]==s[r]){
  l++;
  r--;
  }
  else return false;
  }
  return true;
  }
  string s1,s;
  cin>>n>>s1;
  ll pos=0;
  ll cnt=0;
  s=s1;
  if(n==16){
  while(!panding(s)||cnt==0){
  s1=s;
  pos=0;
  cnt++;
  ll tmp=s1.length();
  for(int i=s1.length()-1;i>=0;i--){
  if(s1[i]>='0'&&s1[i]<='9'){
  p=int(s1[i]-48)+int(s1[tmp-i-1]-48)+pos;
  }
  else{
  p=20+int(s1[i]-65)+int(s1[tmp-i-1]-65)+pos;
  }
  if(p/n){
  pos=1;
  }
  else pos=0;
  p%=n;
  if(p>=0&&p<=9){
  s[i]=p+48;
  }
  else s[i]=p+55;
  }
  if(pos==1){
  s="1"+s;
  }
  if(cnt>30){
  cout<<"Impossible!"<<endl;
  return ;
  }
  }
  cout<<"STEP="<<cnt<<endl;
  return ;
  }
  while(!panding(s)){
  s1=s;
  pos=0;
  cnt++;
  ll tmp=s1.length();
  for(int i=s1.length()-1;i>=0;i--){
  p=int(s1[i]-48)+int(s1[tmp-i-1]-48)+pos;
  if(p/n){
  pos=1;
  }
  else pos=0;
  p%=n;
  s[i]=p+48;
  
  }
  if(pos==1){
  s="1"+s;
  }
  if(cnt>30){
  cout<<"Impossible!"<<endl;
  return ;
  }
  }
  cout<<"STEP="<<cnt<<endl;
  
 */
/*
  void bfs(){
  t pos;
  cnt=0;
  pos.x=0;
  pos.y=0;
  que.push(pos);
  while(!que.empty()){
  ll xx=que.front().x;
  ll yy=que.front().y;
  ll x1=xx,y1=yy;
  if(c[xx][yy]==5000){
  cout<<xx+yy<<endl;
  return;
  }
  que.pop();
  for(int i=0;i<4;i++){
  xx=x1+b[i];
  yy=y1+d[i];
  if(a[xx][yy]==0&&c[xx][yy]>(xx+yy)&&xx>=0&&xx<=300&&yy>=0&&yy<=300){
  t tmp;
  tmp.x=xx;
  tmp.y=yy;
  a[xx][yy]=1;
  que.push(tmp);
  }
  }
  }
  cout<<-1<<endl;
  }
  void solve(){
  cin>>n;
  for(int i=0;i<310;i++){
  for(int j=0;j<310;j++){
  c[i][j]=5000;
  }
  }
  for(int i=1;i<=n;i++){
  cin>>x>>y>>z;
  c[x][y]=min(c[x][y],z);
  c[x-1][y]=min(c[x][y],z);
  c[x+1][y]=min(c[x][y],z);
  c[x][y-1]=min(c[x][y],z);
  c[x][y+1]=min(c[x][y],z);
  }
  bfs();
  }
 */
/*
  void bfs(t pos){
  que.push(pos);
  while(!que.empty()){
  ll xx,yy;
  xx=que.front().x;
  yy=que.front().y;
  que.pop();
  ll x1,y1;
  for(int i=0;i<=7;i++){
  x1=xx+c[i];
  y1=yy+b[i];
  if((x1>0&&x1<=n&&y1>0&&y1<=m)&&a[x1][y1]==-1){
  t tmp;
  tmp.x=x1;
  tmp.y=y1;
  que.push(tmp);
  a[x1][y1]=a[xx][yy]+1;
  }
  }
  }
  }
 */
/*
  void bfs(ll x1,ll y1){
  que.push(x1);
  while(!que.empty()){
  ll xx=que.front();
  que.pop();
  if(xx==y1){
  return ;
  }
  ll xx1=xx;
  for(int i=0;i<=1;i++){
  if(i==1){
  xx=xx1-a[xx1];
  }
  else{
  xx=xx1+a[xx1];
  }
  if(xx>=1&&xx<=n&&c[xx]==-1){
  c[xx]=c[xx1]+1;
  que.push(xx);
  }
  }
  };
  
  }
 */
/*
  void bfs(ll hs,ll cs){
  while(!que.empty()){
  que.pop();
  }
  memset(a,0,sizeof(a));
  que.push(hs);
  a[hs]=0;
  while(!que.empty()){
  ll x=que.front();
  if(x==cs){
  cout<<a[x]<<endl;
  return;
  }
  ll y=x;
  que.pop();
  for(int i=0;i<=2;i++){
  if(i==0){
  x=y-1;
  }
  if(i==1){
  x=y+1;
  }
  if(i==2){
  x=y*2;
  }
  if(x>=0&&x<=100000){
  if(a[x]==0&&x!=hs){
  que.push(x);
  a[x]=a[y]+1;
  }
  }
  }
  }
  }
 */
/*
  cin>>n;
  for(int i=1;i<=n;i++){//遍历每一位
  for(int j=1;j<=i/2;j++){//每一位有多少数字
  a[i]+=a[j];
  }
  a[i]++;
  }
  cout<<a[n]<<endl;
 */
/*
  q=0;
  cin>>n>>m>>p;
  if(n%2){
  q++;
  }
  if(m%2){
  q++;
  }
  if(p%2){
  q++;
  }
  if(q%2){
  cout<<-1<<endl;
  }
  else {
  ll res=max(n,max(m,p));
  ll ans=min(n+m+p-res,(n+m+p)/2);
  cout<<ans<<endl;
  }
 */
/*
  string s;
  cin>>s;
  ll ans=0;
  n=-1;
  if(s[0]=='1'){
  ans++;
  n=0;
  }
  for(ll i=0;i<s.length()-1;i++){
  n=i+1;
  if(s[i]=='0'&&s[i+1]=='1'){
  ans++;	
  break;
  }
  }
  if(n==s.length()-1){
  cout<<ans<<endl;
  return ;
  }
  for(ll i=n;i<=s.length();i++){
  if(s[i]=='0'){
  ans++;
  }
  }
  cout<<ans<<endl;
 */
/*
  cin>>n;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  }
  for(int i=1;i<=n;i++){
  if(a[i]==0){
  if(i%2==0){
  cout<<"YES"<<endl;
  return;
  }
  break;
  }
  }
  for(int i=n;i>=1;i--){
  if(a[i]==0){
  if((n-i+1)%2==0){
  cout<<"YES"<<endl;
  return;
  }
  break;
  }
  }
  cout<<"NO"<<endl;
 */
/*
  cin>>n;
  for(int i=1;i<n;i++){
  for(int j=i+1;j<=n;j++){
  cin>>a[i][j];
  a[j][i]=a[i][j];
  }
  }
  ans=0;
  for(int i=1;i<=n;i++){
  for(int j=1;j<=n;j++){
  b[j]=a[i][j];
  }
  sort(b+1,b+1+n,cmp);
  ans=max(ans,b[2]);
  }
  cout<<1<<endl;
  cout<<ans<<endl;
 */
/*
  cin>>n;
  ans=0;
  for(int i=1;i<=n;i++){
  cin>>x;
  ans^=x;
  }
  if(ans){
  cout<<"Yes"<<endl;
  }
  else cout<<"No"<<endl;
  
  
 */
/*
  cin>>n;
  ans=0;
  while(n!=1){
  p=1,q=1;
  for(int i=2;i*i<=n;i++){
  if(n%i==0){
  p*=i;
  n/=i;
  while(n%i==0){
  n/=i;
  q*=i;
  }
  }
  }
  p*=n;
  n=q;
  ans+=p;
  }
  cout<<ans<<endl;
  
 */
/*
  cin>>n;
  phi[1]=1;
  for(int i=2;i<=n;i++){
  if(!st[i]){
  prime[cnt++]=i;
  phi[i]=i-1;
  }
  for(int j=0;prime[j]<=n/i;j++){
  st[prime[j]*i]=1;
  if(i%prime[j]==0){
  phi[prime[j]*i]=prime[j]*phi[i];
  break;
  }
  else phi[prime[j]*i]=(prime[j]-1)*phi[i];
  }
  }
  p=cnt;
  cnt--;
  for(int i=2;i<=n;i++){
  while(i*prime[cnt]>n){
  cnt--;
  }
  ans+=phi[i]*(cnt+1);
  }
  ans*=2;
  ans+=p;
  cout<<ans<<endl;
 */
/*
  for(int i=2;i<=1000001;i++){
  if(!st[i]){
  prime[cnt++]=i;
  }
  for(int j=0;prime[j]<=1000001/i;j++){
  st[prime[j]*i]=1;
  if(i%prime[j]==0){
  break;
  }
  }
  }
  while(cin>>l>>r){
  memset(st,1,sizeof st);
  if(l==1){
  st[0]=0;
  }
  for(int i=0;i<cnt;i++){
  for(int j=l/prime[i];prime[i]*j<=r;j++){
  if(j>1&&prime[i]*j>=l){
  st[prime[i]*j-l]=0;
  }
  }
  }
  ll l1,l2,r1,r2,mn=1e18,mx=0;
  p=0;
  for(int i=l;i<=r;i++){
  if(st[i-l]==0){
  continue;
  }
  if(p){
  ll res=i-p;
  if(res>mx){
  mx=res;
  l1=p;
  r1=i;
  }
  if(res<mn){
  mn=res;
  l2=p;
  r2=i;
  }
  }
  p=i;
  }
  if(mx==0){
  cout<<"here are no adjacent primes."<<endl;
  }
  else printf("%lld,%lld are closest, %lld,%lld are most distant.\n",l2,r2,l1,r1);
  }
 */
/*
  cin>>n;
  
  ans=0;
  phi[1]=1;
  for(int i=2;i<=n;i++){
  if(!st[i]){
  prime[cnt++]=i;
  phi[i]=i-1;
  }
  for(int j=0;prime[j]<=n/i;j++){
  st[prime[j]*i]=1;
  if(i%prime[j]==0){
  phi[prime[j]*i]=prime[j]*phi[i];
  break;
  }
  else phi[prime[j]*i]=(prime[j]-1)*phi[i];
  }
  }
  for(int i=1;i<=n-1;i++){
  ans+=phi[i];
  }
  ans*=2;
  if(n>=2){
  ans+=1;
  }
  cout<<ans<<endl;
 */
/*
  void dfs(ll x,ll y,ll p,ll q)//x为当前数，y为第y个质数，p为约数个数，q为指数和
  {
  if(p>maxx||(p==maxx&&x<minx)){
  maxx=p,minx=x;
  }
  ll ans=x;
  for(int i=1;i<=q;i++){
  if(ans*prime[y]>n){
  return ;
  }
  ll res=p*(i+1);
  ans*=prime[y];
  if(ans<=n){
  dfs(ans,y+1,res,i);
  }
  }
  }
  cin>>n;
  for(int i=2;i<=100;i++){
  if(!st[i]){
  prime[cnt++]=i;
  }
  for(int j=0;prime[j]<=100/i;j++){
  st[prime[j]*i]=1;
  if(i%prime[j]==0){
  break;
  }
  }
  }
  dfs(1,0,1,30);
  cout<<minx<<endl;
 */
/*
  map<ll,ll>a;
  cin>>n>>m;
  p=log2(m);
  q=1;
  cnt=0;
  for(int i=1;i<=p;i++){
  a[cnt++]=q;
  q*=2;
  }
  if(m-q>0){
  a[cnt++]=m-q;
  }
  for(int i=1;(m*i+1)<=n&&i<=3;i++){
  a[cnt++]=m*i+1;
  q=m*i+1;
  }
  if(q<n){
  for(int i=q;i*2<=n;i*=2){
  a[cnt++]=i*2;
  }
  }
  cout<<cnt<<endl;
  for(int i=0;i<cnt;i++){
  cout<<a[i]<<" ";
  }
  cout<<endl;
 */
/*
  cin>>n>>m;
  ans=A(n+2,n+2)*A(n+3,m)-2*A(n+1,n+1)*A(n+2,m);
  cout<<ans;
 */
/*
  cin>>n;
  for(int i=2;i<=n+1;i++){
  if(!st[i]){
  prime[cnt++]=i;
  }
  for(int j=0;prime[j]<=(n+1)/i;j++){
  st[i*prime[j]]=1;
  if(i%prime[j]==0){
  break;
  }
  }
  }
  if(n<3){
  cout<<1<<endl;
  }
  else cout<<2<<endl;
  for(int i=2;i<=n+1;i++)
  {
  cout<<st[i]+1<<" ";
  }
 */
/*
  ll type;
  cin>>type>>n>>m>>mod;
  x=m-1;//m个花m-1个隔板
  y=n-x;//x个隔板还剩n-x个位置
  ans=1;
  for(int i=y;i>y-m;i--){
  ans=ans*i%mod;
  }
  cout<<ans<<endl;
 */
/*
  cin>>n>>m>>p;
  ll res=gcd(n,m);
  p=-p;
  if(p%res!=0){
  cout<<-1<<endl;
  return ;
  }
  exgcd(n,m,x,y);
  x=x*p/res;
  y=y*p/res;
  cout<<x<<" "<<y;
 */
/*
  read(n);//a
  read(m);//b
  read(p);//c
  ll res=gcd(n,m);
  ll x1,y1,x0,y0,dx,dy,xx,yy;
  exgcd(n,m,x0,y0);
  if(p%res!=0){
  cout<<-1<<endl;
  return ;
  }
  x1=x0*p/res;
  y1=y0*p/res;
  dx=m/res;
  dy=n/res;
  q=ceil((-x1+1.0)/dx);
  x=x1+dx*q;
  y=y1-dy*q;
  if(y<=0){
  y=y+dy*1ll*ceil((-y+1.0)/dy);
  cout<<x<<" "<<y<<endl;
  }
  else {
  ans=(y-1)/dy+1;
  yy=y;
  xx=x+(y-1)/dy*dx;
  y=(y-1)%dy+1;
  cout<<ans<<" "<<x<<" "<<y<<" "<<xx<<" "<<yy<<endl;;
  }
 */
/*
  cin>>x>>y>>n>>m>>l;
  p=m-n;
  q=x-y;
  if(p<0){
  q=-q;
  p=-p;
  }
  ll res=exgcd(p,l,x,y);
  if(q%res!=0){
  cout<<"Impossible";
  }
  else cout<<((x*(q/res))%(l/res)+(l/res))%(l/res);
 */
/*
  cin>>n;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  }
  ans=abs(a[1]);
  for(int i=2;i<=n;i++){
  ans=__gcd(ans,abs(a[i]));
  }
  cout<<ans;
  
 */
/*
  cin>>n>>m;
  for(int i=1;i<n;i++){
  if(gcd(n,i)==1){
  a[cnt++]=i;
  }
  }
  ans=(m-1)/(cnt)*n+a[(m-1)%(cnt)];
  cout<<ans;
 */
/*
  cin>>n>>m;
  for(int i=2;i<=sqrt(n);i++){
  if(n%i==0){
  cnt++;
  c[cnt].x=i;
  while(n%i==0){
  n/=i;
  c[cnt].y++;
  }
  }
  }
  if(n!=1){
  p=n;
  cnt++;
  c[cnt].x=n;
  while(n%p==0){
  n/=p;
  c[cnt].y++;
  }
  }
  ans=1;
  for(int i=1;i<=cnt;i++){
  
  q=c[i].y*m+1;
  if(c[i].x%mod==1){
  ans=ans*q%mod;
  continue;
  }//特判逆元不存在
  ans=((ans%mod)*(qpow(c[i].x,q)%mod-1)*qpow(c[i].x-1,mod-2)%mod)%mod;
  }
  cout<<(ans+mod)%mod;
 */
/*
  cin>>n;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  
  }
  for(int i=1;i<=n;i++){
  if(i==2){
  continue;
  }
  a[2]=a[2]/gcd(a[i],a[2]);
  if(a[2]==1){
  break;
  }
  }
  if(a[2]==1){
  cout<<"Yes"<<endl;
  }
  else cout<<"No"<<endl;
 */
/*cin>>n;
  m=n;
  ans=0;
  for(int i=n/(n/m+1);i>=1;){
  ans+=(n/m)*(m-i);
  m=i;
  i=n/(n/i+1);
  }
  ans+=n;
  cout<<ans<<endl;*/
/*
  void xxs(ll o){
  for(int i=2;i<=o;i++){
  if(!st[i]){
  prime[cnt++]=i;
  }
  for(int j=0;prime[j]<=o/i;j++){
  st[i*prime[j]]=1;
  if(i%prime[j]==0){
  break;
  }
  }
  }
  }
  cin>>l>>r;
  q=sqrt(r);
  xxs(q);
  for(ll i=l;i<=r;i++){
  a[i-l]=i;
  b[i-l]=i;
  }
  for(int i=0;i<cnt&&prime[i]*prime[i]<=r;i++){
  p=prime[i];
  for(int j=(p-l%p)%p;j<=r-l;j+=p){
  b[j]=b[j]/p*(p-1);
  while(a[j]%p==0){
  a[j]/=p;
  }
  }
  }
  ans=0;
  for(int i=0;i<=r-l;i++){
  if(a[i]!=1){
  b[i]=b[i]/a[i]*(a[i]-1);
  }
  ans=1ll*(ans+i+l-b[i])%mod;
  }
  cout<<ans;
 */
/**
  
  void xxs(){
  for(int i=2;i<=1000000;i++){
  if(!st[i]){
  prime[cnt++]=i;
  }
  for(int j=0;prime[j]<=1000000/i;j++){
  st[prime[j]*i]=1;
  if(i%prime[j]==0){
  break;
  }
  }
  }
  }
  ll ph(ll o){
  ll cntc=0,ans1=0;
  for(ll i=0;prime[i]<sqrt(o);i++){
  c[i].x=prime[i];
  c[i].y=o/c[i].x;
  for(ll j=0;j<cntc;j++){
  //cout<<2<<endl;
  c[i].y-=(c[i].y/c[j].x-c[i].x/c88888888888[j].x);
  }
  cntc++;
  //cout<<1<<endl;
  if(o%prime[i]!=0){
  ans1+=c[i].y;
  }
  }
  return ans1;
  }
  cin>>l>>r;
  xxs();
  //cout<<"xxs"<<endl;
  for(ll i=l;i<=r;i++){
  a[i-l]=i;
  }
  for(int i=0;i<=r-l;i++){
  ans+=(a[i]-ph(a[i]));
  cout<<a[i]<<" "<<ph(a[i])<<endl;
  }
  cout<<ans<<endl;
  
  
 错的*/
/*
  void dfs(ll o,ll s){//o>=s
  
  if(o==s){
  ans+=4*s;
  return ;
  }
  else {
  ans+=(s*4)*(o/s);
  if(o%s==0){
  return ;
  }
  dfs(max(s,o%s),min(s,o%s));
  }
  }
 */
/*
  void ys(ll op){//分解因数，并记录
  for(int i=1;i<=sqrt(op);i++){
  if(op%i!=0){
  continue;
  }
  else {
  c[i].x++;
  c[op/i].x++;
  }
  if(i*i==op){
  c[i].x--;
  }
  }
  }
  cin>>n;
  for(int i=0;i<=1000000;i++){
  c[i].y=i;
  }
  for(int i=1;i<=n;i++){
  cin>>a[i];
  ys(a[i]);
  }
  sort(c,c+1000001,cmp);
  ll cnt=0;
  for(int i=0;i<=1000000;i++){
  if(c[i].x==0){
  break;
  }
  cnt=i;
  }
  for(int i=1;i<=n;i++){
  for(int j=0;j<=cnt;j++){
  if(c[j].x>=i){
  dp[i]=c[j].y;
  break;
  }
  }
  }
  for(int i=1;i<=n;i++){
  cout<<dp[i]<<endl;
  }
 */
/*
  for(int i=2;i<=30000;i++){
  if(!st[i]){
  prime[cnt++]=i;
  }
  for(int j=0;prime[j]<=30000/i;j++){
  st[i*prime[j]]=1;
  if(i%prime[j]==0){
  break;
  }
  }
  }
  cin>>n;
  cin>>p>>q;
  cnt=0;
  ll cntc=0;
  while(p!=1){
  if(p%prime[cnt]==0){
  p/=prime[cnt];
  if(a[prime[cnt]]==0){
  c[cntc++]=prime[cnt];
  }
  a[prime[cnt]]++;
  }
  else {
  cnt++;
  }
  }//a存质因数数量，c存质因数
  for(int i=0;i<cntc;i++){
  a[c[i]]*=q;
  //cout<<c[i]<<" "<<a[c[i]]<<endl;
  }
  for(int i=1;i<=n;i++){
  cin>>m;
  //cout<<i<<endl;
  ll cntd=0,res=0,temp=0;
  while(cntd<cntc){
  res=0;
  if(m%c[cntd]==0){
  while(m%c[cntd]==0){
  res++;
  m/=c[cntd];
  }
  //cout<<c[cntd]<<" "<<res<<endl;
  temp=max(temp,(a[c[cntd]]+res-1)/res);
  //cout<<temp<<endl;
  cntd++;
  }
  else {
  d[i]=-1;//d存第i种细胞的最少时间
  break;
  }
  d[i]=temp;
  }
  }
  l=0;
  ans=1e9;
  for(int i=1;i<=n;i++){
  //cout<<d[i]<<" ";
  if(d[i]==-1){
  continue;
  }
  ans=min(d[i],ans);
  l=1;
  }
  //cout<<endl;
  if(l){
  cout<<ans<<endl;
  }
  else cout<<-1<<endl;
 */
/*
  ll a1,a0,b1,b0;
  ans=0;
  cin>>a0>>a1>>b0>>b1;
  for(int i=1;i<=sqrt(b1);i++){
  if(b1%i){
  continue;
  }
  //cout<<i<<" "<<gcd(b1/b0,b1/i)<<" "<<gcd(i/a1,a0/a1)<<endl;
  if((i%a1)==0){
  if(gcd(b1/b0,b1/i)==1&&gcd(i/a1,a0/a1)==1){
  ans++;
  }
  }
  //cout<<b1/i<<" "<<gcd(b1/b0,i)<<" "<<gcd((b1/i)/a1,a0/a1)<<endl;
  if((b1/i)%a1==0){
  if(gcd(b1/b0,i)==1&&gcd((b1/i)/a1,a0/a1)==1){
  ans++;
  }
  }
  if(i*i==b1){
  ans--;
  }
  }
  cout<<ans<<endl;
 */
/*
  cin>>n;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  c[a[i]]++;
  }
  for(int i=1;i<=1000000;i++){
  if(!c[i]){
  continue;
  }
  for(int j=1;j<=1000000/i;j++){
  if(c[i*j]){
  dp[i*j]+=c[i];
  }
  else continue;
  }
  }
  for(int i=1;i<=n;i++){
  cout<<dp[a[i]]-1<<endl;
  }
 */
/*
  cin>>n>>m>>p;
  b[0][0]=1;
  for(int i=1;i<=50;i++){
  for(int j=0;j<=i;j++){
  if(j==0){
  b[i][j]=1;
  }
  else {
  b[i][j]=b[i-1][j]+b[i-1][j-1];
  }
  }
  }
  for(ull i=0;i<=m;i++){
  for(ull j=0;j<=p;j++){
  ans+=b[n+i-1][n-1]*b[n+j-1][n-1];
  }
  }
  cout<<ans;
 */
/*
  read(n);
  read(mod);
  read(m);
  fa[0]=1;
  in[0]=1;
  b[0]=1;
  c[n+1]=1;
  for(register int i=1;i<=n;i++){
  read(a[i]);
  fa[i]=fa[i-1]*a[i]%mod;//前缀和
  }
  in[n+1]=qpow(fa[n],mod-2);
  for(register int i=n;i>=1;i--){
  in[i]=in[i+1]*a[i]%mod;
  }
  p=m;
  for(register int i=1;i<=n;i++){
  ans=(ans+p%mod*fa[i-1]%mod*in[i+1]%mod)%mod;
  p=p*m%mod;
  }
  printf("%lld",ans);
  return 0;
 */
/*
  void dfs(ll p,ll q){
  if(q==0){
  if(c[p]==0){
  ans++;
  c[p]=1;
  }
  }
  else{
  for(ll i=1;i<=q;i++){
  dfs(i*(q-i)+m,q-i);
  }
  }	
  }
 */
/*
  组合数学C(a,b)=lucas(a,b)
  ll qpow(ll a,ll b){
  ll res=1;
  while(b){
  if(b&1) res=res*a%mod;
  b>>=1;
  a=a*a%mod;
  }
  return res;
  }
  ll C(ll a,ll b){
  ll res=1;
  for(int i=1,j=a;i<=b;i++,j--){
  res=(ll)res*j%mod;
  res=(ll)res*qpow(i,mod-2)%mod;
  }
  return res;
  }
  ll lucas(ll a,ll b){
  if(a<mod&&b<mod) return C(a,b);
  return (ll)C(a%mod,b%mod)*lucas(a/mod,b/mod)%mod;
  }
  
 */
/*
  void Exgcd(ll a, ll b, ll &x, ll &y) {
  if (!b) x = 1, y = 0;
  else Exgcd(b, a % b, y, x), y -= a / b * x;
  }//拓展欧几里得
 */
/*
  cin>>n>>m;
  a[1]=1;
  c[1]=1;
  for(int i=2;i<=n;i++){
  a[i]=(a[i-1]+c[i-1])%mod;
  if(i>m+1){
  c[i]=(c[i-m-1]+a[i-m-1])%mod;
  }
  else c[i]=1;
  }
  cout<<(a[n]+c[n])%mod;
 */
/*
  cin>>n;
  a[0]=1;
  for(int i=1;i<=n;i++){
  for(int j=n;j>=i;j--){
  a[j]+=a[j-i];
  }
  }
  cout<<a[n]-1;
 */
/*
  cin>>n;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  minx=min(minx,a[i]);
  }
  ans=1;
  for(int i=1;i<=n;i++){
  ans=(ans*(a[i]/minx))%mod;
  }
  cout<<minx<<" "<<ans;
 */
/*
  for(int i=2;i<=n;i++){
  if(b[i]==0){
  a[ans++]=i;
  }
  for(int j=0;a[j]*i<=n;j++){
  b[a[j]*i]=1;
  if(i%a[j]==0){
  break;
  }
  }	
  }
  cout<<ans<<endl;线性筛
 */
/*deque<ll>que;
  cin>>n>>m;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  }
  
  for(int i=1;i<=n;i++){
  if(!que.empty()&&(i-que.front())>=m){
  que.pop_front();
  }
  while(!que.empty()&&a[que.back()]>a[i]){
  que.pop_back();
  }
  que.push_back(i);
  if(i>=(m)){
  cout<<a[que.front()]<<" ";
  }
  } 
  cout<<endl;
  que.clear();
  for(int i=1;i<=n;i++){
  if(!que.empty()&&(i-que.front())>=m){	
  que.pop_front();
  }
  while(!que.empty()&&a[que.back()]<a[i]){
  que.pop_back();
  }
  que.push_back(i);
  if(i>=(m)){
  cout<<a[que.front()]<<" ";
  }
  }*/
/*cin>>n>>m>>k>>d;
  vector<ll> b(n+10);
  for(int i=0;i<n;i++){
  vector<ll> a(m);
  for(int j=0;j<m;j++){
  cin>>a[j];
  a[j]++;
  }
  deque<ll>que;
  vector<ll> c(m,1E18);
  c[0]=1;
  for(int j=1;j<m;j++){
  while(!que.empty()&&c[que.back()]>c[j-1]){
  que.pop_back();
  }
  que.push_back(j-1);
  while((j-que.front()-1)>d){
  que.pop_front();
  }
  c[j]=a[j]+c[que.front()];
  } 
  b[i]=c[m-1];
  }
  ll ans=1E18;
  for(int i=0;(i+k)<=n;i++){
  ll sum=0;
  for(int j=0;j<k;j++){
  sum+=b[i+j];
  }
  ans=min(ans,sum);
  }
  cout<<ans<<endl;*/
/*cin>>n>>m;
  a[0][1]=1;
  for(int i=1;i<=m;i++){
  cin>>x;
  x%=n;
  for(int j=1;j<=n;j++){
  a[i][j]=a[i-1][(j+x-1)%n+1]|a[i-1][((j-x-1)%n+n)%n+1];
  }
  }
  if(a[m][1]==1){
  cout<<"YES"<<endl;
  return ;
  }
  cout<<"NO"<<endl;*/
/*cin>>n;
  ll cnt=0;
  for(int i=1;i<=n;i++){
  cin>>a[i].x>>a[i].y;
  if((a[i].y-1)<0&&b[a[i].x-1][60-(1-a[i].y)]==0){
  b[a[i].x-1][60-(1-a[i].y)]++;
  cnt++;
  }
  else if(b[a[i].x][a[i].y-1]==0){
  b[a[i].x][a[i].y-1]++;
  cnt++;
  }
  if((a[i].y-3)<0&&b[a[i].x-1][60-(3-a[i].y)]==0){
  b[a[i].x-1][60-(3-a[i].y)]++;
  cnt++;
  }
  else if(b[a[i].x][a[i].y-3]==0){
  b[a[i].x][a[i].y-3]++;
  cnt++;
  }
  if((a[i].y-5)<0&&b[a[i].x-1][60-(5-a[i].y)]==0){
  b[a[i].x-1][60-(5-a[i].y)]++;
  cnt++;
  }
  else if(b[a[i].x][a[i].y-5]==0){
  b[a[i].x][a[i].y-5]++;
  cnt++;
  }
  }
  cout<<cnt<<endl;
  for(int i=0;i<=23;i++){
  for(int j=0;j<=59;j++){
  if(b[i][j]){
  cout<<i<<" "<<j<<endl;
  }
  }
  }*/
/*map<char,ll>maps;
  for(int i=1;i<=5;i++){
  string s;
  getline(cin,s);
  for(int j=0;j<10;j++){
  maps[s[j]]++;
  }
  }
  x=maps['1']+maps['0'];
  if(x==3){
  if(maps['1']>1){
  cout<<1<<endl;
  }
  else cout<<0<<endl;
  }
  else if(maps['&']){
  if(maps['1']==2){
  cout<<1<<endl;
  }
  else {
  cout<<0<<endl;
  }
  }
  else {
  if(maps['0']){
  cout<<1<<endl;
  }
  else cout<<0<<endl;
  }*/
/*ll matchz(ll k){
  while(k){
  maps[k%10]++;
  if(maps[k%10]>1){
  return 0;
  }
  k/=10;
  }	
  return 1;	
  }
  ll matchx(ll k){
  sum=0;
  while(k){
  sum+=(k%10);
  k/=10;
  }
  
  return sum;	
  }
  ll matchy(ll k){
  sum=1;
  while(k){
  sum*=(k%10);
  k/=10;
  }
  return sum;
  }*/
/*ll k[4];
  cin>>k[1]>>k[2]>>k[3];
  
  ll l=1;
  ans=1;
  while(1<=l&&l<=1000/k[3]){
  maps.clear();
  z=matchz(l*1000*k[1]+l*1000000*k[2]+l*k[3]);
  x=matchx(l*1000*k[1]+l*1000000*k[2]+l*k[3]);
  y=matchy(l*1000*k[1]+l*1000000*k[2]+l*k[3]);
  if(z==1&&x==45&&y==362880){
  ans=0;
  cout<<l*k[1]<<" "<<l*k[2]<<" "<<l*k[3]<<endl;
  }
  l++;
  }
  if(ans){
  cout<<"No!!!"<<endl;
  }*/
/*cin>>n>>m;
  x=n-m;
  while(x<=n){
  cout<<x<<" ";
  x++;
  }
  x=n-m-1;
  while(x){
  cout<<x<<" ";
  x--;
  }
  cout<<endl;*/
/*cin>>n;
  string s;
  cin>>s;
  s=' '+s;
  map<char,ll>maps;
  ll cnt=0;
  for(int i=1;i<=n;i++){
  if(maps[s[i]]==0){
  a[cnt++]=i;
  }
  maps[s[i]]++;
  }
  ans=0;
  for(int i=0;i<cnt;i++){
  x=s[a[i]]-'A'+1;
  if(x<=maps[s[a[i]]]){
  //cout<<s[a[i]]<<" "<<maps[s[a[i]]]<<endl;
  ans++;
  }
  }
  cout<<ans<<endl;*/
/*cin>>n>>m>>sum;
  ans=1;
  y=m;
  x=n;
  while(m){
  if(m&1){
  ans=ans*n%sum;
  }
  n=n*n%sum;
  m=m>>1;
  }
  cout<<x<<"^"<<y<<"mod"<<sum<<"="<<ans<<endl;*/
/*ll n,m,sum=0,summ;
  map<ll,ll>maps;
  cin>>n>>m;
  summ=n;
  sum=(m+2)*(m+1)/2;
  for(int i=1;i<=n;i++)  {
  cin>>a[i];
  summ=summ+a[i]/2+m-a[i]-maps[a[i]%2];
  maps[a[i]%2]++;
  }
  cout<<sum-summ<<endl;*/
/*cin>>n;
  for(int i=1;i<=n;i++){
  string s;
  cin>>s;
  x=s.length();
  sum=0;
  l=0;
  for(int i=1;i<x;i++){
  if((s[i-1]>='A'&&s[i-1]<='Z')&&(s[i]>='0'&&s[i]<='9')){
  if(l==0){
  r=i;
  l=1;
  }
  else {
  y=i;
  }
  sum++;
  }
  
  }
  if(sum==2){
  m=0;
  for(int i=y;i<x;i++){
  m=m*10+int(s[i]-'0');
  }
  ll cnt=0;
  string b;
  while(m!=0){
  ll a=m%26;
  m=m/26;
  if(a==0){
  b[cnt++]='Z';
  m--;
  }
  else {
  b[cnt++]=('A'-1+a);
  }
  
  }
  for(int i=cnt-1;i>=0;i--){
  cout<<b[i];
  }
  for(int i=r;i<y-1;i++){
  cout<<s[i];
  }
  cout<<endl;
  }
  else {
  cout<<'R';
  for(int i=r;i<x;i++){
  cout<<s[i];
  }
  cout<<'C';
  ll a=0;
  for(int i=0;i<r;i++){
  a=a*26+(s[i]-'A'+1);
  }
  cout<<a;
  cout<<endl;
  }
  }*/
/*cin>>n>>m>>ans;
  x=(n+ans-1)/ans;
  y=(m+ans-1)/ans;
  cout<<x*y;*/
/*cin>>n>>m;
  for(int i=1;i<=n;i++){
  cin>>x;
  for(int j=1;j<=x;j++){
  cin>>y;
  a[y].push_back(i);
  }
  }
  for(int i=1;i<=m;i++){
  b[a[i]]++;
  ans=ans*b[a[i]]%N;
  }
  cout<<ans;*/
/*cin>>n;
  vector<ll> a(n+1);
  map<ll,ll> b;
  for(int i=0;i<n;i++){
  cin>>a[i];
  }
  for(int i=1;i<n;i++){
  b[abs(a[i]-a[i-1])]++;
  }
  for(int i=1;i<n;i++){
  if(b[i]==0){
  cout<<"Not jolly";
  return 0;
  }
  }
  cout<<"Jolly";*/
/*string s,s1;
  s1="Blbsrua";
  map<char,ll> a;
  cin>>s;
  n=s.length();
  m=s1.length();
  for(int i=0;i<n;i++){
  a[s[i]]++;
  }
  a['a']/=2;
  a['u']/=2;
  ans=1000000000;
  for(int i=0;i<m;i++){
  ans=min(ans,a[s1[i]]);
  }
  cout<<ans;*/
/*cin>>n;
  vector<ll> a(n+1);
  map<ll,ll> b;
  for(int i=0;i<n;i++){
  cin>>a[i];
  for(int j=1;j<=sqrt(a[i]);j++){
  if(a[i]%j==0){
  b[j]++;
  if(j*j!=a[i]){
  b[a[i]/j]++;
  }
  }
  }
  }
  ans=1;
  for(int i=2;i<100000;i++){
  ans=max(b[i],ans);
  }
  cout<<ans;*/
/*double a,b,c,l=0,r=300,mid=0;
  cin>>a>>b>>c;
  while(l<r-0.0001){
  mid=(l+r)/2;
  double x=a;
  for(int i=0;i<c;i++){
  x=x-b+x*(mid/100);
  }
  if(x>0.0001){
  r=mid;
  }
  else l=mid;
  }
  double ans=round(l*10)/10;
  printf("%.1lf",ans);*/
/*double a,b,c,d;
  cin>>a>>b>>c>>d;
  for(double i=-100;i<=100;i+=0.01){
  if(abs(i*i*i*a+i*i*b+i*c+d)<0.005){
  printf("%.2lf ",i);
  }
  }*/
/*cin>>n;
  int i,j;
  for(i=1;i<=n/2;i++){
  ans=0;
  for(j=i;j<n;j++){
  ans+=j;
  if(ans>=n){
  break;
  }
  }
  if(ans==n){
  cout<<i<<" "<<j<<endl;
  }
  }*/
/*cin>>n>>m;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  }
  sort(a+1,a+n+1);
  for(int i=1;i<=m;i++){
  cin>>b[i];
  }
  if(m<n){
  cout<<"you died!";
  return 0;
  }
  for(int i=1;i<=n;i++){
  maxx=0;
  maxy=0;
  for(int j=1;j<=m;j++){
  if(b[j]>=a[i]&&c[j]==0){
  if(maxx==0){
  maxx=b[j];
  }
  else if(b[j]<maxx){
  maxx=b[j];
  maxy=j;
  }
  }
  }
  if(maxx==0){
  cout<<"you died!";
  return 0;
  }
  c[maxy]=1;
  ans+=maxx;
  }
  if(ans!=0){
  cout<<ans;
  }
  else cout<<"you died!";*/
/*cin>>n;
  for(int i=1;i<=500;i++){
  a[i]=a[i-1]+i;
  }
  for(int i=1;i<=n;i++){
  cin>>x;
  ans=0;
  for(int i=1;i<=x;i++){
  ans+=a[x+1-i];
  }
  for(int i=1;i<=x/2;i++){
  ans+=a[x+1-2*i];
  }
  cout<<ans<<endl;
  }*/
/*while(cin>>a[x++]);
  for(int i=0;i<x;i++){
  ans+=a[i];
  }
  ans*=pow(2,x-2);
  cout<<ans;*/
/*cin>>n;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  }
  string s;
  cin>>s;
  sort(a+1,a+n+1);
  for(int i=1;i<=n;i++){
  if(!a[i].find(s)){
  cout<<a[i]<<endl;
  }
  }*/
/*cin>>n;
  for(int i=1;i<=n;i++){
  cin>>a[i].name>>a[i].x>>a[i].y>>a[i].w;
  a[i].i=i;
  }
  sort(a+1,a+n+1,cmp);
  for(int i=1;i<=n;i++){
  cout<<a[i].name<<endl;
  }*/
/*string a,b,c;
  cin>>a>>b;
  n=b.length();
  m=a.length();
  for(int i=0;i<n;i++){
  x=i%m;
  y=(int(a[x])&31)-1;
  if((int(b[i])&31)-y>0){
  b[i]=char(b[i]-y);
  }
  else b[i]=char(b[i]-y+26);
  }
  for(int i=0;i<n;i++){
  cout<<b[i];
  }*/
/*cin>>n;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  maxx+=a[i];
  }
  w=maxx/n;
  for(int i=1;i<=n;i++){
  x=a[i]-w;
  if(x!=0){
  a[i+1]+=x;
  ans++;
  }
  }
  cout<<ans;*/
/*char ch,s[100000];
  cin>>ch;
  ll i=0;
  while(ch!='E'){
  if(ch=='W'||ch=='L'){
  s[i++]=ch;
  }
  cin>>ch;
  
  }
  for(int j=0;j<i;j++){
  if(s[j]=='W'){
  a++;
  }
  if(s[j]=='L'){
  b++;
  }
  if((a>=11||b>=11)&&(abs(a-b)>=2)){
  cout<<a<<":"<<b<<endl;
  a=0;
  b=0;
  }
  }
  cout<<a<<":"<<b<<endl;
  cout<<endl;
  for(int j=0;j<i;j++){
  if(s[j]=='W'){
  x++;
  }
  if(s[j]=='L'){
  y++;
  }
  if((x>=21||y>=21)&&(abs(x-y)>=2)){
  cout<<x<<":"<<y<<endl;
  x=0;
  y=0;
  }
  }
  cout<<x<<":"<<y<<endl;*/
/*cin>>x>>y;
  n=sqrt(y);
  m=2;
  w=max(m,n);
  if(x==1){
  x++;
  }
  for(int i=2;i<=w;i++){
  a=y/i;
  for(int j=a;j>=2;j--){
  b=j*i;
  if(b<x){
  break;
  }
  else c[b-x]=1;
  }
  }
  for(ll i=x;i<=y;i++){
  if(c[i-x]==0){
  ans++;
  }
  }
  cout<<ans;*/
/*cin>>n>>m;
  for(int i=1;i<=m;i++){
  cin>>b[i];
  }
  for(int i=1;i<n;i++){
  cin>>a[i].x>>a[i].y>>a[i].w;
  }
  for(int i=2;i<=m;i++){
  x=min(b[i],b[i-1]);
  y=max(b[i],b[i-1]);
  c[x]++;c[y]--;
  //cout<<c[x]<<" "<<c[y]<<endl;
  }
  for(int i=1;i<=n;i++){
  dp[i]=c[i]+dp[i-1];
  //cout<<dp[i]<<" ";
  }
  //cout<<endl;
  for(int i=1;i<=n;i++){
  x=a[i].x*dp[i];
  y=a[i].y*dp[i]+a[i].w;
  //cout<<i<<" "<<x<<" "<<y<<endl;
  ans+=min(x,y);
  }
  cout<<ans<<endl;*/
/*for(int i=2;i<=m;i++){
  x=min(b[i],b[i-1]);
  y=max(b[i],b[i-1]);
  for(int j=x;j<y;j++){
  city[j].y++;
  city[j].x=j;
  }
  }
  sort(city+1,city+m+1,cmp);
  for(int i=1;i<=m;i++){
  x=a[city[i].x].x*city[i].y;
  y=a[city[i].x].y*city[i].y+a[city[i].x].w;
  ans+=min(x,y);
  }
  cout<<ans<<endl;*/
/*cin>>n>>m>>w;
  for(int i=1;i<=n;i++){
  for(int j=1;j<=m;j++){
  cin>>a[i][j];
  }
  }
  for(int i=n;i>=1;i--){
  for(int j=m;j>=1;j--){
  b[i][j]=b[i][j+1]+a[i][j];
  dp[i][j]=b[i][j]+dp[i+1][j];
  }
  }
  ans=-10000000;
  for(int x1=1;x1<=n;x1++){
  for(int y1=1;y1<=n;y1++){
  y=dp[x1][y1]-dp[x1+w][y1]-dp[x1][y1+w]+dp[x1+w][y1+w];
  if(y>ans){
  ans=y;
  maxx=x1;
  maxy=y1;
  }
  }
  }
  cout<<maxx<<" "<<maxy<<endl;*/
/*cin>>n;
  for(int i=1;i<=n;i++){
  cin>>a[i].x>>a[i].y;
  }
  sort(a+1,a+n+1,cmp);
  ans+=a[1].y-a[1].x;
  maxx=a[1].y;
  for(int i=2;i<=n;i++){
  
  if(a[i].x<maxx){
  if(a[i].y>maxx){
  ans+=a[i].y-maxx;
  maxx=a[i].y;
  }
  }
  else {
  ans+=a[i].y-a[i].x;
  maxx=a[i].y;
  }
  }
  cout<<ans<<endl;*/
/*ans=0;
  l=1;//特判最后一次删除
  r=0;
  cin>>n;
  mp2.clear();
  mp1.clear();
  for(int i=1;i<=n;i++){
  cin>>a[i];
  if(mp1[a[i]]==0){
  r++;//记录有多少种颜色
  mp1[a[i]]=i;//记录每种颜色的第一个位置
  }
  }
  x=r;
  y=a[n];
  n--;
  temp=1;
  mp2[y]=1;
  while(n>0){
  if(mp1[a[n]]==n){
  x--;//记录这个颜色已经删完
  }
  if(a[n]!=y){
  if(mp2[a[n]]==0){
  temp++;//标记遇到的颜色
  mp2[a[n]]=1;
  }
  if(temp==r){
  ans++;
  r=x;//剩下的颜色
  temp=1;
  mp2.clear();//重置标记
  n--;
  mp2[a[n]]=1;
  }
  y=a[n];
  l=1;
  }
  else l++;
  n--;
  if(n==0){
  ans+=l;
  }
  }
  if(ans==0){
  ans++;
  }
  cout<<ans<<endl;*/
/*ans=100000;
  cin>>n>>m;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  b[i]=a[i]-a[i-1];
  }
  for(int i=1;i<=m;i++){
  cin>>x>>y>>w;
  b[x]+=w;
  b[y+1]-=w;
  }
  for(int i=1;i<=n;i++){
  a[i]=a[i-1]+b[i];
  ans=min(ans,a[i]);
  }
  cout<<ans;*/
/*cin>>n;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  }
  mergesort(1,n);
  cout<<ans;*/
/*void merge(ll l,ll r){
  ll mid=(l+r)/2;
  ll i=l,j=mid+1;
  ll k=1;
  while(i<=mid&&j<=r){
  if(a[i]>a[j]){
  ans+=mid-i+1;
  b[k++]=a[j];
  j++;
  }
  else{
  b[k++]=a[i];
  i++;
  }
  }
  if(i<=mid){
  for(int ix=i;ix<=mid;ix++){
  b[k++]=a[ix];
  }
  }
  if(j<=r){
  for(int ix=j;ix<=r;ix++){
  b[k++]=a[ix];
  
  }
  }
  for(int ix=l;ix<=r;ix++){
  a[ix]=b[k-(r-ix)-1];
  }
  }
  void mergesort(ll l,ll r){
  if(l>=r){
  return;
  }
  int mid=(l+r)/2;
  mergesort(l,mid);
  mergesort(mid+1,r);
  merge(l,r);
  }归并排序(计算逆序对)*/

/*void pushup(ll k){
  c[k]=c[k*2]+c[k*2+1];
  }
  void build(ll k,ll l,ll r){
  if(l==r){
  c[k]=a[l];
  return ;
  }
  ll mid=(l+r)/2;
  build(k*2,l,mid);
  build(k*2+1,mid+1,r);
  pushup(k);
  }
  void add(ll k,ll l,ll r,ll p){
  b[k]+=p;
  c[k]+=p*(r-l+1);
  }
  void pushdown(ll k,ll l,ll r){
  ll mid=(l+r)/2;
  add(k*2,l,mid,b[k]);
  add(k*2+1,mid+1,r,b[k]);
  b[k]=0;
  }
  void update(ll x,ll y,ll l,ll r,ll k,ll p){
  if(x<=l&&r<=y){
  c[k]+=p*(r-l+1);
  b[k]+=p;
  return ;
  }
  pushdown(k,l,r);
  ll mid=(l+r)/2;
  if(x<=mid){
  update(x,y,l,mid,k*2,p);
  }
  if(y>mid){
  update(x,y,mid+1,r,k*2+1,p);
  }
  pushup(k);//更新完子节点，维护父节点
  }
  ll solve(ll x,ll y,ll l,ll r,ll k){
  ll anss=0;
  if(x<=l&&r<=y){
  return c[k];
  }
  pushdown(k,l,r);
  ll mid=(l+r)/2;
  if(x<=mid){
  anss+=solve(x,y,l,mid,k*2);
  }
  if(y>mid){
  anss+=solve(x,y,mid+1,r,k*2+1);
  }
  return anss;
  }
  int main()
  {
  cin>>n>>m;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  }
  build(1,1,n);
  for(int i=1;i<=m;i++){
  cin>>ac;
  if(ac==1){
  ll x,y,k;
  cin>>x>>y>>k;
  update(x,y,1,n,1,k);
  }
  if(ac==2){
  ll x,y;
  cin>>x>>y;
  ans=solve(x,y,1,n,1);
  cout<<ans<<endl;
  }
  }kouno线段树da*/


/*cin>>n;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  }
  for(int i=2;i<=n;i++){
  if(a[i]>a[i-1]){
  ans+=a[i]-a[i-1];
  }
  }
  ans+=a[1];
  cout<<ans;*/
/*cin>>n;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  }
  solve(1,n);
  cout<<ans;*/
/*void solve(ll l,ll r){
  //cout<<l<<" "<<r<<endl;
  if(l<r){
  ll mini,minx=20000;
  for(int i=l;i<=r;i++){
  if(a[i]<minx){
  minx=a[i];
  mini=i;
  }
  }
  //cout<<mini<<endl;
  ans+=a[mini];
  //cout<<a[mini]<<endl;
  for(int i=l;i<=r;i++){
  a[i]-=minx;
  //cout<<a[i]<<" ";
  }
  //cout<<endl;
  solve(l,mini-1);
  solve(mini+1,r);
  }
  else if(l==r){
  ans+=a[l];
  //cout<<a[l]<<endl;
  }
  
  }*/
/*cin>>n>>m;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  if(i==1){
  sum=a[i];
  }
  else{
  if((sum+a[i])>m){
  ll b=sum+a[i]-m;
  if(b>=a[i]){
  ans+=b;
  a[i]=0;
  sum=a[i];
  }
  else{
  ans+=b;
  a[i]-=b;
  sum=a[i];
  }
  }
  else sum=a[i];
  }
  }
  cout<<ans<<endl;*/
/*cin>>m;
  cin>>n;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  }
  sort(a+1,a+n+1);
  for(l=1,r=n;l<r;r--){
  if((a[l]+a[r])<=m){
  l++;
  ans++;
  }
  else {
  ans++;
  }
  }
  if(l==r){
  ans++;
  }
  cout<<ans;*/
/*cin>>n>>m;
  ans=pow1(n,m)-n*pow1(n-1,m-1)%100003;
  ans+=100003;
  ans=ans%100003;
  cout<<ans;*/
/*ll pow1(ll a,ll b){
  ll c=1;
  while(b){
  if(b&1){
  c=c*a%100003;	
  }
  a=a*a%100003;
  b>>=1;
  }
  return c;
  }*/
/*cin>>n>>m;//m为盒子shu;
  if(n==0||n<m){
  cout<<0;
  return 0;
  }
  a[1][1]=1;//1个球1个盒子只有一种情况;
  for(ll i=2;i<=n;i++){
  ll t1=min(i,m);//盒子数小于球数但不超过m;
  for(ll j=1;j<=t1;j++){
  a[i][j]=j*(a[i-1][j]+a[i-1][j-1]);
  }
  }
  cout<<a[n][m];*/
/*void exgcd(ll a,ll b,ll &x,ll &y){
  if(a%b==0){
  x=0,y=1;
  }
  else {
  exgcd(b,a%b,y,x);
  y-=a/b*x;
  }
  }拓展欧几里得*/
/*ll x,y;
  cin>>n>>m;
  exgcd(n,m,x,y);
  ans=(x+m)%m;
  cout<<ans;*/
/*cin>>n>>m;
  for(int i=1;i<=m;i++){
  cin>>x>>y>>l>>r;
  for(int ix=x;ix<=l;ix++){
  for(int iy=y;iy<=r;iy++){
  a[ix][iy]++;
  }
  }
  }
  for(int ix=1;ix<=n;ix++){
  for(int iy=1;iy<=n;iy++){
  cout<<a[ix][iy]<<" ";
  }
  cout<<endl;
  }*/
/*cin>>n;
  for(int i=1;i<=n;i++){
  cin>>x;
  a[i]=a[i-1]+x;
  }
  cin>>m;
  for(int i=1;i<=m;i++){
  cin>>x>>y;
  cout<<a[y]-a[x-1]<<endl;
  }*/
/*cin>>n>>m;
  for(int i=0;i<m;i++){
  cin>>x>>y;
  if(mapsx[x]==0){
  a[l++]=x;
  mapsx[x]++;
  }
  if(mapsy[y]==0){
  b[r++]=y;
  mapsy[y]++;
  }
  }
  for(int i=0;i<l;i++){
  ans+=n;
  }
  for(int i=0;i<r;i++){
  ans+=(n-l);
  }
  cout<<ans;*/
/*void pr(char k){
  if(k!='*'){
  cout<<k;
  pr(tree[(int)k].y);
  pr(tree[(int)k].w);
  }
  }*/
/*char s[4];
  cin>>n;
  for(int i=0;i<n;i++){
  cin>>s;
  if(i==0){
  ans=s[0];
  }
  tree[(int)s[0]].x=s[0];
  tree[(int)s[0]].y=s[1];
  tree[(int)s[0]].w=s[2];
  }
  pr(tree[ans].x);*/
/*void yhsj(){
  a[1][1]=1;
  for(int i=0;i<=2000;i++){
  a[i][0]=1;
  }
  for(int i=2;i<=2000;i++){
  for(int j=1;j<=i;j++){
  a[i][j]=(a[i-1][j]+a[i-1][j-1])%m;
  }
  }
  for(int i=2;i<=2000;i++){
  for(int j=1;j<=i;j++){
  b[i][j]=b[i-1][j]-b[i-1][j-1]+b[i][j-1];
  if(a[i][j]==0){
  b[i][j]++;
  }
  }
  b[i][i+1]=b[i][i];
  }
  }
  int main()
  {	
  memset(a,0,sizeof a);
  memset(b,0,sizeof b);
  cin>>n>>m;
  yhsj();
  while(n--){
  cin>>x>>y;
  if(x<y){
  cout<<b[x][x]<<endl;
  }
  else{
  cout<<b[x][y]<<endl;
  }
  }*/
/*cin>>n>>m;
  if(m%n==0){
  x=m/n;
  y=2;
  ans=1;
  while(x!=1){
  while(x%y!=0){
  y++;
  }
  while(x%y==0){
  x/=y;
  }
  y++;
  ans*=2;
  }
  }
  cout<<ans;*/
/*cin>>n>>m;
  cout<<n*m-n-m<<endl;*/
/*cin>>n;
  for(int i=0;i<n;i++){
  cin>>x>>y;
  if((x+y)%2==0){
  l=((y+x)/2)%9;
  r=(y-x+1)%9;
  }
  else{
  l=(y+x)%9;
  r=((y-x+1)/2)%9;
  }
  ans=l*r%9;
  ans=ans%9;
  cout<<ans<<endl;
  }
 */
/*cin>>n>>m;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  r=max(r,a[i]);
  }
  while(l<=r){
  ll mid=(l+r)/2;
  sum=0;
  for(int i=1;i<=n;i++){
  
  if(a[i]>mid){
  sum=sum+a[i]-mid;
  }
  }
  if(sum<m){
  r=mid-1;
  }
  else l=mid+1;
  }
  cout<<r<<endl;*/
/*void dfs(ll a,ll c){
  if(a==fx&&c==fy){
  ans++;
  return;
  }
  else{
  for(int i=0;i<4;i++){
  if(b[a+dx[i]][c+dy[i]]==1){
  b[a][c]=0;
  dfs(a+dx[i],c+dy[i]);
  b[a][c]=1;
  }
  }
  }
  }
  int main()
  {	
  cin>>n>>m>>t;
  cin>>sx>>sy>>fx>>fy;
  for(int i=1;i<=m;i++){
  for(int j=1;j<=n;j++){
  b[j][i]=1;
  }
  }
  for(int i=0;i<t;i++){
  cin>>x>>y;
  b[x][y]=0;
  }	
  dfs(sx,sy);
  cout<<ans;
  return 0;
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
  cout<<ans;*/

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
  cout<<anss;*/
/*int j=0;
  cin>>n;
  for(int i=1;i<=n;i++){
  cin>>m;
  j=0;
  while(m!=0){
  a[m]++;
  dp[i][j++]=m;
  cin>>m;
  }
  }
  for(int i=1;i<=n;i++){
  if(a[i]==0){
  que.push(i);
  }
  }
  while(!que.empty()){
  ans=que.front();
  que.pop();
  cout<<ans<<" ";
  j=0;
  while(dp[ans][j]){
  a[dp[ans][j]]--;
  if(a[dp[ans][j]]==0){
  que.push(dp[ans][j]);
  }
  j++;
  }
  }拓扑排序*/
/*double ans=0;
  cin>>n;
  for(int i=0;i<n;i++){
  cin>>a[i];
  }
  sort(a,a+n);
  for(int i=1;i<n-1;i++){
  ans+=a[i];
  }
  ans/=n-2;
  printf("%.2lf",ans);*/
/*cin>>n;
  if(n<2){
  cout<<0;
  }
  else {
  for(int i=2;i<=n;i++){
  ans=0;
  if(p+i>n){
  break;
  }
  if(i==2){
  cout<<2<<endl;
  m++;
  continue;
  }
  for(int j=2;j<=sqrt(i);j++){
  if(i%j==0){
  ans=1;
  continue;	
  }
  }
  if(ans==0){
  p+=i;
  cout<<i<<endl;
  m++;
  }
  }
  cout<<m<<endl;
  }*/
/*double ans=0;
  cin>>n>>m;
  for(int i=0;i<n;i++){
  cin>>a[i].x>>a[i].y;
  a[i].w=a[i].y/a[i].x;
  }
  sort(a,a+n,cmp);
  for(int i=0;i<n;i++){
  if(m>=a[i].x){
  ans+=a[i].y;
  m-=a[i].x;
  }
  else{
  ans+=m*a[i].w;;
  break;
  }
  }
  printf("%.2lf",ans);*/
/*void add(ll x,ll y,ll z){
  a[++cnt].y=y;
  a[cnt].w=z;
  a[cnt].x=b[x];
  b[x]=cnt;
  }
  cin>>n>>m>>p;
  for(int i=1;i<=m;i++){
  d[i]=pow(2,31)-1;
  }
  d[p]=0;
  for(int i=1;i<=m;i++){
  ll a,b,c;
  cin>>a>>b>>c;
  add(a,b,c);
  }
  ll pos=p;
  while(c[pos]==0){
  minx=pow(2,31)-1;
  c[pos]=1;
  for(int i=b[pos];i!=0;i=a[i].x){
  if(!c[a[i].y]&&d[a[i].y]>d[pos]+a[i].w){
  d[a[i].y]=d[pos]+a[i].w;
  }
  }
  for(int i=1;i<=n;i++){
  if(d[i]<minx&&c[i]==0){
  minx=d[i];
  pos=i;
  }
  }
  }
  for(int i=1;i<=n;i++){
  cout<<d[i]<<" ";
  }P3371*/
/*cin>>n>>m;
  for(int i=1;i<=m;i++){
  cin>>x>>y;
  b[x].push_back(y);
  }
  dfs(1);
  cout<<endl;
  memset(c,0,sizeof(c));
  bfs();*/
/*void dfs(ll num){
  c[num]=1;
  cout<<num<<" ";
  for(ll i=0;i<b[num].size();i++){
  if(!c[b[num][i]]){
  dfs(b[num][i]);
  }
  }
  
  }
  void bfs(){
  queue<ll>q;
  q.push(1);
  c[1]=1;
  while(!q.empty()){
  ll p=q.front();
  q.pop();
  
  for(ll i=0;i<b[p].size();i++){
  if(!c[b[p][i]]){
  q.push(b[p][i]);
  }
  c[b[p][i]]=1;
  }
  cout<<p<<" ";
  }
  }*/
/*ll father(ll x){
  while(x!=b[x]){
  x=b[x]=b[b[x]];
  }
  return x;
  }并查集*/
/*cin>>n>>m;
  ans+=n;
  for(int i=1;i<=m;i++){
  b[i]=i;
  }
  for(int i=1;i<=m;i++){
  for(int j=1;j<=m;j++){
  a[++cnt1].x=i;
  a[cnt1].y=j;
  cin>>a[cnt1].z;
  }
  }
  for(int i=1;i<=cnt1;i++){
  if(a[i].z==0){
  a[i].z=n;
  }
  }
  sort(a+1,a+1+cnt1,cmp);
  for(int i=1;i<=cnt1;i++){
  if(father(a[i].x)==father(a[i].y)){
  continue;
  }
  ans+=a[i].z;
  b[father(a[i].x)]=father(a[i].y);
  cnt++;
  if(cnt==m-1){
  break;
  }
  }
  if(n*m<ans){
  cout<<n*m<<endl;
  }
  else cout<<ans<<endl;*/
/*cin>>n>>m;
  for(int i=1;i<=n;i++){
  b[i]=i;//初始化并查集
  }
  for(int i=1;i<=m;i++){
  cin>>a[i].x>>a[i].y>>a[i].z;
  }
  sort(a+1,a+1+m,cmp);
  //cout<<endl;
  //for(int i=1;i<=m;i++){
  //	cout<<a[i].x<<" "<<a[i].y<<" "<<a[i].z<<endl;
  //}
  //cout<<endl;
  for(int i=1;i<=m;i++){
  //cout<<father(a[i].x)<<" "<<father(a[i].y)<<endl;
  if(father(a[i].x)==father(a[i].y)){
  continue;
  }
  ans+=a[i].z;
  //cout<<ans<<endl;
  //cout<<endl;
  b[father(a[i].x)]=father(a[i].y);
  cnt++;
  if(cnt==n-1){
  cout<<ans<<endl;
  return 0;
  }
  }
  cout<<"orz"<<endl;最小生成树kruskel*/
/*cin>>n;
  for(ll i=1;i<=n;i++){
  cin>>b[i];
  for(ll j=0;j<=30;j++){
  if((1<<j)&b[i]){
  m=max(m,c[j]+1);
  }
  }
  for(ll j=0;j<=30;j++){
  if((1<<j)&b[i]){
  c[j]=max(c[j],m);
  }
  }
  ans=max(ans,m);
  }
  cout<<ans;*/
/*cin>>n;
  cin>>b[0];
  c[0]=1;
  for(ll i=1;i<n;i++){
  cin>>b[i];
  c[i]=1;
  for(ll j=0;j<i;j++){
  if((b[i]&b[j])!=0){
  c[i]=max(c[i],c[j]+1);
  ans=max(ans,c[i]);
  }
  }
  
  }
  cout<<ans;还是垃圾的n^2*/
/*for(int i=0;i<=6;i++){
  turn[i]=i;
  }
  for(int i=8;i<=9;i++){
  turn[i]=i-1;
  }
  cin>>n;
  for(int i=0;i<n;i++){
  cin>>b[i];
  m=b[i];
  int j=0;
  ans=0;
  while(m){
  ans+=turn[m%10]*pow(9,j++);
  m/=10;
  }
  cout<<ans<<endl;
  }*/

/*ll C(ll j,ll k){
  double ans=1;
  if(k==0){
  return 1;
  }
  for(int i=1;i<=k;i++){
  ans*=j-i+1;
  }
  for(int i=1;i<=k;i++){
  ans/=i;
  }
  return (ll)ans;
  }*/
/*//cout<<C(26,1x3);
  cin>>a;
  for(ll i=1;i<a.length();i++){
  if(a[i]<=a[i-1]||'a'>a[i-1]||a[i-1]>'z'||'a'>a[i]||a[i]>'z'){
  cout<<0;
  return 0;
  }
  }
  for(ll i=1;i<a.length();i++){
  n+=C(26,i);
  cout<<C(26,i)<<endl;
  }
  a=char('a'-1)+a;
  //cout<<a<<endl;
  for(ll i=1;i<a.length();i++){
  for(ll j=0;j<((ll)(a[i]-a[i-1])-1);j++){
  n+=C(26-(ll)(a[i-1]-'a')-2-j,a.length()-1-i);
  cout<<C(26-(ll)(a[i-1]-'a')-2-j,a.length()-1-i)<<endl;
  }
  }
  cout<<n+1;*/
/*int i;
  cin>>n>>m;
  cout<<n<<"=";
  while(n){
  r=n%m;
  if(r<0){
  r-=m;
  n+=m;
  }
  if(r>=10){
  a[++i]=char(r-10+'A');
  }
  else a[++i]=char(r+'0');
  n/=m;
  }
  for(int j=i;j>=1;j--){
  cout<<a[j];
  }
  cout<<"(base"<<m<<")";*/
/*ll ans=1;
  cin>>n;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  }
  sort(a+1,a+n+1);
  for(int i=1;i<=n;i++){
  ans*=(a[i]-i+1);
  ans%=1000000007;
  }
  cout<<ans;*/
/*while(cin>>b[++n]){
  }
  n--;
  a[1]=b[1];
  //cout<<n;
  r=1;
  for(int i=2;i<=n;i++){
  if(b[i]<=a[r]){
  r++;
  a[r]=b[i];
  }
  else *upper_bound(a+1,a+r+1,b[i],greater<int>())=b[i];
  }
  cout<<r<<endl;
  memset(a,0,sizeof a);
  a[1]=b[1];
  r=1;
  for(int i=2;i<=n;i++){
  if(b[i]>a[r]){
  r++;
  a[r]=b[i];
  //cout<<1<<endl;
  }
  else *lower_bound(a+1,a+r+1,b[i])=b[i];
  //for(int j=0;j<=r+1;j++){
  //	cout<<a[j]<<" ";
  //}
  //cout<<endl;
  }
  cout<<r<<endl;牛逼的nlogn*/
/*maxx=1;
  while(cin>>b[++n]){
  }
  for(int i=1;i<=n;i++){
  a[i]=1;
  for(int j=1;j<=i-1;j++){
  if(b[i]<=b[j]){
  //a[i]=max(a[i],a[j]+1);
  if(a[i]<a[j]+1){
  a[i]=a[j]+1;
  c[j]++;
  }
  maxx=max(maxx,a[i]);
  }
  }
  }
  cout<<maxx-1<<endl;
  for(int i=1;i<=n;i++){
  cout<<a[i]<<" ";
  }
  cout<<endl;
  for(int i=1;i<=n-1;i++)
  {
  cout<<c[i]<<" ";
  if(c[i]<=1){
  ans++;
  }
  }
  cout<<ans<<endl;n^2复杂度的飞舞*/
/*cin>>n;
  ans=((n&(0b11111111111111110000000000000000))>>16)|((n&(0b00000000000000001111111111111111))<<16);
  cout<<ans;*/
/*scanf("%lld",&n);
  for(int i=0;i<n;i++){
  scanf("%lld",&m);
  ans=ans^m;
  }
  printf("%lld",ans);*/
/*string a,c;
  cin>>n;
  cin>>a;
  cin>>m;
  for(int i=0;i<a.length();i++){
  ans=ans*n;
  //cout<<int(a[i]-'0')<<endl;
  if(int(a[i]-'0')<=10){
  ans+=int(a[i]-'0');
  }
  else ans=ans+int(a[i]-'A'+10);	
  }
  int i=0;
  do{
  if((ans%m)<=10){
  c=c+char(ans%m+'0');
  i++;
  }
  else {
  c=c+char('A'+ans%m-10);
  i++;
  }
  ans/=m;
  }while(ans);
  for(int j=i-1;j>=0;j--){
  cout<<c[j];
  }*/
/*string a[21];
  cin>>n;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  }
  sort(a+1,a+1+n,cmp);
  for(int i=1;i<=n;i++){
  cout<<a[i];
  }*//*bool cmp(string a,string b)
  {
  ll i=0,j;
  if(a.length()>b.length()){
  m=b.length();
  j=1;
  }
  else {
  m=a.length();
  j=0;
  }
  while(m>i){
  if(a[i]!=b[i]){
  return a>b;
  }
  i++;
  }
  if(j){
  if(a[0]>a[i]){
  return a<b;
  }
  else return b<a;
  }
  else {
  if(b[0]>b[i]){
  return a<b;
  }
  else return a>b;
  }
  
  }P1012拼数*/
/*cin>>n>>m;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  }
  for(int i=1;i<=m;i++){
  next_permutation(a+1,a+1+n);
  }
  for(int i=1;i<=n;i++){
  cout<<a[i]<<' ';
  }P1088 火星人*/
/*cin>>n>>m;
  for(int i=1;i<=n;i++){
  cin>>x;
  if(cnt[x]==0){
  cnt[x]=i;
  }
  }
  for(int i=1;i<=m;i++){
  cin>>x;
  if(cnt[x]){
  cout<<cnt[x]<<" ";
  }
  else cout<<"-1"<<" ";
  }P2249查找*/
/*cin>>n>>m>>x>>y;
  a[2]=1;
  a[3]=2;
  for(int i=4;i<m;i++){
  //a数组计n的数量，b计l的数量
  a[i]=a[i-1]+a[i-2]-1;
  b[i]=b[i-1]+b[i-2]+1;
  }
  l=(x-n*a[m-1])/b[m-1];
  cout<<(n*a[y]+l*b[y]);P1011车站*/
/*cin>>n;
  solve(n);
  void solve(ll k){
  for(int i=14;i>=0;i--)
  {
  if(pow(2,i)<=k){
  if(i==1){
  cout<<"2";
  } 
  else if(i==0) {
  cout<<"2(0)";	
  }
  else{ 
  cout<<"2(";
  solve(i);
  cout<<")";
  }
  k-=pow(2,i); 
  if(k!=0) {
  cout<<"+";
  }
  }
  }
  }P1010 幂次方*/
/*l=123;
  while(123<=l&&l<=333){
  x=matchx(l*1000+l*1000000*2+l*3);
  y=matchy(l*1000+l*1000000*2+l*3);
  if(x==45&&y==362880){
  cout<<l<<" "<<l*2<<" "<<l*3<<endl;
  }
  l++;
  }*/
/*cin>>l>>n;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  minx=max(minx,min(a[i]-0,l+1-a[i]));
  maxx=max(maxx,max(a[i]-0,l+1-a[i]));
  }
  cout<<minx<<" "<<maxx;P1007	独木桥*/
/*cin>>n;
  a[0]=b[0]=1;
  for(int i=2;i<=n;i++){
  for(int j=0;j<100;j++){
  b[j]*=i;
  }
  for(int j=0;j<100;j++){
  if(b[j]>9){
  b[j+1]+=b[j]/10;
  b[j]%=10;
  }
  }
  for(int j=0;j<100;j++){
  a[j]+=b[j];
  if(a[j]>9){
  a[j+1]+=a[j]/10;
  a[j]%=10;
  }
  }
  }
  int i;
  for(i=100;i>=0;i--){
  if(a[i]){
  break;
  }
  }
  for( int j=i;j>=0;j--){
  cout<<a[j];
  }P1009阶乘之和(高精度)*/
/*cin>>n>>x;
  for(ll i=1;i<=n;i++){
  cin>>c[i];
  m[c[i]]++;
  c[i]-=x;
  }
  for(ll i=1;i<=n;i++){
  sum+=m[c[i]];
  }
  cout<<sum;P1102	A-B 数对*/
/*cin>>n;
  cin>>x>>y;
  cin>>a[x][y].num;
  while(a[x][y].num||x||y){
  cin>>x>>y;
  cin>>a[x][y].num;
  }
  b[0][0]=0;
  for(int i=1;i<=n;i++){
  b[i][0]=-1;
  b[0][i]=-1;
  } 
  b[1][1]=a[1][1].num;
  for(int i=2;i<=n;i++){
  b[1][i]=b[1][i-1]+a[1][i].num;
  }
  for(int i=2;i<=n;i++){
  b[i][1]=b[i-1][1]+a[i][1].num;
  }
  for(int i=1;i<=n;i++){
  for(int j=2;j<=n;j++){
  if(a[i][j].num+b[i-1][j]>=a[i][j].num+b[i][j-1]){
  b[i][j]=a[i][j].num+b[i-1][j];
  a[i][j].x=i-1;a[i][j].y=j;
  }
  else {
  b[i][j]=a[i][j].num+b[i][j-1];
  a[i][j].x=i;a[i][j].y=j-1;
  }
  }
  }
  for(int i=1;i<=n;i++){
  for(int j=1;j<=n;j++){
  cout<<a[i][j].num<<" ";
  }
  cout<<endl;
  }
  cout<<endl;
  sum+=b[n][n];
  int i=n,j=n,ix;
  while(a[i][j].x||a[i][j].y){
  a[i][j].num=0;
  ix=i;
  i=a[i][j].x;
  j=a[ix][j].y;
  
  }
  for(int i=1;i<=n;i++){
  for(int j=1;j<=n;j++){
  cout<<a[i][j].num<<" ";
  }
  cout<<endl;
  }
  
  for(int i=1;i<=n;i++){
  for(int j=1;j<=n;j++){
  b[i][j]=0;
  }
  }
  for(int i=2;i<=n;i++){
  b[1][i]=b[1][i-1]+a[1][i].num;
  }
  for(int i=2;i<=n;i++){
  for(int j=1;j<=n;j++){
  b[i][j]=max(a[i][j].num+b[i][j-1],a[i][j].num+b[i-1][j]);
  }
  }
  sum+=b[n][n];
  cout<<sum;*/
/*cin>>n;
  for(int i=1;i<=n;i++){
  cin>>a[i]>>b[i]>>c[i]>>d[i];
  }
  cin>>x>>y;
  for(int i=1;i<=n;i++){
  if(x>=a[i]&&y>=b[i]&&x<=(a[i]+c[i])&&y<=(b[i]+d[i])){
  sum=i;
  }
  }
  cout<<sum;*/
/*int n,m,a,b;
  cin>>n>>m>>a>>b;
  n++;m++;a++;b++;
  int s[n+2][m+2]={0};
  int x[9]={1,2,2,1,-1,-2,-2,-1,0};
  int y[9]={2,1,-1,-2,2,-1,1,-2,0};
  t t[9];
  s[1][0]=1;
  int f[n+2][m+2]={0};
  for(int i=0;i<=8;i++){
  t[i].x=a+x[i];
  t[i].y=b+y[i];
  f[t[i].x][t[i].y]=1;
  }
  for(int i=1;i<n;i++){
  for(int j=1;j<m;j++){
  if(f[i][j]){
  continue;
  }
  s[i][j]=s[i-1][j]+s[i][j-1];
  }
  }
  cout<<s[n][m];
  int k;
  cin>>k;
  double sum=0,n=1;
  while(1){
  sum=sum+1/n;
  if(sum>k){
  printf("%d",(int)n);
  break;
  }
  n++;
  }
  int a[10],h;
  for(int i=0;i<10;i++){
  cin>>a[i];
  }
  cin>>h;
  h+=30;
  sort(a,a+10);
  for(int i=0;i<10;i++){
  if(a[i]>h){
  cout<<i;
  break;
  }
  }
  int l,m,sum=0;
  cin>>l>>m;
  int x[m],y[m];
  for(int i=0;i<=l;i++){
  a[i]=1;
  }
  for(int i=0;i<m;i++){
  cin>>x[i]>>y[i];
  for(int j=x[i];j<=y[i];j++){
  if(a[j]==1){
  a[j]=0;
  sum++;
  }
  }
  }
  cout<<l-sum+1;
  int V,n;
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
  cout<<V-b[l-1];
  ll k,N,i=0,sum=0;
  cin>>k>>N;
  while(N){
  a[i]=N%2;
  N/=2;
  i++;
  }
  for(int j=i-1;j>=0;j--){
  sum=sum*k+a[j];
  }
  cout<<sum;
  ll n,m,t,l=1,h,mid;
  cin>>n>>m;
  for(int i=1;i<=n;i++){
  cin>>a[i];
  }
  sort(a+1,a+1+n);
  for(int i=0;i<m;i++){
  cin>>t;
  h=n;
  l=1;
  while(l<=h)
  {
  mid=(l+h)/2;
  if(t>a[mid])
  {
  l=mid+1;
  }
  else if(t<a[mid])
  {
  h=mid-1;
  }
  else break;
  }
  if(t==a[mid]){
  cout<<"Y"<<endl;
  }
  else cout<<"N"<<endl;
  }*/
/*int n,sum=0,b=0;
  cin>>n;
  for(int i=1;i<=n;i++){
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
  cout<<sum;*/


