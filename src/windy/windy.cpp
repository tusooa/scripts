#include "server_http.hpp"
#include "client_http.hpp"

//Added for the json-example
#define BOOST_SPIRIT_THREADSAFE
#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>

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

int main() {
    //HTTP-server at port 8080 using 1 thread
    //Unless you do more heavy non-threaded processing in the resources,
    //1 thread is usually faster than several threads
    HttpServer server(RECV_PORT, 1);
    
    //POST-example for the path /json, responds firstName+" "+lastName from the posted json
    //Responds with an appropriate error message if the posted json is not valid, or if firstName or lastName is missing
    //Example posted json:
    //{
    //  "firstName": "John",
    //  "lastName": "Smith",
    //  "age": 25
    //}
    server.resource["^/api/call$"]["POST"]=[](shared_ptr<HttpServer::Response> response, shared_ptr<HttpServer::Request> request) {
        try {
            ptree pt;
            read_json(request->content, pt);

            string name=pt.get<string>("func")+"("+pt.get<string>("arg")+")";

            *response << "HTTP/1.1 200 OK\r\n"
                      << "Content-Type: application/json\r\n"
                      << "Content-Length: " << name.length() << "\r\n\r\n"
                      << name;
        }
        catch(exception& e) {
            *response << "HTTP/1.1 400 Bad Request\r\nContent-Length: " << strlen(e.what()) << "\r\n\r\n" << e.what();
        }
    };

    /*    //GET-example for the path /match/[number], responds with the matched string in path (number)
    //For instance a request GET /match/123 will receive: 123
    server.resource["^/match/([0-9]+)$"]["GET"]=[&server](shared_ptr<HttpServer::Response> response, shared_ptr<HttpServer::Request> request) {
        string number=request->path_match[1];
        *response << "HTTP/1.1 200 OK\r\nContent-Length: " << number.length() << "\r\n\r\n" << number;
    };
    
    //Get example simulating heavy work in a separate thread
    server.resource["^/work$"]["GET"]=[&server](shared_ptr<HttpServer::Response> response, shared_ptr<HttpServer::Request> request) {
        thread work_thread([response] {
            this_thread::sleep_for(chrono::seconds(5));
            string message="Work done";
            *response << "HTTP/1.1 200 OK\r\nContent-Length: " << message.length() << "\r\n\r\n" << message;
        });
        work_thread.detach();
    };*/
    
    //Default GET-example. If no other matches, this anonymous function will be called. 
    //Will respond with content in the web/-directory, and its subdirectories.
    //Default file: index.html
    //Can for instance be used to retrieve an HTML 5 client that uses REST-resources on this server
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
    server_thread.join();
    
    return 0;
}
/*
void default_resource_send(const HttpServer &server, shared_ptr<HttpServer::Response> response,
                           shared_ptr<ifstream> ifs, shared_ptr<vector<char> > buffer) {
    streamsize read_length;
    if((read_length=ifs->read(&(*buffer)[0], buffer->size()).gcount())>0) {
        response->write(&(*buffer)[0], read_length);
        if(read_length==static_cast<streamsize>(buffer->size())) {
            server.send(response, [&server, response, ifs, buffer](const boost::system::error_code &ec) {
                if(!ec)
                    default_resource_send(server, response, ifs, buffer);
                else
                    cerr << "Connection interrupted" << endl;
            });
        }
    }
}
*/
