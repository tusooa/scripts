#ifndef CONVERT_HPP
#define CONVERT_HPP
#include <iconv.h>
#include <string>
#include <cstring>
#include <iostream>

using namespace std;
#define UTF82GBK iconv_open("UTF-8", "GBK");

string fromTo(const string & s, const char * from, const char * to)
{
  iconv_t conv = iconv_open(to, from);
  // copy to c-style str
  size_t oldLen = s.length() + 1;
  // kept for future `delete`
  char * oldFromStr = new char[oldLen];
  char * fromStr = oldFromStr;
  strcpy(fromStr, s.c_str());
  // allow for enough space
  size_t newLen = s.length() * 2 + 1;
  // kept for `delete` and string()
  char * oldToStr = new char[newLen];
  char * toStr = oldToStr;
  // do the conversion
  iconv(conv, &fromStr, &oldLen,
        &toStr, &newLen);
  // convert to std::string
  // be sure to use old*
  // because fromStr and toStr are CHANGED by iconv.
  string newStr(oldToStr);
  // clean up
  // ditto.
  delete []oldFromStr;
  delete []oldToStr;
  iconv_close(conv);
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
