/*
 * This file is a part of Xpiks - cross platform application for
 * keywording and uploading images for microstocks
 * Copyright (C) 2014-2015 Taras Kushnir <kushnirTV@gmail.com>
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
#include <QFutureWatcher>
#include "artworksprocessor.h"

namespace Helpers {
    class TestConnectionResult;
    class UploadCoordinator;
}

namespace Models {
    class ArtworkMetadata;

    class ArtworkUploader : public ArtworksProcessor
    {
        Q_OBJECT
    public:
         ArtworkUploader(int maxParallelUploads);
         virtual ~ArtworkUploader();

    public:
         Q_PROPERTY(bool includeVector READ getIncludeVector WRITE setIncludeVector NOTIFY includeVectorChanged)

    signals:
         void includeVectorChanged(bool);
         void credentialsChecked(bool result, const QString &url);

    public:
         bool getIncludeVector() const { return m_IncludeVector; }
         void setIncludeVector(bool value) {
             if (m_IncludeVector != value) {
                 m_IncludeVector = value;
                 emit includeVectorChanged(value);
             }
         }

         virtual int getPercent() const { return m_Percent; }


     public slots:
         void onUploadStarted();
         void artworkUploaded(bool status);
         void allFinished(bool status);
         void credentialsTestingFinished();

    private slots:
         void uploaderPercentChanged(double percent);

     private:
         void artworkUploadedHandler(bool success);

     public:
         Q_INVOKABLE void uploadArtworks();
         Q_INVOKABLE void checkCredentials(const QString &host, const QString &username, const QString &password) const;
         Q_INVOKABLE bool needCreateArchives() const;

     private:
         void doUploadArtworks(const QVector<ArtworkMetadata*> &artworkList);

    protected:
        void cancelProcessing();
        virtual void innerResetModel() { m_Percent = 0; }

     private:
         Helpers::UploadCoordinator *m_UploadCoordinator;
         QFutureWatcher<Helpers::TestConnectionResult> *m_TestingCredentialWatcher;
         bool m_IncludeVector;
         int m_Percent;
    };
}

#endif // ARTWORKUPLOADER_H