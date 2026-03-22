#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<time.h>
typedef struct BiTNode
{
	int data;
	struct BiTNode *lchild,*rchild;
}BiTree;
void preread(BiTree *T)
{
	if(T==NULL)
	{
		return;
	}
	BiTree* box[10];
	int boxtop=-1;
	BiTree *move=T;
	while(boxtop!=-1||move)
	{
		while(move)
		{
			printf("%d\n",move->data);
			box[++boxtop]=move;
			move=move->lchild;
		}
		if(boxtop!=-1)
		{
			move=box[boxtop];
			boxtop--;
			move=move->rchild;
		}
	}
}
void midread(BiTree *T)
{
	BiTree*box[10];
	int boxtop=-1;
	BiTree *move=T;
	while (boxtop!=-1||move)
	{
		while(move)
		{
			box[++boxtop]=move;
			move=move->lchild;
		}
		if(boxtop!=-1)
		{
			move=box[boxtop--];
			printf("%d\n",move->data);
			move=move->rchild;
		}
	}
}

void postread(BiTree*T)
{
	if(T==NULL)
	{
		return;
	}
	BiTree*box[10];
	int boxtop=-1;
	BiTree *move=T;
	BiTree *visit=NULL;
	while(move)
	{
		box[++boxtop]=move;
		move=move->lchild;
	}
	while(boxtop!=-1)
	{
		move=box[boxtop--];
		if(move->rchild==NULL||move->rchild==visit)
		{
			printf("%d\n",move->data);
			visit=move;
		}
		else
		{
			box[++boxtop]=move;
			move=move->rchild;
			while(move)
			{
				box[++boxtop]=move;
			move=move->lchild;
			}
		}
	}
}
int main()
{
		
}
