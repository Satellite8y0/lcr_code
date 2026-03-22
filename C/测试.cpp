#include<bits/stdc++.h>
using namespace std;
struct line{
	int data=0;
	line *next;
};
void addline(line *newdata,line *a){
	a->next=newdata;
	newdata->next=NULL;
}
void read(line *a){
	line *b=a;
	do{
		cout<<b->data<<endl;
		b=b->next;
	}while(b->next!=NULL);
}
int main()
{
	line *head=new line;
	head->data=1;
	line *newdata=new line;
	newdata->data=2;
	addline(newdata,head);
	read(head);
	
}

