using namespace std;

#include <iostream>
#include <cmath>
#include <vector>
#include <string>
#include <algorithm>
#include <fstream>
#include <sstream>
#include "Golden.h"
#include <ctime>
#include <ratio>
#include <chrono>

int main(){
    using namespace std::chrono;    
    ifstream file("../dat/in_1.dat");
    string str,token;
    string delimiter = "_";
    size_t pos = 0;
    vector<vector<string> > data(1,vector<string>(2));
    int i = 0;
    while (std::getline(file, str))
    { 
        std::transform(str.begin(), str.end(), str.begin(), ::tolower);
        data[i/2][i%2] = str;
        if(i%2)data.push_back(vector<string>(2));
        i+=1;
    }
    ofstream myfile;
    myfile.open ("../dat/out_1.dat");
    myfile<<"";
    myfile.close();

    ofstream myfile2;
    myfile2.open ("../dat/BinaryInput.dat");
    myfile2<<"";
    myfile2.close();

    ofstream myfile3;
    myfile3.open ("../dat/data_size.dat");
    myfile3<<"";
    myfile3.close();

    data.pop_back();
    for(int i = 0;i < data.size();i++){
        smith_waterman(data[i][0],data[i][1]);
    }
}