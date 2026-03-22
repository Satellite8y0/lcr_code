#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<time.h>
clock_t start_time;
clock_t finish_time;
typedef struct stu
{
	char name[10];
	int grade;
	struct stu *next;
}stu;
void Initlist(stu *L)
{
	L=(stu*)malloc(sizeof(stu));
	L->next=NULL;
}
void Merge(stu *L,stu *R)
{
	stu *p=L,*q,*n=R->next;
	while(p->next){
		p=p->next;
	}
	p->next=n;
	for(p=L->next;p->next;p=p->next){
		q=p;
		for(;p->next;p=p->next){
			if(strcmp(q->name,p->name)==0){
				p->next=p->next->next;
			}
		}
		p=q;
	}
}
void Add(stu *L)
{
	stu *p=L,*n=(stu*)malloc(sizeof(stu));
	int b=100;
	char c[10]="lcr";
	n->grade=b;
	strcpy(n->name,c);
	int i=0;
	int a=rand()%2+1;
	for(;p->next;p=p->next)
	{
		i++;
		if(i+1==a){
			
			n->next=p->next;
			p->next=n;
			break;
		}
	}
}
void Read(stu *h)
{
	stu *p=h->next;
	while(p->next->next)
	{
		printf("%s  %d\n",p->name,p->grade);
		p=p->next;
	}
}
void Delete(stu *L)
{
	stu *p=L;
	int i=0;
	int a=rand()%2+1;
	for(;p->next;p=p->next)
	{
		i++;
		if(i+1==a){
			p->next=p->next->next;
			break;
		}
	}
}
void ADD(stu *L,char name[10],int grade)
{
	stu *p=L,*n;
	n=(stu*)malloc(sizeof(stu));
	strcpy(n->name,name);
	n->grade=grade;
	n->next=p->next;
	p->next=n;
}
int main()
{

	stu L,R;
	Initlist(&L);
	Initlist(&R);
	stu a[5],b[2];
	strcpy(a[1].name,"liyujia");
	a[1].grade=70;
	strcpy(a[3].name,"liming");
	a[3].grade=100;
	strcpy(a[0].name,"lihua");
	a[0].grade=89;
	strcpy(a[2].name,"lihan");
	a[2].grade=99;
	for(int j=1;j<=3;j++){
		ADD(&L,a[j].name,a[j].grade);
	}
	Read(&L);
	
} 
