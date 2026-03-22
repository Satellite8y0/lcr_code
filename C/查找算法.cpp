#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<time.h>
typedef struct HashTable
{
	int key=0;
	struct HashTable *next=NULL;
}HashTable;
void HashCreate1(HashTable *HT,int p,int m,int a)
{
	int key,Hk;
	float i=m,n=m;
	srand((unsigned int)time(NULL));
	while(m){
		key=rand()%99+1;
		Hk=key%p;
		while(key)
		{
		if(Hk==a){
			Hk=0;
		}
		if(HT[Hk].key==0){
			HT[Hk].key=key;
			key=0;
			m--;
		}
		else 
		{
			i++;
			Hk++;
		}
		}
	}
	int j=0;
	while(j<a){
		printf("%d ",HT[j].key);
		j++;
	}
	i=i/n;
	printf("\n平均查找长度:%f",i);
}
void HashCreate2(int p,int m,int a)
{
	HashTable HT[a];
	HashTable *ht;
	int key,Hk;
	float i=0,n=m,z;
	srand((unsigned int)time(NULL)+1);
	while(m){
		key=rand()%99+1;
		ht=(HashTable*)malloc(sizeof(HashTable));
		ht->key=key;
		Hk=key%p;
		ht->next=HT[Hk].next;
		HT[Hk].next=ht;
		m--;
	}
	int j=0;
	while(j<a){
		z=0;
		ht=HT[j].next;
		printf("%d ",HT[j].key);
		while(ht){
			z++;
			printf("%d ",ht->key);
			ht=ht->next;
			i=i+z;
		}
		printf("\n");
		j++;
	}
	i=i/n;
	printf("\n平均查找长度:%f",i);
}
int main()
{
	int p,m,a;
	HashTable HT[200];
	printf("输入表长:");
	scanf("%d",&a);
	printf("输入装填因子长度：");
	scanf("%d",&m);
	printf("输入除数：");
	scanf("%d",&p);
	printf("线性探测法\n");
	HashCreate1(HT,p,m,a);
	printf("\n链地址法\n");
	HashCreate2(p,m,a);
	return 0;
}


