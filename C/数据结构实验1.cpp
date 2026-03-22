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
void Merge(stu *L,stu *R)
{
	stu *p=L,*q;
	while(1){
		if(!(p->next)){
			break;
		}
		p=p->next;
	}
	p->next=R->next;
	p=L;
	for(;p->next;p=p->next){
		q=p;
		for(;p->next->next;p=p->next){
			if(strcmp(q->name,p->name)==0){
				p->next=p->next->next;
			}
		}
		p=q;
	}
}
void Initlist(stu *L)
{
	L=(stu*)malloc(sizeof(stu));
	L->next=NULL;
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
void Read(stu *h)
{
	stu *p=h->next;
	while(p->next->next)
	{
		printf("%s  %d\n",p->name,p->grade);
		p=p->next;
	}
}
void search(stu *L)
{
	int a=1;
	int i=0;
    stu *p=L;
	for(;p->next;p=p->next)
	{
		i++;
		if(i+1==a){
			printf("%s  %d",p->name,p->grade);
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
	start_time=clock();
	stu R,L;
	stu *n=(stu*)malloc(sizeof(stu));
	Initlist(&R);
	Initlist(&L);
	stu a[2];
	strcpy(a[0].name,"lyh");
	a[0].grade=88;
	strcpy(a[1].name,"lyj");
	a[1].grade=99;
	for(int i=0;i<=1;i++){
		ADD(&L,a[i].name,a[i].grade);
	}
	stu b[2];
	strcpy(b[0].name,"lcr");
	b[0].grade=100;
	strcpy(b[1].name,"qzh");
	b[1].grade=85;
	for(int i=0;i<=1;i++){
		ADD(&L,b[i].name,b[i].grade);
	}
	Add(&L);
	Delete(&L);
	finish_time=clock();
	printf("花费时间为%.100f\n",(float)(finish_time-start_time)/100000);
	return 0;
}
