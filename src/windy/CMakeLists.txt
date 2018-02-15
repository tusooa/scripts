# keep CMake quiet about developer warning
cmake_minimum_required (VERSION 2.8.8)
# we need static build with STATIC RUNTIME
set(CMAKE_USER_MAKE_RULES_OVERRIDE_CXX
  ${CMAKE_CURRENT_SOURCE_DIR}/cxx_flags_override.cmake)
project (windy)
# we love utf-8, but Visual Studio does not
if(MSVC)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -utf-8")
else()
  message(STATUS "Compilers other than MSVC are not tested and therefore not gauranteed to work.")
endif()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

include_directories(.
  Simple-Web-Server
  port
  json/single_include/nlohmann)

# we're gonna find Iconv
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")

find_package(Threads REQUIRED)
find_package(Iconv REQUIRED)
# STATIC LIB with STATIC RUNTIME. yummy.
set(Boost_USE_STATIC_LIBS 1)
set(Boost_USE_STATIC_RUNTIME 1)
find_package(Boost 1.53.0 COMPONENTS regex system thread filesystem date_time REQUIRED)
include_directories(SYSTEM ${ICONV_INCLUDE_DIR} ${Boost_INCLUDE_DIR})

add_library(windy.xx SHARED windy.cpp)
target_link_libraries(windy.xx ${Boost_LIBRARIES})
target_link_libraries(windy.xx ${CMAKE_THREAD_LIBS_INIT})
target_link_libraries(windy.xx ${ICONV_LIBRARIES})

if(MSYS) #TODO: Is MSYS true when MSVC is true?
    target_link_libraries(windy.xx ws2_32 wsock32)
endif()

