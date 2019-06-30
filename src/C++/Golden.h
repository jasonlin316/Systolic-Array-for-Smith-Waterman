using namespace std;

#include <iostream>
#include <cmath>
#include <vector>
#include <string>
#include <algorithm>
extern string s,t;
extern string l1,l2;
void smith_waterman(string ,string );
double similarity(char a,char b);
double score(vector<vector<double> >& dp,int row,int col,vector<vector<double> >&,vector<vector<double> >&,vector<vector<double> >&);
void E_func(vector<vector<double> >& dp,int row,int col);
void F_func(vector<vector<double> >& dp,int row,int col);
void calculation(vector<vector<double> >&,vector<vector<double> >&,vector<vector<double> >&,vector<vector<double> >&);
void traceback(vector<vector<double> > dp,vector<vector<double> >,double,double);