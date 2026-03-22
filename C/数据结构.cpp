#include<bits/stdc++.h>
using namespace std;
#define ll long long
#define InitSize 10
struct student{
	ll num;
	string name;
};
struct SqList{//顺序表
	student *data;
	ll maxsize;
	ll length;
};
struct LNode{//单链表
	student data;
	LNode *next;
};

void InitList(SqList &L){//创建顺序表
	L.data=new student[L.maxsize];
	L.length=0;
	L.maxsize=InitSize;
}
void IncreaseSize(SqList &L,ll increasesize){
	student *st=L.data;
	ll presize=L.maxsize;
	L.maxsize+=increasesize;
	L.data=new student[L.maxsize];

	
	for(int i=0;i<presize;i++){
		L.data[i].num=st[i].num;
	}
	delete st;
}
bool InsertElement(SqList &L,ll locate,ll e){
	if(locate<1||locate>L.length+1){
		return false;
	}
	if(L.length>=L.maxsize){
		return false;
	}
	for(int i=L.length;i>=locate;i--){
		L.data[i]=L.data[i-1];
	}
	L.data[locate-1].name=e;
	L.length++;
	return true;
}
bool DeleteElement(SqList &L,ll locate,ll &e){//删除元素
	if(locate<1||locate>L.length+1){
		return false;
	}
	e=L.data[locate].num;
	for(int j=locate;j<L.length;j++){
		L.data[j-1]=L.data[j];
	}
	L.length--;
	return true;
}
int main(){
	//SqList L;
	//InitList(L);
	return 0;
}
