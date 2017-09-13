#include <QtQuickTest/quicktest.h>
#include <QtQml>
#include <QDir>
#include <QDebug>
#include <QQmlEngine>
#include "../../xpiks-qt/Helpers/clipboardhelper.h"
#include "../../xpiks-qt/QMLExtensions/triangleelement.h"
#include "../ui-tests-plugin/ui-tests-stubs/ui-tests-stubs_plugin.h"

#define STRINGIZE_(x) #x
#define STRINGIZE(x) STRINGIZE_(x)

int main(int argc, char **argv) {
    qmlRegisterType<Helpers::ClipboardHelper>("xpiks", 1, 0, "ClipboardHelper");
    qmlRegisterType<QMLExtensions::TriangleElement>("xpiks", 1, 0, "TriangleElement");

    return quick_test_main(argc, argv, "xpiks_tests_ui", QUICK_TEST_SOURCE_DIR);
}
