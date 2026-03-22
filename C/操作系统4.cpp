#include <iostream>
#include <vector>
#include <algorithm>
#include <cstdlib>
#include <ctime>

using namespace std;

// 计算两个磁道号之间的距离
int distance(int head, int track) {
	return abs(head - track);
}

// SCAN算法实现
void scanAlgorithm(int head, vector<int>& requests, int totalTracks) {
	bool direction = true; // true表示向右，false表示向左
	int currentPos = head;
	int seekSequence;
	int totalSeekTime = 0;
	int numRequests = requests.size();
	
	// 打印初始请求队列
	cout << "Initial request queue: ";
	for (int req : requests) {
		cout << req << " ";
	}
	cout << endl;
	
	while (!requests.empty()) {
		// 在当前方向上找到最远的请求
		auto it = max_element(requests.begin(), requests.end(), [&](int a, int b) {
			if (direction) {
				return a < b;
			} else {
				return a > b;
			}
			});
		
		seekSequence = *it;
		requests.erase(it);
		
		// 计算并打印当前移动距离
		int seekDistance = distance(currentPos, seekSequence);
		cout << "Move head from " << currentPos << " to " << seekSequence << " (distance: " << seekDistance << ")" << endl;
		totalSeekTime += seekDistance;
		
		currentPos = seekSequence;
		
		// 如果当前方向没有更多请求，则改变方向
		if (requests.empty() || (direction && (*requests.begin() > currentPos)) || (!direction && (*requests.begin() < currentPos))) {
			direction = !direction;
		}
	}
	
	// 计算平均寻道长度
	double averageSeekTime = static_cast<double>(totalSeekTime) / numRequests;
	cout << "Total seek time: " << totalSeekTime << endl;
	cout << "Average seek time: " << averageSeekTime << endl;
}

int main() {
	srand(time(0)); // 初始化随机数种子
	int totalTracks = 200;
	int headPosition = 100;
	int numRequests = 15;
	
	vector<int> requests;
	
	// 随机生成磁道请求序列
	for (int i = 0; i < numRequests; ++i) {
		requests.push_back(rand() % totalTracks);
	}
	
	// 调用SCAN算法进行磁盘调度
	scanAlgorithm(headPosition, requests, totalTracks);
	
	return 0;
}
