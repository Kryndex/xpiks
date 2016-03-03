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

#include "backupsaverservice.h"
#include <QThread>
#include <QDebug>
#include "backupsaverworker.h"
#include "../Models/artworkmetadata.h"
#include "saverworkerjobitem.h"

namespace MetadataIO {
    BackupSaverService::BackupSaverService():
        QObject()
    {
        m_BackupWorker = new BackupSaverWorker();
    }

    void BackupSaverService::startSaving() {
        Q_ASSERT(!m_BackupWorker->isRunning());
        qDebug() << "BackupSaverService::startSaving #";

        QThread *thread = new QThread();
        m_BackupWorker->moveToThread(thread);

        QObject::connect(thread, SIGNAL(started()), m_BackupWorker, SLOT(process()));
        QObject::connect(m_BackupWorker, SIGNAL(stopped()), thread, SLOT(quit()));

        QObject::connect(m_BackupWorker, SIGNAL(stopped()), m_BackupWorker, SLOT(deleteLater()));
        QObject::connect(thread, SIGNAL(finished()), thread, SLOT(deleteLater()));

        QObject::connect(this, SIGNAL(cancelSaving()),
                         m_BackupWorker, SLOT(cancel()));

        QObject::connect(m_BackupWorker, SIGNAL(stopped()),
                         this, SLOT(workerFinished()));

        thread->start();
    }

    void BackupSaverService::saveArtwork(Models::ArtworkMetadata *metadata) const {
        SaverWorkerJobItem *jobItem = new SaverWorkerJobItem(metadata, JobTypeWrite);
        m_BackupWorker->submitItem(jobItem);
    }

    void BackupSaverService::readArtwork(Models::ArtworkMetadata *metadata) const {
        SaverWorkerJobItem *jobItem = new SaverWorkerJobItem(metadata, JobTypeRead);
        m_BackupWorker->submitItem(jobItem);
    }

    void BackupSaverService::readArtworks(const QVector<Models::ArtworkMetadata *> &artworks) const {
        qDebug() << "BackupSaverService::readArtworks #" << artworks.size() << "artwork(s)";
        QVector<SaverWorkerJobItem *> jobs;
        jobs.reserve(artworks.length());

        int size = artworks.size();
        for (int i = 0; i < size; ++i) {
            jobs.append(new SaverWorkerJobItem(artworks.at(i), JobTypeRead));
        }

        m_BackupWorker->submitItems(jobs);
    }

    void BackupSaverService::workerFinished() {
        qInfo() << "BackupSaverService::workerFinished #";
    }

    void BackupSaverService::stopSaving() {
        qDebug() << "BackupSaverService::stopSaving #" << "stopping...";
        m_BackupWorker->stopWorking();
    }
}
