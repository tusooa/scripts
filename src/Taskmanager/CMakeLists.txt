project (taskmanager)
 
find_package(KDE4 REQUIRED)
find_package(X11 REQUIRED)

include_directories(${KDE4_INCLUDES} ${X11_INCLUDE_DIR})
 
set(taskmanager_SRCS 
  main.cpp
  window.cpp
  hoverbutton.cpp
  kde-window.cpp
  app.cpp
)
 
kde4_add_executable(taskmanager ${taskmanager_SRCS})
target_link_libraries(taskmanager ${KDE4_KDEUI_LIBS} ${X11_X11_LIB})
install(TARGETS taskmanager DESTINATION ${BIN_INSTALL_DIR})
