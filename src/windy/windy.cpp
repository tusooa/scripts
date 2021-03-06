#include "server_http.hpp"
#include "client_http.hpp"

#ifndef BOOST_SPIRIT_THREADSAFE
#define BOOST_SPIRIT_THREADSAFE
#endif
#include <json.hpp>
#include <windows.h>
#include <fstream>
#include <vector>
#include <algorithm>
#include <string>
#include <cstring>

#include "call-api.hpp"
#include "conf.hpp"

using namespace std;
using namespace nlohmann;
typedef SimpleWeb::Server<SimpleWeb::HTTP> HttpServer;
typedef SimpleWeb::Client<SimpleWeb::HTTP> HttpClient;
/*static __attribute__((destructor))*/ void final()
{
  //freeLibs();
}
static Conf config;

static HttpServer server;
static HttpClient client(config.sendServer);
static bool firstLoad = true;
/*static __attribute__((constructor))*/ void startServer()
{
  if (firstLoad) {
    server.config.port = config.recvPort;
    server.resource["^" + config.apiCallAddr + "$"]["POST"]=[](shared_ptr<HttpServer::Response> response, shared_ptr<HttpServer::Request> request) {
      try {
        json input;
        //set<string> args;
        request->content >> input;
        json output;
        output["seq"] = json::array();
        for (auto & curFunc : input["seq"]) {
          json a = curFunc["args"];
          vector<string> args;
          for (auto & i : a) {
            // ensure all args are string
            if (i.is_string()) {
              args.push_back(i);
            } else {
              args.push_back(i.dump());
            }
          }
          string func = curFunc["func"];
          string result = callApi(func, args);
          output["seq"].push_back(result);
        }
        stringstream content;
        content << output;
        content.seekp(0, ios::end);
        *response << "HTTP/1.1 200 OK\r\n"
        << "Content-Type: application/json\r\n"
        << "Content-Length: " << content.tellp() << "\r\n\r\n"
        << content.rdbuf();
      }
      catch(exception& e) {
        *response << "HTTP/1.1 400 Bad Request\r\nContent-Length: " << strlen(e.what()) << "\r\n\r\n" << e.what();
      }
    };
  
    server.default_resource["GET"]=[](shared_ptr<HttpServer::Response> response, shared_ptr<HttpServer::Request> request) {
      string content="Could not open path "+request->path;
      *response << "HTTP/1.1 400 Bad Request\r\nContent-Length: " << content.length() << "\r\n\r\n" << content;
    };
  }
  firstLoad = false;
  thread server_thread([](){
      //Start server
      server.start();
    });
  server_thread.detach();
}

#define EXTERN extern "C"
const int RET_DONE = 1;
const int RET_PASS = 0;
const int RET_STOP = 2;
const int UNKNOWN_EVENT = -1;

static bool initDone = false;
static bool targetAvail = false;

// check every X seconds for availability
void checkTarget()
{
  thread clientTestThread([]() {
      while (true) {
        try {
          if (!targetAvail) {
            auto res = client.request("POST", config.testAddr);
            targetAvail = true;
          }
        } catch (...) {
          this_thread::sleep_for(chrono::seconds(config.testSleepTime));
        }
      }
    });
  clientTestThread.detach();
}

// 这里把 info() 作为一个入口，避免了 DllMain 和 constructor 的使用。
// 于是避免了卡死。
// 真棒。
EXTERN __declspec(dllexport) char * info()
{
  if (!initDone) {
    loadLibs();
    startServer();
    targetAvail = false;
    if (config.testAddr.length()) { // meaning we want testing
      checkTarget();
    }
    initDone = true;
  }
  return "Mew~~~";
}
EXTERN __declspec(dllexport) void about() {}
EXTERN __declspec(dllexport) int end()
{
  if (initDone) {
    freeLibs();
    server.stop();
    targetAvail = false;
    initDone = false;
  }
  return 1;
}
EXTERN __declspec(dllexport) int
EventFun(char *tencent, int type, int subtype, char *source, char *subject, char *object, char *msg, char *rawmsg, char *backptr);

extern __declspec(dllexport) int
EventFun(char *tencent, int type, int subtype, char *source, char *subject, char *object, char *msg, char *rawmsg, char *backptr)
{
  int retvalue = RET_PASS;
  // Do not send the event if it is still unknown
  // to prevent potential errors
  // MAYBE...
  if (type == UNKNOWN_EVENT) {
    return retvalue;
  }
  // 原来 MPQ 会把空指针传进去。。。
  // C++ 的 try-catch 抓不到 Access Violation....
  // https://stackoverflow.com/questions/5951987/prevent-c-dll-exception-using-try-catch-internally
  char t[1] = {0};
  if (!tencent) {
    tencent = t;
  }
  if (!source) {
    source = t;
  }
  if (!subject) {
    subject = t;
  }
  if (!object) {
    object = t;
  }
  if (!msg) {
    msg = t;
  }
  if (!rawmsg) {
    rawmsg = t;
  }
  try {
    string smsg(msg);
    string sraw(rawmsg);
    json send = {
      {"tencent", string(tencent)},
      {"type", type},
      {"subtype", subtype},
      {"source", string(source)},
      {"subject", string(subject)},
      {"object", string(object)},
      {"msg", gbk2utf8(smsg)},
      {"rawmsg", gbk2utf8(sraw)},
    };
    stringstream jsonStream;
    jsonStream << send;
    string ss = jsonStream.str();
    if (targetAvail
        || // or we do not want testing
        config.testAddr.length() == 0) {
      try {
        auto ret = client.request("POST", config.sendAddr, ss);
        try {
          json retval;
          ret->content >> retval;
          retvalue = retval["ret"];
          string back = retval["msg"];
          if (back.length() && backptr) {
            string backGBK = utf82gbk(back);
            strcpy(backptr, backGBK.c_str());
          }
        } catch (...) { // json decoding error
          retvalue = RET_PASS;
        }
      } catch (...) { // post error
        targetAvail = false;
        retvalue = RET_PASS;
      }
    }
  } catch (...) { // other error
    retvalue = RET_PASS;
  }
  return retvalue;
}

