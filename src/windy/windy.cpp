#include "server_http.hpp"
#include "client_http.hpp"

//Added for the json-example
#define BOOST_SPIRIT_THREADSAFE
#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>
#include "call-api.hpp"
#include <windows.h>
//Added for the default_resource example
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

//Added for the default_resource example
//void default_resource_send(const HttpServer &server, shared_ptr<HttpServer::Response> response,
//                           shared_ptr<ifstream> ifs, shared_ptr<vector<char> > buffer);

//int main() {}
static __attribute__((destructor)) void final()
{
  //freeLibs();
}
HttpServer server(RECV_PORT, 1);
static __attribute__((constructor)) void startServer()
{
  cout << "out"<<endl;
  loadLibs();
  
  server.resource["^/api/call$"]["POST"]=[](shared_ptr<HttpServer::Response> response, shared_ptr<HttpServer::Request> request) {
    try {
      ptree pt;
      //set<string> args;
      read_json(request->content, pt);
      vector<string> args;
      string func = pt.get<string>("func");
      string name=func + "(";
      for (boost::property_tree::ptree::value_type &v : pt.get_child("args")) {
        args.push_back(v.second.data());
      }
      for (string a : args) {
        name += a + ", ";
      }
      name += ")=";
      name += callApi(func, args);

      *response << "HTTP/1.1 200 OK\r\n"
      << "Content-Type: text/plain\r\n"
      << "Content-Length: " << name.length() << "\r\n\r\n"
      << name;
    }
        catch(exception& e) {
            *response << "HTTP/1.1 400 Bad Request\r\nContent-Length: " << strlen(e.what()) << "\r\n\r\n" << e.what();
        }
    };
  
    server.default_resource["GET"]=[&server](shared_ptr<HttpServer::Response> response, shared_ptr<HttpServer::Request> request) {
      string content="Could not open path "+request->path;
      *response << "HTTP/1.1 400 Bad Request\r\nContent-Length: " << content.length() << "\r\n\r\n" << content;
    };
    
    thread server_thread([&server](){
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

EXTERN __declspec(dllexport) char * info() { return "Dude."; }
EXTERN __declspec(dllexport) void about() {}
EXTERN __declspec(dllexport) int end() { return 1; }
EXTERN __declspec(dllexport) int
EventFun(char *tencent, int type, int subtype, char *source, char *subject, char *object, char *msg, char *rawmsg, char *backptr);

extern __declspec(dllexport) int
EventFun(char *tencent, int type, int subtype, char *source, char *subject, char *object, char *msg, char *rawmsg, char *backptr)
{
  //if (type >= 1 && type <= 4 && std::string(msg) == text) {
  //  Api_GroupInvitation(tencent, subject, (char *)mainGroup.c_str());
  //  return RET_DONE;
  //}
  return RET_PASS;
}

