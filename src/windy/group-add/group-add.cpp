#include "loadlib.hpp"
#define EXTERN extern "C"
#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/ini_parser.hpp>
#include <string>
#include <iostream>
#define RET_DONE 1
#define RET_PASS 0
#define RET_STOP 2
std::string text, mainGroup;
namespace pt = boost::property_tree;
static __attribute__((constructor)) init()
{
  loadLibs();
  const std::string filename = "group-add.conf";
  pt::ptree conf;
  try {
    pt::read_ini(filename, conf);
    text = conf.get<std::string>("main.text");
    mainGroup = conf.get<std::string>("main.group");
  } catch(std::exception& e) {
    text = std::string();
    mainGroup = std::string();
  }
}
EXTERN __declspec(dllexport) char * info() { return "Dude."; }
EXTERN __declspec(dllexport) void about() {}
EXTERN __declspec(dllexport) int end() { return 1; }
EXTERN __declspec(dllexport) int
EventFun(char *tencent, int type, int subtype, char *source, char *subject, char *object, char *msg, char *rawmsg, char *backptr);

extern __declspec(dllexport) int
EventFun(char *tencent, int type, int subtype, char *source, char *subject, char *object, char *msg, char *rawmsg, char *backptr)
{
  if (type >= 1 && type <= 4 && std::string(msg) == text) {
    Api_GroupInvitation(tencent, subject, (char *)mainGroup.c_str());
    return RET_DONE;
  }
  return RET_PASS;
}
