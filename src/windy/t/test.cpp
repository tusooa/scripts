#include <windows.h>
#include <stdlib.h>
#include <iostream>
using namespace std;
HINSTANCE dll;

int main(int argc, char* argv[])
{
  if (argc != 2) {
    cout << "one and only one argument expected" << endl;
    return 1;
  }
  if (! (dll = LoadLibrary(argv[1]))) {
    cout << "cannot load library." << endl;
    return 1;
  }
  cout << "fine" << endl;
  return 0;
}
