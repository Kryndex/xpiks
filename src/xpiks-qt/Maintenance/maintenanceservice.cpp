/*
 * This file is a part of Xpiks - cross platform application for
 * keywording and uploading images for microstocks
 * Copyright (C) 2014-2017 Taras Kushnir <kushnirTV@gmail.com>
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

#include <QThread>
#include "../Common/defines.h"
#include "maintenanceservice.h"
#include "maintenanceworker.h"
#include "logscleanupjobitem.h"
#include "updatescleanupjobitem.h"
#include "launchexiftooljobitem.h"
#include "initializedictionariesjobitem.h"
#include "addtolibraryjobitem.h"
#include "locallibraryloadsaveitem.h"
#include "movesettingsjobitem.h"

namespace Maintenance {
    MaintenanceService::MaintenanceService():
        m_MaintenanceWorker(NULL)
    {
    }

    void MaintenanceService::startService() {
        LOG_DEBUG << "#";

        if (m_MaintenanceWorker != NULL) {
            LOG_WARNING << "Attempt to start running worker";
            return;
        }

        m_MaintenanceWorker = new MaintenanceWorker();

        QThread *thread = new QThread();
        m_MaintenanceWorker->moveToThread(thread);

        QObject::connect(thread, SIGNAL(started()), m_MaintenanceWorker, SLOT(process()));
        QObject::connect(m_MaintenanceWorker, SIGNAL(stopped()), thread, SLOT(quit()));

        QObject::connect(m_MaintenanceWorker, SIGNAL(stopped()), m_MaintenanceWorker, SLOT(deleteLater()));
        QObject::connect(thread, SIGNAL(finished()), thread, SLOT(deleteLater()));

        QObject::connect(m_MaintenanceWorker, SIGNAL(stopped()),
                         this, SLOT(workerFinished()));
        QObject::connect(m_MaintenanceWorker, SIGNAL(destroyed(QObject *)),
                         this, SLOT(workerDestroyed(QObject *)));

        LOG_DEBUG << "starting low priority thread...";
        thread->start(QThread::LowPriority);
    }

    void MaintenanceService::stopService() {
        LOG_DEBUG << "#";
        if (m_MaintenanceWorker != NULL) {
            m_MaintenanceWorker->stopWorking();
        } else {
            LOG_WARNING << "MaintenanceWorker is NULL";
        }
    }

    void MaintenanceService::cleanupUpdatesArtifacts() {
#ifdef Q_OS_WIN
        LOG_DEBUG << "#";
        std::shared_ptr<IMaintenanceItem> jobItem(new UpdatesCleanupJobItem());
        m_MaintenanceWorker->submitItem(jobItem);
#endif
    }

    void MaintenanceService::launchExiftool(const QString &settingsExiftoolPath, MetadataIO::MetadataIOCoordinator *coordinator) {
        LOG_DEBUG << "#";
        std::shared_ptr<IMaintenanceItem> jobItem(new LaunchExiftoolJobItem(settingsExiftoolPath, coordinator));
        m_MaintenanceWorker->submitItem(jobItem);
    }

    void MaintenanceService::initializeDictionaries(Translation::TranslationManager *translationManager) {
        LOG_DEBUG << "#";
        std::shared_ptr<IMaintenanceItem> jobItem(new InitializeDictionariesJobItem(translationManager));
        m_MaintenanceWorker->submitFirst(jobItem);
    }

    void MaintenanceService::addArtworksToLibrary(const QVector<Models::ArtworkMetadata *> artworksList, Suggestion::LocalLibrary *localLibrary) {
        LOG_DEBUG << "#";
        std::shared_ptr<IMaintenanceItem> jobItem(new AddToLibraryJobItem(artworksList, localLibrary));
        m_MaintenanceWorker->submitFirst(jobItem);
    }

    void MaintenanceService::cleanupLogs() {
#ifdef WITH_LOGS
        LOG_DEBUG << "#";
        std::shared_ptr<IMaintenanceItem> jobItem(new LogsCleanupJobItem());
        m_MaintenanceWorker->submitItem(jobItem);
#endif
    }

    void MaintenanceService::loadLocalLibrary(Suggestion::LocalLibrary *localLibrary) {
        std::shared_ptr<IMaintenanceItem> jobItem(new LocalLibraryLoadSaveItem(localLibrary, LocalLibraryLoadSaveItem::Load));
        m_MaintenanceWorker->submitFirst(jobItem);
    }

    void MaintenanceService::saveLocalLibrary(Suggestion::LocalLibrary *localLibrary) {
        std::shared_ptr<IMaintenanceItem> jobItem(new LocalLibraryLoadSaveItem(localLibrary, LocalLibraryLoadSaveItem::Save));
        m_MaintenanceWorker->submitFirst(jobItem);
    }

    void MaintenanceService::cleanupLocalLibrary(Suggestion::LocalLibrary *localLibrary) {
        std::shared_ptr<IMaintenanceItem> jobItem(new LocalLibraryLoadSaveItem(localLibrary, LocalLibraryLoadSaveItem::Clean));
        m_MaintenanceWorker->submitFirst(jobItem);
    }

    void MaintenanceService::moveSettings(Models::SettingsModel *settingsModel) {
        std::shared_ptr<IMaintenanceItem> jobItem(new MoveSettingsJobItem(settingsModel));
        m_MaintenanceWorker->submitFirst(jobItem);
    }

    void MaintenanceService::workerFinished() {
        LOG_DEBUG << "#";
    }

    void MaintenanceService::workerDestroyed(QObject *object) {
        Q_UNUSED(object);
        LOG_DEBUG << "#";
        m_MaintenanceWorker = NULL;
    }
}
