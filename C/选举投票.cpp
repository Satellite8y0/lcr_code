#include<stdio.h>
#include<string.h>
int main()
{
	typedef struct ord{
		char name[10];
		int b;
	}p;
	int i;
	p a;
	p c[3]={{"Lisi",0},{"Zhangsan",0},{"Wuting",0}};
	FILE *fq;
	fq=fopen("in.txt","r");
	while(!feof(fq))
	{
		fscanf(fq,"%s",a.name);
		for(i=0;i<3;i++)
		{if(strcmp(c[i].name,a.name)==0)
		{
			c[i].b++;
		}
		}
	}
	fclose(fq);
	fq=fopen("out.txt","w+");
	for(i=0;i<3;i++)
		fprintf(fq,"名字%s 票数%d\n",c[i].name,c[i].b);
	fclose(fq);
	return 0;
}
