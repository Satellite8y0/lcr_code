#include<bits/stdc++.h>
using namespace std;
#define ll long long
ll dp1[200000],dp2[200000 ];
ll a[2002000];
ll n;
int main()
{
	ll cnt=1;
	while(cin>>a[cnt++]){}
	cnt-=2;
	ll len1=1;//存放最长不上升子序列长度，即最多导弹数，最少为一
	ll len2=1;//存放最长上升子序列长度，即最少系统数,最少为一
	dp1[1]=a[1];
	dp2[1]=a[1];
	for(int i=2;i<=cnt;i++){
		if(a[i]<=dp1[len1]){
			len1++;
			dp1[len1]=a[i];
		}
		else {//如果比当前最小值大，二分更新dp中的第一个小于a[i]的值
			ll l=1,r=len1,mid;
			while(l<r){
				mid=(l+r)>>1;
				if(dp1[mid]>=a[i]){
					l=mid+1;
				}
				else r=mid;
			}
			dp1[l]=a[i];
		}
		if(a[i]>dp2[len2]){
			len2++;
			dp2[len2]=a[i];
		}
		else {//如果比当前最小值大，二分更新dp中的第一个小于a[i]的值
			ll l=1,r=len2,mid;
			while(l<r){
				mid=(l+r)>>1;
				if(dp2[mid]<a[i]){
					l=mid+1;
				}
				else r=mid;
			}
			dp2[l]=a[i];
		}
	}
	cout<<len1<<endl<<len2<<endl;
	return 0;
}
