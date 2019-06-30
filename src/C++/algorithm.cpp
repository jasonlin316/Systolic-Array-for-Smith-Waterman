using namespace std;

#include <iostream>
#include <cmath>
#include <vector>
#include <string>
#include <algorithm>
#include <ctime>
#include <ratio>
#include <chrono>
#include <fstream>
//Programmable Factors
int match = 6;
int penalty = -3;
int alpha = 2;
int beta = 1;
//Scoring Functions
int similarity(char a,char b);
int score(vector<vector<int> >& dp,int row,int col,vector<vector<int> >&,vector<vector<int> >&,vector<vector<int> >&);
void E_func(vector<vector<int> >& dp,int row,int col);
void F_func(vector<vector<int> >& dp,int row,int col);
void calculation(vector<vector<int> >&,vector<vector<int> >&,vector<vector<int> >&,vector<vector<int> >&);
void traceback(vector<vector<int> > dp,vector<vector<int> >,int,int);
//Some Comparison Functions
int min(int a, int b) { return (a < b)? a: b; }  
int min(int a, int b, int c) { return min(min(a, b), c);} 
int max(int a, int b) { return (a > b)? a: b; } 
//Global Variables
string s,t;
string l1,l2;
int x,y,biggest=0;

void printMatrix(vector<vector<int> >& dp) 
{   
     std::ofstream myfile;
     myfile.open ("../dat/answer.csv");
     myfile<<"";
    int ROW = dp.size();
    int COL = dp[0].size();
    for (int i=0; i< ROW; i++) 
    { 
        for (int j=0; j<COL; j++)myfile << dp[i][j] << "," ;
        myfile << "\n"; 
    } 
    myfile.close();
} 

int main(){
    using namespace std::chrono; 
    int w,l;
    cout<<"Input sequence S:";
    cin >> t;
    cout<<"Input sequence T:";
    cin >> s;
    if(s.size()==0 || t.size()==0) return 0;
    
    s = "x" + s;
    t = "x" + t;
    int row = s.length();
    int col = t.length();
    vector<vector<int> > dp(row,vector<int>(col));
    vector<vector<int> > E_matrix(dp.size(),vector<int>(dp[0].size()));
    vector<vector<int> > F_matrix(dp.size(),vector<int>(dp[0].size()));
    vector<vector<int> > d_matrix(dp.size(),vector<int>(dp[0].size()));
    high_resolution_clock::time_point t1 = high_resolution_clock::now();
    calculation(dp,E_matrix,F_matrix,d_matrix);
    high_resolution_clock::time_point t2 = high_resolution_clock::now();
    printMatrix(dp);
    cout<<"--------Finish----------"<<endl;
    //printMatrix(E_matrix);
    traceback(dp,d_matrix,x,y);
    reverse(l1.begin(),l1.end());
    reverse(l2.begin(),l2.end());
    
    cout<<l1<<endl;
    cout<<l2<<endl;
    duration<double> time_span = duration_cast<duration<double> >(t2 - t1);
    cout<<"score: "<<biggest<<endl;
    std::cout << "Tooked " << (time_span.count()*1000000)  << " us.";
    std::cout << std::endl;
}

int similarity(char a,char b){
    if(a==b) return match;
    else return penalty;
}

void E_func(vector<vector<int> >& dp,vector<vector<int> >& E,int row,int col){
    int a = dp[row][col-1] - alpha;
    if(a<0) a = 0;
    int b = E[row][col-1] - beta;
    E[row][col] = max(a,b);
}

void F_func(vector<vector<int> >& dp,vector<vector<int> >& F,int row,int col){
    int a = dp[row-1][col] - alpha;
    if(a<0) a = 0;
    int b = F[row-1][col] - beta;
    F[row][col] = max(a,b);
}


int score(vector<vector<int> >& dp,int row,int col,vector<vector<int> >& E,vector<vector<int> >& F,vector<vector<int> >& D){
    //return the highest socre of the four
    int topleft = dp[row-1][col-1];
    int a = topleft + similarity(s[row],t[col]);
    int tmp1,tmp2,d1,d2,tmp_max;
    E_func(dp,E,row,col);
    F_func(dp,F,row,col);
    if(a > E[row][col]){ tmp1 = a; d1 = 0;}
    else{ tmp1 = E[row][col]; d1 = 1;}
    if(F[row][col] > 0){ tmp2 = F[row][col]; d2 = 2;}
    else{ tmp2 = 0; d2 = 3;}
    tmp_max = max(tmp1,tmp2);
    if(tmp_max > biggest){ y = row ; x = col; biggest = tmp_max;}//record the coordinate of the biggest value
    if(tmp1 > tmp2){ D[row][col] = d1; return tmp1;}
    else{ D[row][col] = d2; return tmp2;}
    //return max((max(a,E[row][col])),(max(F[row][col],0)));
}

void calculation(vector<vector<int> >& dp,vector<vector<int> >& E,vector<vector<int> >& F,vector<vector<int> >& D) 
{ 
    int ROW = dp.size();
    int COL = dp[0].size();
	for (int line = 1; line <= (ROW + COL -1); line++) 
	{ 
		int start_row = max(0, line-COL); 
		int count = min(line, (ROW-start_row), COL); 

		for (int j=0; j<count; j++)
        {
            int row = (start_row+j);
            int col = (min(COL, line)-j-1);
            if(row == 0 || col == 0) continue;
            dp[row][col] = score(dp,row,col,E,F,D);
        }
	} 
} 

void traceback(vector<vector<int> > dp,vector<vector<int> > d_matrix,int x,int y)
{
    //0:topleft,1:left,2:up,3:stop
    if(dp[y][x] == 0) return;
    else if(d_matrix[y][x]==0)
    {
        l1 += t[x];
        l2 += s[y];
        traceback(dp,d_matrix,x-1,y-1);
    }
    else if (d_matrix[y][x]==1)
    {
        l1 += t[x];
        l2 += "-" ;
        traceback(dp,d_matrix,x-1,y);
    }
    else if (d_matrix[y][x]==2)
    {
        l1 += "-";
        l2 += s[y];
        traceback(dp,d_matrix,x,y-1);
    }
}


