#ifndef CONVERT_HPP
#define CONVERT_HPP
#include "iconvpp/iconv.hpp"
#include <string>
#include <cstring>
#include <iostream>

using namespace std;
const bool ICONVPP_IGNORE_ERROR = true;

string fromTo(const string & s, const char * from, const char * to)
{
  // allocate enough space
  size_t newLen = s.length() * 2 + 1;
  iconvpp::converter conv(to, from, ICONVPP_IGNORE_ERROR, newLen);
  string newStr;
  conv.convert(s, newStr);
  return newStr;
}

inline string gbk2utf8(const string & s) {
  return fromTo(s, "GBK", "UTF-8");
}

inline string utf82gbk(const string & s) {
  return fromTo(s, "UTF-8", "GBK");
}

string & utf82gbkHere(string & s) {
  return s = utf82gbk(s);
}

inline char * stoc(string & s) {
  return ((char *)s.c_str());
}

inline char * utf82gbk_c(string & s) {
  return stoc(utf82gbkHere(s));
}

#endif // CONVERT_HPP
