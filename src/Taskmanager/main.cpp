#include <kaboutdata.h>
#include "app.h"
#include "window.h"
#include <kcmdlineargs.h>

int main (int argc, char *argv[])
{
  KAboutData about ("taskmanager", 0, ki18n ("Task Manager"), "0.1",
                    ki18n ("A tool like Unity to manage tasks"), KAboutData::License_GPL,
                    ki18n (""), ki18n ("(to do)"), "", "tusooa@gmail.com");
  KCmdLineArgs::init (argc, argv, &about);
  App app;
  TaskWin *window = new TaskWin ();
  window->show ();
  return app.exec ();
}
