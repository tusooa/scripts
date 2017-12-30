cmake_minimum_required (VERSION 2.8.8)
project (Simple-Web-Server)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall")

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.8)
        message(FATAL_ERROR "GCC version >=4.8 required.")
    endif()
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 3.3)
        message(FATAL_ERROR "Clang version >=3.3 required.")
    endif()
elseif (MSVC14) #TODO: What about other MSVC versions?
else()
    message(WARNING "Your compiler (${CMAKE_CXX_COMPILER_ID}) has not been tested on this project. Only Clang and GCC has been tested. Please report any problems at the project page on GitHub.")
endif()


include_directories(. Simple-Web-Server port)

find_package(Threads REQUIRED)

set(Boost_USE_STATIC_LIBS 1)
#set(Boost_USE_STATIC_RUNTIME 1)
find_package(Boost 1.53.0 COMPONENTS regex system thread filesystem date_time REQUIRED)
include_directories(SYSTEM ${Boost_INCLUDE_DIR})

add_library(windy.xx windy.cpp)
target_link_libraries(windy.xx ${Boost_LIBRARIES})
target_link_libraries(windy.xx ${CMAKE_THREAD_LIBS_INIT})

if(MSYS) #TODO: Is MSYS true when MSVC is true?
    target_link_libraries(windy.xx ws2_32 wsock32)
endif()

