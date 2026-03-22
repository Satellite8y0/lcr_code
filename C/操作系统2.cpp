#include<bits/stdc++.h>
#include <iostream>
#include <vector>
using namespace std;

// 定义全局变量
const int P = 5; // 进程数量
const int R = 3; // 资源种类数量

// 数据结构
int Available[R];                 // 可用资源向量
int Max[P][R];                    // 最大需求矩阵
int Allocation[P][R];             // 分配矩阵
int Need[P][R];                   // 需求矩阵

// 初始化资源状态
void initialize() {
	// 初始化Available
	cout << "请输入可用资源向量（Available）:" << endl;
	for (int i = 0; i < R; i++) {
		cin >> Available[i];
	}
	
	// 初始化Max矩阵
	cout << "请输入最大需求矩阵（Max）:" << endl;
	for (int i = 0; i < P; i++) {
		for (int j = 0; j < R; j++) {
			cin >> Max[i][j];
		}
	}
	
	// 初始化Allocation矩阵
	cout << "请输入分配矩阵（Allocation）:" << endl;
	for (int i = 0; i < P; i++) {
		for (int j = 0; j < R; j++) {
			cin >> Allocation[i][j];
			Need[i][j] = Max[i][j] - Allocation[i][j]; // 计算Need矩阵
		}
	}
}

// 安全性算法
bool isSafeState() {
	int Work[R]; // 工作向量
	bool Finish[P] = {false}; // 进程完成状态
	
	// 初始化工作向量
	for (int i = 0; i < R; i++) {
		Work[i] = Available[i];
	}
	
	// 安全性检查
	for (int count = 0; count < P; count++) {
		bool found = false;
		for (int i = 0; i < P; i++) {
			if (!Finish[i]) { // 如果进程尚未完成
				bool canAllocate = true;
				for (int j = 0; j < R; j++) {
					if (Need[i][j] > Work[j]) {
						canAllocate = false; // 如果需求大于当前可用资源
						break;
					}
				}
				if (canAllocate) {
					// 模拟资源分配
					for (int j = 0; j < R; j++) {
						Work[j] += Allocation[i][j];
					}
					Finish[i] = true; // 进程完成
					found = true;     // 找到一个满足条件的进程
					break;
				}
			}
		}
		if (!found) { // 如果没有找到满足条件的进程
			return false;
		}
	}
	return true; // 所有进程都能完成，系统处于安全状态
}

// 银行家算法
void bankerAlgorithm() {
	int pid; // 请求的进程号
	int Request[R]; // 请求向量
	
	cout << "请输入请求的进程号（0~" << P - 1 << "）: ";
	cin >> pid;
	
	cout << "请输入请求资源向量（Request）: ";
	for (int i = 0; i < R; i++) {
		cin >> Request[i];
	}
	
	// 检查请求是否合理
	for (int i = 0; i < R; i++) {
		if (Request[i] > Need[pid][i]) {
			cout << "错误：请求超过进程的最大需求！" << endl;
			return;
		}
		if (Request[i] > Available[i]) {
			cout << "资源不足，请等待。" << endl;
			return;
		}
	}
	
	// 试探性分配资源
	for (int i = 0; i < R; i++) {
		Available[i] -= Request[i];
		Allocation[pid][i] += Request[i];
		Need[pid][i] -= Request[i];
	}
	
	// 检查安全性
	if (isSafeState()) {
		cout << "资源分配成功，系统处于安全状态。" << endl;
	} else {
		cout << "系统不安全，恢复分配状态。" << endl;
		// 恢复状态
		for (int i = 0; i < R; i++) {
			Available[i] += Request[i];
			Allocation[pid][i] -= Request[i];
			Need[pid][i] += Request[i];
		}
	}
}

int main() {
	// 初始化数据
	initialize();
	
	// 打印初始状态
	cout << "初始状态：" << endl;
	cout << "Available: ";
	for (int i = 0; i < R; i++) {
		cout << Available[i] << " ";
	}
	cout << endl;
	
	// 循环模拟资源分配
	char choice;
	do {
		bankerAlgorithm();
		cout << "是否继续请求资源？（y/n）: ";
		cin >> choice;
	} while (choice == 'y');
	
	return 0;
}
