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

#include <QFile>
#include <QDataStream>
#include <QThread>
#include <QDebug>
#include "locallibrary.h"
#include "../Models/artworkmetadata.h"
#include "libraryloaderworker.h"
#include "suggestionartwork.h"

namespace Suggestion {
    void LocalLibrary::addToLibrary(const QList<Models::ArtworkMetadata *> artworksList) {
        QMutexLocker locker(&m_Mutex);

        foreach (Models::ArtworkMetadata *metadata, artworksList) {
            const QString &filepath = metadata->getFilepath();
            const QStringList &keywords = metadata->getKeywords();
            // replaces if exists
            m_LocalArtworks.insert(filepath, keywords);
        }

        qDebug() << artworksList.length() << "artworks added to the local library";
    }

    void LocalLibrary::swap(QHash<QString, QStringList> &hash) {
        QMutexLocker locker(&m_Mutex);
        m_LocalArtworks.swap(hash);
        qDebug() << "Local library swapped with read from db.";
    }

    void LocalLibrary::saveToFile() {
        QFile file(m_Filename);
        if (file.open(QIODevice::WriteOnly)) {
            QDataStream out(&file);   // write the data

            m_Mutex.lock();
            {
                out << m_LocalArtworks;
            }
            m_Mutex.unlock();

            file.close();

            qDebug() << "Local library saved to" << m_Filename;
        }
    }

    void LocalLibrary::loadLibraryAsync() {
        LibraryLoaderWorker *worker = new LibraryLoaderWorker(this, m_Filename, LibraryLoaderWorker::Load);
        QThread *thread = new QThread();
        worker->moveToThread(thread);

        QObject::connect(thread, SIGNAL(started()), worker, SLOT(process()));
        QObject::connect(worker, SIGNAL(stopped()), thread, SLOT(quit()));

        QObject::connect(worker, SIGNAL(stopped()), worker, SLOT(deleteLater()));
        QObject::connect(thread, SIGNAL(finished()), thread, SLOT(deleteLater()));

        thread->start();
    }

    void LocalLibrary::saveLibraryAsync() {
        LibraryLoaderWorker *worker = new LibraryLoaderWorker(this, m_Filename, LibraryLoaderWorker::Save);
        QThread *thread = new QThread();
        worker->moveToThread(thread);

        QObject::connect(thread, SIGNAL(started()), worker, SLOT(process()));
        QObject::connect(worker, SIGNAL(stopped()), thread, SLOT(quit()));

        QObject::connect(worker, SIGNAL(stopped()), worker, SLOT(deleteLater()));
        QObject::connect(thread, SIGNAL(finished()), thread, SLOT(deleteLater()));

        thread->start();
    }

    void LocalLibrary::searchArtworks(const QStringList &query, QList<SuggestionArtwork*> &searchResults) {
        QMutexLocker locker(&m_Mutex);

        QHashIterator<QString, QStringList> i(m_LocalArtworks);

        while (i.hasNext()) {
            i.next();

            bool anyError = false;

            const QStringList &keywords = i.value();
            foreach (const QString &searchTerm, query) {
                bool containsTerm = false;

                foreach (const QString &keyword, keywords) {
                    if (keyword.contains(searchTerm, Qt::CaseInsensitive)) {
                        containsTerm = true;
                        break;
                    }
                }

                if (!containsTerm) {
                    anyError = true;
                    break;
                }
            }

            if (!anyError) {
                SuggestionArtwork *artwork = new SuggestionArtwork("file:///" + i.key(), keywords);
                searchResults.append(artwork);
            }
        }
    }
}
