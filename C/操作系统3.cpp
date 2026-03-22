#include <bits/stdc++.h>
// 空闲区结构体
struct FreeArea {
	int start;  // 起始地址
	int length; // 长度
	bool isFree; // 是否空闲
};

// 打印空闲区说明表
void printFreeAreas(const std::vector<FreeArea>& freeAreas) {
	std::cout << "起    址\t长    度\t状      态\n";
	for (const auto& area : freeAreas) {
		std::cout << area.start << "\t" << area.length << "\t";
		std::cout << (area.isFree ? "未 分 配" : "已 分 配") << "\n";
	}
}

// 查找第一个足够大的空闲区
int findFreeArea(std::vector<FreeArea>& freeAreas, int size) {
	for (int i = 0; i < freeAreas.size(); ++i) {
		if (freeAreas[i].isFree && freeAreas[i].length >= size) {
			return i;
		}
	}
	return -1; // 未找到足够大的空闲区
}

// 分配空间
bool allocate(std::vector<FreeArea>& freeAreas, int start, int size) {
	int index = findFreeArea(freeAreas, size);
	if (index == -1) {
		return false; // 分配失败
	}
	
	// 分配空间
	freeAreas[index].isFree = false;
	
	// 如果分配后有空余空间，则将其拆分为两部分
	if (freeAreas[index].length > size) {
		FreeArea newFreeArea = {freeAreas[index].start + size, freeAreas[index].length - size, true};
		freeAreas.insert(freeAreas.begin() + index + 1, newFreeArea);
		freeAreas[index].length = size;
	}
	
	return true; // 分配成功
}

// 释放空间并合并相邻的空闲区
void deallocate(std::vector<FreeArea>& freeAreas, int start, int size) {
	for (int i = 0; i < freeAreas.size(); ++i) {
		if (!freeAreas[i].isFree && freeAreas[i].start == start && freeAreas[i].length == size) {
			freeAreas[i].isFree = true;
			
			// 合并相邻的空闲区
			if (i > 0 && freeAreas[i - 1].isFree) {
				freeAreas[i - 1].length += freeAreas[i].length;
				freeAreas.erase(freeAreas.begin() + i);
				--i; // 更新索引
			}
			if (i < freeAreas.size() - 1 && freeAreas[i + 1].isFree) {
				freeAreas[i].length += freeAreas[i + 1].length;
				freeAreas.erase(freeAreas.begin() + i + 1);
			}
			break;
		}
	}
}

int main() {
	// 初始化空闲区说明表
	std::vector<FreeArea> freeAreas = {{0, 1024, true}};
	
	// 打印初始状态
	std::cout << "初始状态:\n";
	printFreeAreas(freeAreas);
	
	// 作业申请与释放序列
	allocate(freeAreas, 0, 300); // 作业1申请300K
	allocate(freeAreas, 0, 100); // 作业2申请100K
	deallocate(freeAreas, 0, 300); // 作业1释放300K
	allocate(freeAreas, 0, 150); // 作业3申请150K
	allocate(freeAreas, 0, 30);  // 作业4申请30K
	allocate(freeAreas, 0, 40);  // 作业5申请40K
	allocate(freeAreas, 0, 60);  // 作业6申请60K
	deallocate(freeAreas, 330, 30); // 作业4释放30K
	
	// 打印每次申请或释放后的状态
	std::cout << "\n作业1申请300K后:\n";
	printFreeAreas(freeAreas);
	
	std::cout << "\n作业2申请100K后:\n";
	printFreeAreas(freeAreas);
	
	std::cout << "\n作业1释放300K后:\n";
	printFreeAreas(freeAreas);
	
	std::cout << "\n作业3申请150K后:\n";
	printFreeAreas(freeAreas);
	
	std::cout << "\n作业4申请30K后:\n";
	printFreeAreas(freeAreas);
	
	std::cout << "\n作业5申请40K后:\n";
	printFreeAreas(freeAreas);
	
	std::cout << "\n作业6申请60K后:\n";
	printFreeAreas(freeAreas);
	
	std::cout << "\n作业4释放30K后:\n";
	printFreeAreas(freeAreas);
	
	// 检查是否能满足100K的作业空间申请
	bool canAllocate100K = (findFreeArea(freeAreas, 100) != -1);
	std::cout << "\n能否满足100K的作业空间申请: " << (canAllocate100K ? "能" : "不能") << "\n";
	
	return 0;
}
