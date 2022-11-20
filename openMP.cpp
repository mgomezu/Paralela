#include <iostream>
#include <stdlib.h>
#include <omp.h>
#include <string>

using namespace std;

int main(int argc, char* argv[]){
    String nameIn = argv[1];
    String nameOut = argv[2];
    int nThreads = stoi(argv[3]);
    int nArguments = argc;
    
    return 0;
}