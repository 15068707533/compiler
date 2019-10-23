
#include <direct.h>
#include <iostream>
#include <string>
#include <windows.h>
using namespace std;

/*
	文件:一件编译
	功能:给出根目录,自动搜索根目录下的src目录中所有的.cpp文件(递归搜索src下面的所有源文件),并将其编译之bin目录中,编译后的可执行文件名为main.exe
	优点:超级轻量化,整个程序仅使用字符串函数处理.
	缺点:过于单调,不够灵活,功能太少.

	目录结构:
		根目录
			Bin									//	可执行文件目录(暂部分DEBUG版和调试版,待解决依赖问题后再行优化),目前仅支持简单的编译命令
			Include								//	头文件目录(暂不支持递归,待解决依赖问题后再行优化)
			Src									//	源代码目录(自动递归该目录下的所有源文件))

	待优化:
		1.库目录结构和源目录结构一致化.
		2.文件依赖关系目前尚无头绪,特别是头文件和源文件之间.
		3.g++ -c 指令并不能指定obj文件的输出目录,需要自行将obj文件复制到lib中,然后在将根目录中的obj文件删除.
		4.暂不支持自行组建文件目录结构.
		5.由于g++的编译命令较为简单,暂仅支持g++编译.
		6.由于水平有限,暂不支持设置文件功能.
		7.需要自行将目录结构搭建好.
*/

string ROOT;
string BIN, INC, LIB, SRC;
string srcs;
string CPP = "g++ -g ";

void getFile( string& src);

int main(int argv,char **argc) {
	if (argv != 2)
		cout << "命令错误\n" << endl;
	else {
		ROOT = argc[1];
		BIN = "-o " + ROOT + "\\" + "Bin\\main.exe "; //	可执行文件目录
		INC = "-I " + ROOT + "\\" + "Include ";       //	头文件目录
		LIB = ROOT + "\\" + "Lib";           //	库文件目录
		SRC = ROOT + "\\" + "Src";           //	源文件目录

		getFile(SRC);
		if (srcs!="") {
			CPP +=INC + BIN + srcs;
			system(CPP.data());							//	gcc -i INC -c libName srcName
		}
	}
	return 0;
}

void getFile(string& src) {
	string srcName=src+"\\"+"*.cpp";									//	源文件名
	WIN32_FIND_DATA srcFileData;	
	HANDLE          srcFileHandle = FindFirstFile(srcName.data(), &srcFileData);	//	文件句柄
	do {
		srcName = srcFileData.cFileName;
		if (srcName == "." || srcName == "..")
			continue;
		else if (srcFileData.dwFileAttributes == FILE_ATTRIBUTE_ARCHIVE) {		//	文件
			srcs +=src+"\\"+srcName+" ";					//	库列表
		}
		else if (srcFileData.dwFileAttributes == FILE_ATTRIBUTE_DIRECTORY) {	//	目录
			srcName = src + "\\" + srcName;
			getFile(srcName);
		}
	} while (FindNextFile(srcFileHandle, &srcFileData));
}
