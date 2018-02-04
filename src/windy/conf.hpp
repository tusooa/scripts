#ifndef CONF_HPP
#define CONF_HPP

#ifndef BOOST_SPIRIT_THREADSAFE
#define BOOST_SPIRIT_THREADSAFE
#endif
#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/ini_parser.hpp>

#include <string>
#include <fstream>
using namespace std;
using namespace boost::property_tree;

const char confFile[] = "windy.xx.conf";
class Conf
{
  ptree ini;
public:
  int recvPort;
  string apiCallAddr;
  string sendServer;
  string testAddr;
  string sendAddr;
  int testSleepTime;
  Conf() : recvPort(7456), apiCallAddr("/api/call"), sendServer("localhost:7457"), testAddr("/"), sendAddr("/recv"), testSleepTime(5)
  {
    try {
      read_ini(confFile, ini);
    } catch (...) {
      return;
    }
    recvPort = ini.get("windy.recvPort", recvPort);
    apiCallAddr = ini.get("windy.apiCallAddr", apiCallAddr);
    sendServer = ini.get("windy.sendServer", sendServer);
    testAddr = ini.get("windy.testAddr", testAddr);
    sendAddr = ini.get("windy.sendAddr", sendAddr);
    testSleepTime = ini.get("windy.testSleepTime", testSleepTime);
  }
};

#endif // CONF_HPP
