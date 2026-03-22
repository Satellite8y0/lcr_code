#include<bits/stdc++.h>
using namespace std;
#define ll long long
struct in{
	int s;
	int e;
	int n=0;
};
const ll N=3e5+10;
ll a[N],b[N],n;
bool cmp(in c,in b){
	return c.s>b.s;
}
int main()
{
	int *i;
	int t=100;
	i=&t;
	int j=*i;
	cout<<i<<endl;
	cout<<j<<endl;
	/*int a,max=0;
	scanf("%d",&a);
	int b[a+2];
	b[0]=1000000;
	for(int i=1;i<a+1;i++){
		scanf("%d",&b[i]);
		if(b[0]>abs(b[i])){
			b[0]=abs(b[i]);
		}
	}
	printf("%d",b[0]);
	int X,Y,num=0,n,m,temp,z;
	long long Xm=1,Ym=1,t,max=0,min=998244353;
	scanf("%d",&X);
	int Xs[X+1],Xz[X+1];
	for(int i=0;i<X;i++){
		cin>>Xs[i];
	}
	for(int i=0;i<X;i++){
		cin>>Xz[i];
	}
	scanf("%d",&Y);
	int Ys[X+1],Yz[X+1];
	for(int i=0;i<Y;i++){
		cin>>Ys[i];
	}
	for(int i=0;i<Y;i++){
	    cin>>Yz[i];
	}
	for(int i=0;i<X;i++){
		t=pow(Xs[i],Xz[i]);
		t=t%998244353;
		if(max<Xs[i]){
			max=Xs[i];
		}
		if(min>Xs[i]){
			min=Xs[i];
		}
		Xm=(t*Xm)%998244353;
	}
	for(int i=0;i<Y;i++){
		t=pow(Ys[i],Yz[i]);
		t=t%998244353;
		if(max<Ys[i]){
			max=Ys[i];
		}
		if(min>Ys[i]){
			min=Ys[i];
		}
		Ym=(t*Ym)%998244353;
	}
	if(Xm<Ym){
        printf("0");
	}
	else {
	    if(Xm%Ym==0){
			num++;
			while(min<=max){
				m=Ym*min;n=Xm/min;
				printf("%d,%d\n",n,m);
				if(m%Ym==0){
					while(n>0){
						temp=m%n;
						m=n;
						n=temp;
					}
					if(m==Ym){
						
						num++;
					}
				}
				
				min++;
			}
		}
		if(num==1){
			printf("%d",num);
		}
		else {
			num=num*2;
			printf("%d",num);
		}
	}
	int a[4],temp,sum;
	for(int i=0;i<=3;i++){
		cin>>a[i];
	}
	if(a[0]==a[3]||a[2]==a[1]){
		printf("YES");
	}
	else printf("NO");
	int n,m;
	scanf("%d %d",&n,&m);
	printf("%d",n-m);
	return 0;
	int n,m,k,ki,mi,t;
	int a[m][2];
	for(int i=0;i<m;i++){
		scanf("%d %d",&a[m][1],&a[m][2]);
	}
	t=1;
	ki=k;
	mi=m;
	while(mi){
		
	}
	int input;
	cin>>input;
	while(input){
		int a,b,c,t=0;
		cin>>a>>b>>c;
		while(a=b){
			if(a>b){
				b=b+c;
				t++;
			}
			else {
				a=a+c;
				t++;
			}
		}
		printf("%d",t);
		input--;
	}*/
	/*int a[n],c[n],b[n]={0},temp;
	  for(int i=0;i<n;i++){
	  cin>>a[i];
	  c[i]=i+1;
	  if(a[i]==c[i]){
	  b[i]=1;
	  }
	  }
	  for(int i=0;i<n;i++){
	  if(b[i]==1){
	  for(int j=i+1;j<n;j++){
	  if(c[i]!=a[j]){
	  temp=c[i];
	  c[i]=c[j];
	  c[j]=temp;
	  break;
	  }
	  }	
	  }
	  }
	  for(int i=0;i<n;i++){
	  printf("%d ",c[i]);
	  }
	  printf("\n");*/
	/*int n;
	  cin>>n;
	  
	  in c[n];
	  int d[n];
	  for(int i=0;i<n;i++){
	  cin>>c[i].a;
	  c[i].b=i;
	  }
	  sort(c,c+n,cmp);
	  for(int i=0;i<n;i++){
	  d[c[i].b]=n-i;
	  }
	  for(int i=0;i<n;i++){
	  cout<<d[i]<<" ";
	  
	  }
	  printf("\n");*/
	/*int n,t=-1;
	  cin>>n;
	  in a[n+1],p;
	  for(int i=0;i<n;i++){
	  cin>>a[i].s>>a[i].e;
	  }
	  p.s=a[0].s;
	  p.e=a[0].e;
	  a[0].n=1;
	  sort(a,a+n,cmp);
	  for(int i=0;i<n;i++){
	  if((a[i].n)and((a[i].s)!=(a[i+1].s))){
	  t=a[i].s;
	  break;
	  }
	  if(((a[i].e)>=(p.e))and!(a[0].n)){
	  t=-1;
	  break;
	  }
	  }
	  printf("%d\n",t);*/
	/*ll n,suma=0,sumb=0,sum=0;
	  cin>>n;
	  ll a[n],b[n],mna=1e18,mnb=1e18;
	  for(int i=0;i<n;i++){ 
	  cin>>a[i];
	  mna=min(mna,a[i]);
	  }
	  for(int i=0;i<n;i++){
	  cin>>b[i];
	  mnb=min(mnb,b[i]);
	  }
	  for(int i=0;i<n;i++){
	  suma=suma+mna+b[i];
	  }
	  for(int i=0;i<n;i++){
	  sumb=sumb+mnb+a[i];
	  }
	  if(sumb<suma){
	  sum=sumb;
	  }
	  else{
	  sum=suma;
	  }
	  printf("%d\n",sum);*/
	/*int n,k,b=0;
	  cin>>n>>k;
	  int a[n];
	  for(int i=0;i<n;i++){
	  cin>>a[i];
	  if(a[i]==k){
	  b=1;
	  }
	  }
	  if(b){
	  printf("YES\n");
	  }
	  else printf("NO\n");*/
	/*ll a;
	  ll i=2;
	  cin>>a;
	  ll t=2;
	  ll b=9,c=15,d=18;
	  printf("%lld %lld ",b,c);
	  while(t<a){
	  if((d*3)%(b+c)==0){
	  d=d+3;
	  }
	  else{
	  b=c;
	  c=d;
	  printf("%lld ",d);
	  d=d+3;
	  t++;
	  }
	  }
	  printf("\n");*/
	/*double n,k,x;
	  cin>>n>>k>>x;
	  if(((k/2)*(1+n-k+n)>=x)and(x>=(k/2)*(1+k))){
	  printf("YES\n");
	  }
	  else{
	  printf("NO\n");
	  }*/
	/*ll n,k,q;
	  int a,b;
	  cin>>n>>k;
	  string s;
	  ll l[k],r[k];
	  cin>>s;
	  for(int i=0;i<k;i++){
	  cin>>l[i];
	  l[i]--;
	  }
	  for(int i=0;i<k;i++){
	  cin>>r[i];
	  r[i]--;
	  }
	  cin>>q;
	  ll x[q];
	  int d=0;
	  char tow;
	  for(int i=0;i<q;i++){
	  cin>>x[i];
	  x[i]--;
	  d=0;
	  while((l[d]<=x[i])and(x[i]<=r[d])and d<=k){
	  d++;
	  }
	  a=min(x[i],(r[d]+l[d]-x[i]));
	  b=max(x[i],(r[d]+l[d]-x[i]));
	  while(a<=b){
	  swap(s[a],s[b]);
	  a++;
	  b--;
	  }
	  }
	  for(int i=0;i<n;i++){
	  cout<<s[i];
	  }
	  cout<<endl;*/
	int input;
	cin>>input;
	while(input){
		
		input--;	
	}
	return 0;
}

