TEMPLATE = app

QT += qml quick
CONFIG += qmltestcase plugin c++11
TARGET = xpiks-tests-ui

DEFINES += QML_IMPORT_TRACE
DEFINES += QT_DEBUG_PLUGINS

SOURCES += main.cpp \
    ../../xpiks-qt/QMLExtensions/triangleelement.cpp

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = "$$PWD/UiTestsStubPlugin"

# Default rules for deployment.
include(deployment.pri)

DISTFILES += \
    ../../xpiks-qt/Components/EditableTags.qml \
    tst_EditableTags.qml \
    FakeColors.qml \
    ../../xpiks-qt/StackViews/CombinedEditView.qml \
    tst_CombinedEditView.qml

HEADERS += \
    ../../xpiks-qt/Helpers/clipboardhelper.h \
    ../../xpiks-qt/QMLExtensions/triangleelement.h

RESOURCES += \
    xpiks-tests-ui.qrc

copyplugins.commands = $$QMAKE_COPY_DIR "$$PWD/UiTestsStubPlugin/" "$$OUT_PWD/"
QMAKE_EXTRA_TARGETS += copyplugins
POST_TARGETDEPS += copyplugins
