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
	cout << "\nprocess name " << pcb->name <<endl;
	cout << "remaining running time " << pcb->reqtime <<endl;
	cout << "priority rank: " << pcb->rank <<endl;
	cout << "status: " << pcb->state<<endl;
}
bool cmpreqtime(PCB a, PCB b){
	return a.reqtime > b.reqtime;
}

void run(PCB* head, PCB* runningprocess){
	if (cnt == 0) {
		cout << "\n******every pcb ends******\n";
		return;
	}
	cout << "\n##########process" << runningprocess->name << "running##########\n" ;
	runningprocess->reqtime--;//剩余运行时间-1
	runningprocess->rank--;//优先级-1	
	cout << "-----------------every pcb status------------------";
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
		cout << "\nplease input the " << i + 1 << "th process name :\n";
		cin >> P[i].name;
		cout << "\nplease input the rank of the process\n";
		cin >> P[i].rank;
		cout << "\nplease input the required time of the process\n";
		cin >> P[i].reqtime;
		P[i].state = 'R';//初始赋予就绪状态Running
		P[i].next = NULL;//进程指针初始化为空指针
		cnt++;
	}
}

int main(){
	HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
	CONSOLE_SCREEN_BUFFER_INFO consoleInfo;
	GetConsoleScreenBufferInfo(hConsole, &consoleInfo);
	consoleInfo.wAttributes = FOREGROUND_BLACK | BACKGROUND_WHITE;
	SetConsoleScreenBufferInfo(hConsole, &consoleInfo);
	
	// 这里是你原来的代码内容，例如：
	// 定义五个进程的PCB数组
	PCB* pcb_list[5];
	//...（省略其他原有代码部分）
	
	// 最后记得恢复控制台默认设置（可选，如果希望程序结束后控制台恢复原样的话）
	SetConsoleScreenBufferInfo(hConsole, &consoleInfo);
	init();
	input();
	sort(P, P + cnt, cmprank);//按照进程优先级排序
	for (int i = 1; i < cnt; i++)//对各指针赋值，形成队列
		P[i - 1].next = &P[i];
	head = &P[0];//头指针赋值
	runningprocess = &P[0];//正在运行的进程赋值
	cout << "\n---------------every pcb init status----------------\n";//打印各进程初始状态
	for (int i = 0; i < cnt; i++)
		print(&P[i]);
	cout << "\n---------------------------------------------------\n";
	run(head, runningprocess);//进程运行
	system("pause");
	return 0;
}

