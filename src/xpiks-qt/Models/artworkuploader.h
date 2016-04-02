/*
 * This file is a part of Xpiks - cross platform application for
 * keywording and uploading images for microstocks
 * Copyright (C) 2014-2016 Taras Kushnir <kushnirTV@gmail.com>
 *
 * Xpiks is distributed under the GNU General Public License, version 3.0
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef ARTWORKUPLOADER_H
#define ARTWORKUPLOADER_H

#include <QAbstractListModel>
#include <QStringList>
#include <QMap>
#include <QFutureWatcher>
#include "artworksprocessor.h"
#include "../Conectivity/testconnection.h"

namespace Helpers {
    class TestConnectionResult;
}

namespace Conectivity {
    class IFtpCoordinator;
}

namespace Commands {
    class CommandManager;
}

namespace Models {
    class ArtworkMetadata;

    class ArtworkUploader : public ArtworksProcessor
    {
        Q_OBJECT
    public:
        ArtworkUploader(Conectivity::IFtpCoordinator *ftpCoordinator, QObject *parent=0);
        virtual ~ArtworkUploader();

    public:
        virtual void setCommandManager(Commands::CommandManager *commandManager);

    signals:
        void percentChanged();
        void credentialsChecked(bool result, const QString &url);

    public:
        int getPercent() const { return m_Percent; }

    public slots:
        void onUploadStarted();
        void allFinished(bool anyError);
        void credentialsTestingFinished();

    private slots:
        void uploaderPercentChanged(double percent);

    public:
#ifndef TESTS
        Q_INVOKABLE void uploadArtworks();
        Q_INVOKABLE void checkCredentials(const QString &host, const QString &username,
                                          const QString &password, bool disablePassiveMode) const;
#endif
        Q_INVOKABLE bool needCreateArchives() const;

    private:
#ifndef TESTS
        void doUploadArtworks(const QVector<ArtworkMetadata*> &artworkList);
#endif

    protected:
        virtual void cancelProcessing();
        virtual void innerResetModel() { m_Percent = 0; }

    private:
        Conectivity::IFtpCoordinator *m_FtpCoordinator;
#ifndef TESTS
        QFutureWatcher<Conectivity::ContextValidationResult> *m_TestingCredentialWatcher;
#endif
        int m_Percent;
    };
}

#endif // ARTWORKUPLOADER_H
