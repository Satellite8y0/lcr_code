#include <bits/stdc++.h>
#define N 5
using namespace std;
class PCB{//进程块
public:
	PCB* next;//指针
	string name;//进程名
	int reqtime;//要求运行时间
	int rank;//优先级
	char state;//状态,R running E end
};
PCB* head;
int cnt=0;
PCB* runningprocess;
PCB P[N];
bool cmprank(PCB a, PCB b){//优先级从大到小比较函数
	return a.rank > b.rank;
}
void print(PCB* pcb) {
	cout << "\n进程名： " << pcb->name <<endl;
	cout << "要求运行时间： " << pcb->reqtime <<endl;
	cout << "优先级: " << pcb->rank <<endl;
	cout << "状态: " << pcb->state<<endl;
}
bool cmpreqtime(PCB a, PCB b){
	return a.reqtime > b.reqtime;
}

void run(PCB* head, PCB* runningprocess){
	if (cnt == 0) {
		cout << "\n******结束******\n";
		return;
	}
	cout << "\n##########进程" << runningprocess->name << "运行##########\n" ;
	runningprocess->reqtime--;//剩余运行时间-1
	runningprocess->rank--;//优先级-1	
	cout << "-----------------已就绪进程------------------";
	for (int i = 0; i < cnt; i++)  //显示已就绪进程
		print(&head[i]);
	cout << "\n---------------------------------------------------\n";
	if (runningprocess->reqtime == 0){//某个进程运行结束，打印提示信息
		runningprocess->state = 'E';//赋予结束状态E
		print(runningprocess);
		sort(head, head + cnt, cmpreqtime);//按照进程剩余时间排序，使该结束的进行排在队尾
		cnt--;
	}
	sort(head, head + cnt, cmprank);//按照进程优先级排序
	for (int i = 1; i < cnt; i++) //改变指针位置，当一个进程运行结束后退出队列
		head[i - 1].next = &head[i];
	runningprocess = head;//下一次运行的进程为队首进程
	run(head, runningprocess);//递归调用进程运行函数
}
void init() {
	head = NULL;//进程队列队首
	runningprocess = NULL;//正在运行的进程
	cnt = 0;//进程数
}
void input() {
	for (int i = 0; i < N; i++)//输入各进程状态
	{
		cout << "\n请输入第" << i + 1 << "个进程名 :\n";
		cin >> P[i].name;
		cout << "\n请输入优先级\n";
		cin >> P[i].rank;
		cout << "\n请输入要求运行时间\n";
		cin >> P[i].reqtime;
		P[i].state = 'R';//初始赋予就绪状态Running
		P[i].next = NULL;//进程指针初始化为空指针
		cnt++;
	}
}

int main(){

	init();
	input();
	sort(P, P + cnt, cmprank);//按照进程优先级排序
	for (int i = 1; i < cnt; i++)//对各指针赋值，形成队列
		P[i - 1].next = &P[i];
	head = &P[0];//头指针赋值
	runningprocess = &P[0];//正在运行的进程赋值
	cout << "\n---------------各进程初始状态----------------\n";//打印各进程初始状态
	for (int i = 0; i < cnt; i++)
		print(&P[i]);
	cout << "\n---------------------------------------------------\n";
	run(head, runningprocess);//进程运行
	system("pause");
	return 0;
}

