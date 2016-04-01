#ifndef ARTWORKSREPOSITORYMOCK_H
#define ARTWORKSREPOSITORYMOCK_H

#include <QVector>
#include <QPair>
#include "../xpiks-qt/Models/artworksrepository.h"

namespace Mocks {
    class ArtworksRepositoryMock : public Models::ArtworksRepository {
    public:
        ArtworksRepositoryMock() {}

        void publicRemoveFileAndEmitSignal() {
            Models::ArtworksRepository::removeFileAndEmitSignal();
        }

        void publicRemoveVectorAndEmitSignal() {
            Models::ArtworksRepository::removeVectorAndEmitSignal();
        }
    };
}
#endif // ARTWORKSREPOSITORYMOCK_H
