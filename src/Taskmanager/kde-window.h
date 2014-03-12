#include <kwindowsystem.h>
#include <qlist.h>
#include <qpixmap.h>
#include <qstring.h>
void setWindowHints(WId id);
void setStrut(WId id, int left, int right, int top, int bottom);
QList<WId> getWindowList();
QString getWindowTitle(WId id);
QPixmap getWindowIcon(WId window);
QPixmap getWindowIcon(WId window, QSize size);
void switchToOrIconify(WId window);
void switchTo(WId window);
void iconify(WId window);
