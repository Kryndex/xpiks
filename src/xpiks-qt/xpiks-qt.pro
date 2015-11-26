TEMPLATE = app

QMAKE_MAC_SDK = macosx10.11

QT += qml quick widgets concurrent

SOURCES += main.cpp \
    Models/artitemsmodel.cpp \
    Models/artworkmetadata.cpp \
    Helpers/globalimageprovider.cpp \
    Models/artworksrepository.cpp \
    Models/combinedartworksmodel.cpp \
    Helpers/indiceshelper.cpp \
    Models/iptcprovider.cpp \
    Models/artworkuploader.cpp \
    Models/artworksprocessor.cpp \
    Models/uploadinforepository.cpp \
    Helpers/tempmetadatadb.cpp \
    Models/warningsmanager.cpp \
    ../tiny-aes/aes.cpp \
    Encryption/secretsmanager.cpp \
    Helpers/stringhelper.cpp \
    Commands/commandmanager.cpp \
    UndoRedo/undoredomanager.cpp \
    Commands/addartworkscommand.cpp \
    UndoRedo/addartworksitem.cpp \
    Commands/removeartworkscommand.cpp \
    UndoRedo/removeartworksitem.cpp \
    UndoRedo/artworkmetadatabackup.cpp \
    UndoRedo/modifyartworkshistoryitem.cpp \
    Commands/combinededitcommand.cpp \
    Commands/pastekeywordscommand.cpp \
    Helpers/uploadworker.cpp \
    Helpers/uploadcoordinator.cpp \
    Helpers/runguard.cpp \
    Encryption/aes-qt.cpp \
    Models/ziparchiver.cpp \
    Helpers/ziphelper.cpp \
    ../quazip/quazip/JlCompress.cpp \
    ../quazip/quazip/qioapi.cpp \
    ../quazip/quazip/quaadler32.cpp \
    ../quazip/quazip/quacrc32.cpp \
    ../quazip/quazip/quagzipfile.cpp \
    ../quazip/quazip/quaziodevice.cpp \
    ../quazip/quazip/quazip.cpp \
    ../quazip/quazip/quazipdir.cpp \
    ../quazip/quazip/quazipfile.cpp \
    ../quazip/quazip/quazipfileinfo.cpp \
    ../quazip/quazip/quazipnewinfo.cpp \
    ../quazip/quazip/unzip.c \
    ../quazip/quazip/zip.c \
    Suggestion/keywordssuggestor.cpp \
    Suggestion/suggestionqueryengine.cpp \
    Models/settingsmodel.cpp \
    Helpers/curlwrapper.cpp \
    Helpers/loggingworker.cpp \
    Helpers/logger.cpp \
    Models/logsmodel.cpp \
    Helpers/exiftoolwrapper.cpp \
    Models/filteredartitemsproxymodel.cpp \
    Helpers/filenameshelpers.cpp \
    Common/flags.cpp \
    Helpers/keywordvalidator.cpp \
    Helpers/helpersqmlwrapper.cpp \
    Models/recentdirectoriesmodel.cpp \
    Suggestion/locallibrary.cpp \
    Suggestion/libraryqueryworker.cpp \
    Suggestion/libraryloaderworker.cpp \
    Helpers/updateservice.cpp \
    SpellCheck/spellcheckerservice.cpp \
    SpellCheck/spellcheckitem.cpp \
    SpellCheck/spellcheckworker.cpp \
    SpellCheck/spellchecksuggestionmodel.cpp \
    SpellCheck/keywordspellsuggestions.cpp \
    Common/basickeywordsmodel.cpp \
    SpellCheck/spellcheckerrorshighlighter.cpp \
    SpellCheck/spellcheckiteminfo.cpp

RESOURCES += qml.qrc

BUILDNO = $$system(git log -n 1 --pretty=format:"%H")
DEFINES += BUILDNUMBER=$${BUILDNO}
DEFINES += QT_NO_CAST_TO_ASCII \
           QT_NO_CAST_FROM_BYTEARRAY
DEFINES += QUAZIP_STATICx

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

ICON = xpiks-qt.icns

