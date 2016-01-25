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

#ifndef METADATAIOCOORDINATOR_H
#define METADATAIOCOORDINATOR_H

#include <QObject>
#include <QVector>
#include "../Common/baseentity.h"

namespace Models {
    class ArtworkMetadata;
}

namespace MetadataIO {
    class MetadataReadingWorker;
    class MetadataWritingWorker;

    class MetadataIOCoordinator : public QObject, public Common::BaseEntity
    {
        Q_OBJECT
        Q_PROPERTY(int processingItemsCount READ getProcessingItemsCount WRITE setProcessingItemsCount NOTIFY processingItemsCountChanged)
        Q_PROPERTY(bool hasErrors READ getHasErrors WRITE setHasErrors NOTIFY hasErrorsChanged)
    public:
        MetadataIOCoordinator();

    signals:
        void metadataReadingFinished();
        void metadataWritingFinished();
        void processingItemsCountChanged(int value);
        void discardReadingSignal();
        void hasErrorsChanged(bool value);

    private slots:
        void readingWorkerFinished(bool success);
        void writingWorkerFinished(bool success);

    public:
        int getProcessingItemsCount() const { return m_ProcessingItemsCount; }
        void setProcessingItemsCount(int value) {
            if (value != m_ProcessingItemsCount) {
                m_ProcessingItemsCount = value;
                emit processingItemsCountChanged(value);
            }
        }

        bool getHasErrors() const { return m_HasErrors; }
        void setHasErrors(bool value) {
            if (value != m_HasErrors) {
                m_HasErrors = value;
                emit hasErrorsChanged(value);
            }
        }

    public:
        void readMetadata(const QVector<Models::ArtworkMetadata*> &artworksToRead, const QVector<QPair<int, int> > &rangesToUpdate);
        void writeMetadata(const QVector<Models::ArtworkMetadata*> &artworksToWrite, bool useBackups);
        Q_INVOKABLE void discardReading();
        Q_INVOKABLE void readMetadata(bool ignoreBackups);

    private:
        void readingFinishedHandler(bool ignoreBackups);
        void afterImportHandler(const QVector<Models::ArtworkMetadata*> &itemsToRead, bool ignoreBackups);

    private:
        MetadataReadingWorker *m_ReadingWorker;
        MetadataWritingWorker *m_WritingWorker;
        int m_ProcessingItemsCount;
        volatile bool m_IsImportInProgress;
        volatile bool m_CanProcessResults;
        volatile bool m_IgnoreBackupsAtImport;
        volatile bool m_HasErrors;
    };
}

#endif // METADATAIOCOORDINATOR_H