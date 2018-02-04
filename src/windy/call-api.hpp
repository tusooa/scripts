#ifndef CALL_API_HPP
#define CALL_API_HPP

#include <windows.h>
#include <loadlib.hpp>
#include <iostream>
#include <string>
#include <vector>
#include <base64.h>
using namespace std;

string decodeBase64(string s)
{
  string to;
  Base64::Decode(s, &to);
  return to;
}

string & decodeBase64Here(string & s)
{
  return s = decodeBase64(s);
}

inline char * stoc(string & s)
{
  return ((char *)s.c_str());
}

inline char * dec_s(string & s)
{
  return stoc(decodeBase64Here(s));
}

string encodeBase64(string s)
{
  string to;
  Base64::Encode(s, &to);
  return to;
}

string callApi(string func, vector<string> args) {
  if (func == "SendMsg") {
    return
      to_string(Api_SendMsg
                (dec_s(args[0]),
                 stoi(args[1]),
                 stoi(args[2]),
                 dec_s(args[3]),
                 dec_s(args[4]),
                 dec_s(args[5])));
  }
  if (func == "OutPut") {
    return to_string(Api_OutPut(dec_s(args[0])));
  }
  return string("");
}

#endif
