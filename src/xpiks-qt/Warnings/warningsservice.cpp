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

#include "warningsservice.h"
#include <QVector>
#include "../Common/defines.h"
#include "warningscheckingworker.h"
#include "../Commands/commandmanager.h"
#include "warningsitem.h"

namespace Warnings {
    WarningsService::WarningsService(QObject *parent) :
        QObject(parent),
        m_WarningsWorker(NULL)
    {
    }

    void WarningsService::startService() {
        m_WarningsWorker = new WarningsCheckingWorker(m_CommandManager->getSettingsModel());

        QThread *thread = new QThread();
        m_WarningsWorker->moveToThread(thread);

        QObject::connect(thread, SIGNAL(started()), m_WarningsWorker, SLOT(process()));
        QObject::connect(m_WarningsWorker, SIGNAL(stopped()), thread, SLOT(quit()));

        QObject::connect(m_WarningsWorker, SIGNAL(stopped()), m_WarningsWorker, SLOT(deleteLater()));
        QObject::connect(thread, SIGNAL(finished()), thread, SLOT(deleteLater()));

        QObject::connect(m_WarningsWorker, SIGNAL(destroyed(QObject*)),
                         this, SLOT(workerDestoyed(QObject*)));

        QObject::connect(m_WarningsWorker, SIGNAL(stopped()),
                         this, SLOT(workerStopped()));

        LOG_INFO << "Starting worker";

        thread->start();
    }

    void WarningsService::stopService() {
        if (m_WarningsWorker != NULL) {
            LOG_INFO << "Stopping worker";
            m_WarningsWorker->stopWorking();
        } else {
            LOG_WARNING << "Worker was destroyed";
        }
    }

    void WarningsService::submitItem(IWarningsCheckable *item) {
        if (m_WarningsWorker == NULL) { return; }

        item->acquire();

        WarningsItem *wItem = new WarningsItem(item);
        m_WarningsWorker->submitItem(wItem);
    }

    void WarningsService::submitItem(IWarningsCheckable *item, int flags) {
        if (m_WarningsWorker == NULL) { return; }

        item->acquire();

        WarningsItem *wItem = new WarningsItem(item, flags);
        m_WarningsWorker->submitItem(wItem);
    }

    void WarningsService::submitItems(const QVector<IWarningsCheckable *> &items) {
        if (m_WarningsWorker == NULL) { return; }

        int length = items.length();

        QVector<WarningsItem*> itemsToSubmit;
        itemsToSubmit.reserve(length);

        for (int i = 0; i < length; ++i) {
            IWarningsCheckable *item = items.at(i);
            item->acquire();
            WarningsItem *itemToSubmit = new WarningsItem(item);
            itemsToSubmit.append(itemToSubmit);
        }

        LOG_INFO << "Submitting" << length << "items";
        m_WarningsWorker->submitItems(itemsToSubmit);
    }

    void WarningsService::workerDestoyed(QObject *object) {
        Q_UNUSED(object);
        LOG_DEBUG << "#";
        m_WarningsWorker = NULL;
    }

    void WarningsService::workerStopped() {
        LOG_DEBUG << "#";
    }
}