RC_ICONS = xpiks-qt.ico

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    Models/artitemsmodel.h \
    Models/artworkmetadata.h \
    Helpers/globalimageprovider.h \
    Models/artworksrepository.h \
    Helpers/indiceshelper.h \
    Helpers/clipboardhelper.h \
    Models/combinedartworksmodel.h \
    Models/artiteminfo.h \
    Models/abstractlistmodel.h \
    Helpers/constants.h \
    Helpers/appsettings.h \
    Models/iptcprovider.h \
    Helpers/exiftoolwrapper.h \
    Models/artworkuploader.h \
    Helpers/curlwrapper.h \
    Models/artworksprocessor.h \
    Models/uploadinfo.h \
    Models/exportinfo.h \
    Models/uploadinforepository.h \
    Models/logsmodel.h \
    Helpers/tempmetadatadb.h \
    Models/warningsinfo.h \
    Models/warningsmanager.h \
    Encryption/aes-qt.h \
    ../tiny-aes/aes.h \
    Encryption/secretsmanager.h \
    Helpers/uploaditem.h \
    Helpers/stringhelper.h \
    Helpers/logger.h \
    Helpers/testconnectionresult.h \
    Commands/commandmanager.h \
    UndoRedo/historyitem.h \
    UndoRedo/undoredomanager.h \
    UndoRedo/addartworksitem.h \
    Commands/commandbase.h \
    Commands/addartworkscommand.h \
    Common/baseentity.h \
    Commands/removeartworkscommand.h \
    UndoRedo/removeartworksitem.h \
    UndoRedo/artworkmetadatabackup.h \
    UndoRedo/modifyartworkshistoryitem.h \
    Commands/combinededitcommand.h \
    Commands/pastekeywordscommand.h \
    Helpers/uploadworker.h \
    Helpers/uploadcoordinator.h \
    Helpers/runguard.h \
    Models/ziparchiver.h \
    Helpers/ziphelper.h \
    ../quazip/quazip/crypt.h \
    ../quazip/quazip/ioapi.h \
    ../quazip/quazip/JlCompress.h \
    ../quazip/quazip/quaadler32.h \
    ../quazip/quazip/quachecksum32.h \
    ../quazip/quazip/quacrc32.h \
    ../quazip/quazip/quagzipfile.h \
    ../quazip/quazip/quaziodevice.h \
    ../quazip/quazip/quazip_global.h \
    ../quazip/quazip/quazip.h \
    ../quazip/quazip/quazipdir.h \
    ../quazip/quazip/quazipfile.h \
    ../quazip/quazip/quazipfileinfo.h \
    ../quazip/quazip/quazipnewinfo.h \
    ../quazip/quazip/unzip.h \
    ../quazip/quazip/zip.h \
    Common/basickeywordsmodel.h \
    Suggestion/keywordssuggestor.h \
    Suggestion/suggestionartwork.h \
    Suggestion/suggestionqueryengine.h \
    Models/settingsmodel.h \
    Helpers/loggingworker.h \
    Common/defines.h \
    Models/filteredartitemsproxymodel.h \
    Helpers/filenameshelpers.h \
    Common/flags.h \
    Helpers/keywordvalidator.h \
    Helpers/helpersqmlwrapper.h \
    Models/recentdirectoriesmodel.h \
    Helpers/settingsprovider.h \
    Common/version.h \
    Suggestion/locallibrary.h \
    Suggestion/libraryqueryworker.h \
    Suggestion/libraryloaderworker.h \
    Helpers/updateservice.h \
    SpellCheck/spellcheckerservice.h \
    SpellCheck/spellcheckitem.h \
    SpellCheck/spellcheckworker.h \
    SpellCheck/spellchecksuggestionmodel.h \
    SpellCheck/keywordspellsuggestions.h \
    SpellCheck/ispellcheckable.h \
    SpellCheck/spellcheckerrorshighlighter.h \
    SpellCheck/spellcheckiteminfo.h

DISTFILES += \
    Components/CloseIcon.qml \
    Components/EditableTags.qml \
    Components/LargeRemoveIcon.qml \
    Constants/Colors.js \
    StyledControls/SimpleProgressBar.qml \
    StyledControls/StyledButton.qml \
    StyledControls/StyledCheckbox.qml \
    StyledControls/StyledScrollView.qml \
    StyledControls/StyledText.qml \
    StyledControls/StyledTextInput.qml \
    Dialogs/CombinedArtworksDialog.qml \
    Dialogs/ExportMetadata.qml \
    Dialogs/ImportMetadata.qml \
    Dialogs/SettingsWindow.qml \
    Dialogs/UploadArtworks.qml \
    Dialogs/LogsDialog.qml \
    StyledControls/StyledTextEdit.qml \
    Dialogs/WarningsDialog.qml \
    xpiks-qt.ico \
    Dialogs/AboutWindow.qml \
    StyledControls/StyledAddHostButton.qml \
    StyledControls/StyledInputHost.qml \
    Dialogs/EnterMasterPasswordDialog.qml \
    Dialogs/MasterPasswordSetupDialog.qml \
    Components/CheckedComponent.qml \
    Dialogs/ZipArtworksDialog.qml \
    Components/AddIcon.qml \
    Dialogs/KeywordsSuggestion.qml \
    Components/LargeAddIcon.qml \
    StyledControls/StyledBusyIndicator.qml \
    StyledControls/StyledTabView.qml \
    Components/CustomBorder.qml \
    Dialogs/ArtworkPreview.qml \
    StyledControls/StyledBlackButton.qml \
    StyledControls/StyledSlider.qml \
    Components/KeywordWrapper.qml \
    Components/CustomScrollbar.qml \
    Dialogs/EditArtworkVerticalDialog.qml \
    Dialogs/EditArtworkHorizontalDialog.qml \
    Dialogs/UpdateWindow.qml \
    Dialogs/SpellCheckDialog.qml \
    Dialogs/SpellCheckSuggestionsDialog.qml \
    Components/SuggestionWrapper.qml

macx {
OBJECTIVE_SOURCES += \
    Helpers/osxnsurlhelper.mm

LIBS += -framework Foundation
LIBS += -lz
HEADERS += Helpers/osxnsurlhelper.h
}

LIBS += -L$$PWD/../libs/
INCLUDEPATH += "..\hunspell-1.3.3\src\hunspell"

LIBS += -lhunspell
DEFINES += HUNSPELL_STATIC

win32 {
INCLUDEPATH += "../zlib-1.2.8"
LIBS += -lz
DEFINES += QUAZIP_BUILD
}

linux-g++-64 {
target.path=/usr/bin/
LIBS += -L/lib/x86_64-linux-gnu/ -lz
QML_IMPORT_PATH += /usr/lib/x86_64-linux-gnu/qt5/imports/
}


linux-static {
CONFIG += static
QTPLUGIN += qt5quick
DEFINES += STATIC
message("Static build.")
}

HUNSPELL_DICT_FILES.files = dict/en_US.aff dict/en_US.dic
HUNSPELL_DICT_FILES.path = Contents/Resources
QMAKE_BUNDLE_DATA += HUNSPELL_DICT_FILES