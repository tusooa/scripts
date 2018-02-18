#include <fstream>
#include <string>

//#define debug(s) 

void debug(std::string string)
{
  std::ofstream of("windy.debug.txt", std::ios_base::app);
  of << string << std::endl;
  of.close();
}
