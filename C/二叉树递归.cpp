#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<time.h>
typedef struct BiTNode
{
	int data;
	struct BiTNode *lchild,*rchild;
}BiTree;
void CreateBiTree(BiTree *T)
{
	int ch;
	scanf("%d",&ch);
	if(ch=='#')
	{
		T=NULL;
	}
	else
	{
		T=(BiTree*)malloc(sizeof(BiTree));
		T->data=ch;
		CreateBiTree(T->lchild);
		CreateBiTree(T->rchild);
	}
}
void midread(BiTree *T)
{
	if(T){
		midread(T->lchild);
		printf("",T->data);
		midread(T->rchild);
	}
}
void preread(BiTree *T)
{
	if(T){
		printf("",T->data);
		preread(T->lchild);
		preread(T->rchild);
	}
}
void postread(BiTree *T)
{
	if(T){
		postread(T->lchild);
		postread(T->rchild);
		printf("",T->data);
	}
}
int Depth(BiTree *T)
{
	int n,m;
	if(T==NULL){
		return 0;
	}
	else{
		m=Depth(T->lchild);
		n=Depth(T->rchild);
		if(m>n){
			return (m+1);
		}
		else{
			return (n+1);
		}
	}
}
int Nodecount(BiTree *T)
{
	if(T==NULL){
		return 0;
	}
	else{
		return Nodecount(T->lchild)+Nodecount(T->rchild)+1;
	}
}
int Width1(int *a,BiTree *T)
{
	int max=-1,i=1;
	for(i=1;i<=Depth(T);i++){
		if(a[i]>=max){
			max=a[i];
		}
	}
	return max;
}
int Width2(BiTree *T,int *a,int i)
{
	if(T->lchild!=NULL){
		a[i+1]++;
		Width2(T->lchild,a,i+1);
	}
	if(T->rchild!=NULL){
		a[i+1]++;
		Width2(T->rchild,a,i+1);
	}
	return Width1(a,T);
}
int Leaf(BiTree *T)
{if(T==NULL){
	return 0;}
	else 
	{if(T->lchild==NULL&&T->rchild==NULL)
		return 1;
	else{
		return (Leaf(T->lchild)+Leaf(T->rchild));
	}
	}
}
void Branchcount(BiTree *T)
{
	printf("%d",Nodecount(T)-1);
}
int main()
{
	
} 
