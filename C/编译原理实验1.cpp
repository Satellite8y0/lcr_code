#include<stdio.h>
#include<string.h>
#include<iostream>
using namespace std;
char prog[500], token[20];
char ch;
int syn, p, m = 0, n, row, sum = 0;
const char* rwtab[10] = { "if","int","for","while","do","return","break","continue","using","namespace"};
const char* rwtab1[8] = { "main","a","b","c","d","e","f","g" };

void scaner()
{
	/*
	  共分为三大块，分别是标示符、数字、符号，对应下面的 if   else if  和 else
	 */
	for (n = 0; n < 20; n++) token[n] = '\0';
	ch = prog[p++];
	while (ch == ' ')
	{
		ch = prog[p];
		p++;
	}
	/*******Beign*******/
	/*进行标示符或者关键字的识别*/
	if ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z'))
	{
		m = 0;
		while ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || (ch >= '0' && ch <= '9'))
		{
			token[m++] = ch;
			ch = prog[p++];
		}
		p--;
		token[m] = '\0';
		for (n = 0; n < 10; n++)
		{
			if (strcmp(token, rwtab[n]) == 0)
			{
				syn = 1;
				return;
			}
		}
		for (n = 0; n < 8; n++)
		{
			if (strcmp(token, rwtab1[n]) == 0)
			{
				syn = 2;
				return;
			}
		}
		syn = 2;
	}
	/********End********/
	
	/*******Beign*******/
	/*进行数字的识别*/
	else if ((ch >= '0' && ch <= '9'))
	{
		sum = 0;
		while (ch >= '0' && ch <= '9')
		{
			sum = sum * 10 + (ch - '0');
			ch = prog[p++];
		}
		p--;
		syn = 3;
	}
	/********End********/
	
	/*******Beign*******/
	/*进行其他字符的识别*/
	else
		
		switch (ch)
	{
		case'<':m = 0; token[m++] = ch;
		ch = prog[p++];
		if (ch == '>')
		{
			syn = 4;
			token[m++] = ch;
		}
		else if (ch == '=')
		{
			syn = 4;
			token[m++] = ch;
		}
		else
		{
			token[m++] = ch;
			syn = 4;
		}
		break;
		case'>':m = 0; token[m++] = ch;
		ch = prog[p++];
		if (ch == '=')
		{
			syn = 4;
			token[m++] = ch;
		}
		else
		{
			token[m++] = ch;
			syn = 4;
		}
		break;
		case':':m = 0; token[m++] = ch;
		ch = prog[p++];
		if (ch == '=')
		{
			syn = 4;
			token[m++] = ch;
		}
		else
		{
			syn = 4;
			p--;
		}
		break;
		case'/':syn = 5; token[0] = ch;
		token[1] = prog[p++];
		break;
		case'*':syn = 4; token[0] = ch; break;
		
		case'+':syn = 4; token[0] = ch; break;
		case'-':syn = 4; token[0] = ch; break;
		case'=':syn = 4; token[0] = ch; break;
		case';':syn = 5; token[0] = ch; break;
		case',':syn = 5; token[0] = ch; break;
		case'(':syn = 5; token[0] = ch; break;
		case')':syn = 5; token[0] = ch; break;
		case'{':syn = 5; token[0] = ch; break;
		case'}':syn = 5; token[0] = ch; break;
		case'"':syn = 5; token[0] = ch; break;
		case'#':syn = 0; token[0] = ch; break;
		case'\n':syn = -2; break;
		default: syn = -1; break;
	}
	/********End********/
}

int main()
{
	/*******Beign*******/
	/*输入*/
	p = 0;
	row = 1;
	cout << "Please input string:" << endl;
	do
	{
		cin.get(ch);
		prog[p++] = ch;
	} while (ch != '#');
	p = 0;
	/********End********/
	/*******Beign*******/
	/*输出*/
	do
	{
		scaner();
		switch (syn)
		{
		case 0:
			break;
		case 3:
			cout << "(" << syn << "," << sum << ")" << endl;
			break;
		case -1:
			cout << "Error in row " << row << "!" << endl;
			break;
		case -2:
			row++;
			break;
		default:
			cout << "(" << syn << "," << token << ")" << endl;
			break;
		}
	} while (syn != 0);
	/********End********/
	return 0;
}
