#include "server_http.hpp"
#include "client_http.hpp"

#define BOOST_SPIRIT_THREADSAFE
#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>
#include "call-api.hpp"
#include <windows.h>
#include <fstream>
#include <vector>
#include <algorithm>

#define RECV_PORT 7456
#define SEND_ADDR "localhost:7457"

using namespace std;
//Added for the json-example:
using namespace boost::property_tree;

typedef SimpleWeb::Server<SimpleWeb::HTTP> HttpServer;
typedef SimpleWeb::Client<SimpleWeb::HTTP> HttpClient;
/*static __attribute__((destructor))*/ void final()
{
  //freeLibs();
}
HttpServer server;
HttpClient client(SEND_ADDR);
/*static __attribute__((constructor))*/ void startServer()
{
  server.config.port = RECV_PORT;
  server.resource["^/api/call$"]["POST"]=[](shared_ptr<HttpServer::Response> response, shared_ptr<HttpServer::Request> request) {
    try {
      ptree input;
      //set<string> args;
      read_json(request->content, input);
      ptree output;
      for (ptree::value_type &f : input.get_child("seq")) {
        ptree curFunc = f.second;
        vector<string> args;
        string func = curFunc.get<string>("func");
        for (ptree::value_type &v : curFunc.get_child("args")) {
          args.push_back(v.second.data());
        }
        string result = callApi(func, args);
        output.add("seq", result);
      }
      stringstream content;
      write_json(content, output);
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
    
    thread server_thread([](){
        //Start server
        server.start();
    });
    /*    HttpClient client("localhost:8080");
    auto r1=client.request("GET", "/match/123");
    cout << r1->content.rdbuf() << endl;

    string json_string="{\"firstName\": \"John\",\"lastName\": \"Smith\",\"age\": 25}";
    auto r2=client.request("POST", "/string", json_string);
    cout << r2->content.rdbuf() << endl;
    
    auto r3=client.request("POST", "/json", json_string);
    cout << r3->content.rdbuf() << endl;
    */
    server_thread.detach();

    return;
}

#define EXTERN extern "C"
#define RET_DONE 1
#define RET_PASS 0
#define RET_STOP 2

static int initDone = 0;
// 这里把 info() 作为一个入口，避免了 DllMain 和 constructor 的使用。
// 于是避免了卡死。
// 真棒。
EXTERN __declspec(dllexport) char * info()
{
  if (!initDone) {
    loadLibs();
    startServer();
    initDone = 1;
  }
  return "Mew~~~";
}
EXTERN __declspec(dllexport) void about() {}
EXTERN __declspec(dllexport) int end() { return 1; }
EXTERN __declspec(dllexport) int
EventFun(char *tencent, int type, int subtype, char *source, char *subject, char *object, char *msg, char *rawmsg, char *backptr);

extern __declspec(dllexport) int
EventFun(char *tencent, int type, int subtype, char *source, char *subject, char *object, char *msg, char *rawmsg, char *backptr)
{
  int retvalue;
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
    ptree send;
    send.add("tencent", string(tencent));
    send.add("type", type);
    send.add("subtype", subtype);
    send.add("source", string(source));
    send.add("subject", string(subject));
    send.add("object", string(object));
    send.add("msg", string(msg));
    send.add("rawmsg", string(rawmsg));
    stringstream jsonStream;
    write_json(jsonStream, send);
    string ss = jsonStream.str();
    vector<string> args(1, ss);
    callApi("OutPut", args);
    //auto ret = client.request("POST", "/recv", ss);
    //ptree retval;
    //read_json(ret->content, retval);
    //retvalue = stoi(retval.get<string>("ret"));
    retvalue = RET_PASS;
  } catch(const exception &e) {
    retvalue = RET_PASS;
  }
  return retvalue;
}

