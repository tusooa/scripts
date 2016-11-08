#ifndef CALL_API_HPP
#define CALL_API_HPP

#include <windows.h>
#include <loadlib.hpp>
#include <iostream>
#include <string>
#include <vector>
using namespace std;

string callApi(string func, vector<string> args) {
  if (func == "Api_SendMsg") {
    return
      to_string(Api_SendMsg
             ((char *)(args[0].c_str()),
              stoi(args[1]),
              stoi(args[2]),
              (char *)(args[3].c_str()),
              (char *)(args[4].c_str()),
              (char *)(args[5].c_str())));
  }
  return string("undefined");
}

#endif
