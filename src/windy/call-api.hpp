#ifndef CALL_API_HPP
#define CALL_API_HPP

#include <windows.h>
#include <loadlib.hpp>
#include <iostream>
#include <string>
#include <vector>
#include "convert.hpp"
using namespace std;

string callApi(string func, vector<string> args) {
#include "call-api.hpp.part"
  return string();
}

#endif

