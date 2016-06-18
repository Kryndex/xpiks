#include "artworkfilter_tests.h"
#include "Mocks/artworkmetadatamock.h"
#include "../../xpiks-qt/Helpers/filterhelpers.h"
#include "../../xpiks-qt/Common/flags.h"

void ArtworkFilterTests::searchImageVectorTest() {
    Mocks::ArtworkMetadataMock metadata("/path/to/file.jpg");
    QVERIFY(Helpers::containsPartsSearch("x:image", &metadata, false));
    QVERIFY(!Helpers::containsPartsSearch("x:vector", &metadata, false));

    metadata.attachVector("/path/to/file.eps");
    QVERIFY(!Helpers::containsPartsSearch("x:image", &metadata, false));
    QVERIFY(Helpers::containsPartsSearch("x:vector", &metadata, false));
}

void ArtworkFilterTests::searchByKeywordsTest() {
    Mocks::ArtworkMetadataMock metadata("/path/to/file.jpg");
    metadata.setKeywords(QStringList() << "keyword" << "another" << "test");
    QVERIFY(Helpers::containsPartsSearch("keyw TSTS", &metadata, false));
    QVERIFY(!Helpers::containsPartsSearch("!keyw", &metadata, false));
    QVERIFY(Helpers::containsPartsSearch("!keyword", &metadata, false));

    QVERIFY(Helpers::containsPartsSearch("keyword super", &metadata, false));
    QVERIFY(!Helpers::containsPartsSearch("keyword super", &metadata, true));
}

void ArtworkFilterTests::searchByTitleTest() {
    Mocks::ArtworkMetadataMock metadata("/path/to/file.jpg");
    metadata.setTitle("my long title here");
    QVERIFY(Helpers::containsPartsSearch("tit", &metadata, false));
    QVERIFY(!Helpers::containsPartsSearch("!tit", &metadata, false));
    // strict search works only for keywords
    QVERIFY(!Helpers::containsPartsSearch("!title", &metadata, false));

    QVERIFY(!Helpers::containsPartsSearch("keyword super", &metadata, false));
    QVERIFY(Helpers::containsPartsSearch("here my", &metadata, true));
}

void ArtworkFilterTests::searchByDescriptionTest() {
    Mocks::ArtworkMetadataMock metadata("/path/to/file.jpg");
    metadata.setDescription("my long desciption john");
    QVERIFY(Helpers::containsPartsSearch("o", &metadata, false));
    QVERIFY(!Helpers::containsPartsSearch("!o", &metadata, false));
    // strict search works only for keywords
    QVERIFY(!Helpers::containsPartsSearch("!description", &metadata, false));

    QVERIFY(!Helpers::containsPartsSearch("myjohn", &metadata, false));
    QVERIFY(!Helpers::containsPartsSearch("descriptionmy", &metadata, true));
}

void ArtworkFilterTests::strictSearchTest() {
    Mocks::ArtworkMetadataMock metadata("/path/to/file.jpg");
    metadata.setKeywords(QStringList() << "keyword" << "ano!ther" << "test" << "k");
    QVERIFY(Helpers::containsPartsSearch("keyw", &metadata, false));
    QVERIFY(!Helpers::containsPartsSearch("!keyw", &metadata, false));
    QVERIFY(Helpers::containsPartsSearch("!keyword", &metadata, false));

    QVERIFY(!Helpers::containsPartsSearch("!!", &metadata, false));
    QVERIFY(Helpers::containsPartsSearch("!k", &metadata, true));

    metadata.appendKeyword("!");
    QVERIFY(Helpers::containsPartsSearch("!", &metadata, false));
}

void ArtworkFilterTests::caseSensitiveKeywordSearchTest() {
    Mocks::ArtworkMetadataMock metadata("/path/to/file.jpg");
    metadata.setKeywords(QStringList() << "keYwOrd" << "keYword");

    int flags = Common::SearchFlagSearchKeywords | Common::SearchFlagCaseSensitive;

    QVERIFY(Helpers::hasSearchMatch("YwO", &metadata, flags));
    QVERIFY(!Helpers::hasSearchMatch("ywO", &metadata, flags));
}

void ArtworkFilterTests::cantFindWithFilterDescriptionTest() {
    Mocks::ArtworkMetadataMock metadata("/path/to/file.jpg");
    metadata.setDescription("token between here");
    metadata.setKeywords(QStringList() << "some keyword" << "another stuff");

    int flags = Common::SearchFlagSearchKeywords | Common::SearchFlagSearchTitle;

    QVERIFY(!Helpers::hasSearchMatch("between", &metadata, flags));
    QVERIFY(Helpers::hasSearchMatch("between", &metadata, flags | Common::SearchFlagSearchDescription));
}

void ArtworkFilterTests::cantFindWithFilterTitleTest() {
    Mocks::ArtworkMetadataMock metadata("/path/to/file.jpg");
    metadata.setTitle("token between here");
    metadata.setKeywords(QStringList() << "some keyword" << "another stuff");

    int flags = Common::SearchFlagSearchDescription | Common::SearchFlagSearchKeywords;

    QVERIFY(!Helpers::hasSearchMatch("between", &metadata, flags));
    QVERIFY(Helpers::hasSearchMatch("between", &metadata, flags | Common::SearchFlagSearchTitle));
}

void ArtworkFilterTests::cantFindWithFilterKeywordsTest() {
    Mocks::ArtworkMetadataMock metadata("/path/to/file.jpg");
    metadata.setDescription("another keyword in description");
    metadata.setTitle("token between here");
    metadata.setKeywords(QStringList() << "some keyword" << "another stuff");

    int flags = Common::SearchFlagSearchDescription | Common::SearchFlagSearchTitle;

    QVERIFY(!Helpers::hasSearchMatch("stuff", &metadata, flags));
    QVERIFY(Helpers::hasSearchMatch("stuff", &metadata, flags | Common::SearchFlagSearchKeywords));
}

void ArtworkFilterTests::cantFindWithFilterSpecialTest() {
    Mocks::ArtworkMetadataMock metadata("/path/to/file.jpg");
    metadata.setDescription("another keyword in description");
    metadata.setTitle("token between here");
    metadata.setKeywords(QStringList() << "some keyword" << "another stuff");

    int flags = Common::SearchFlagSearchDescription | Common::SearchFlagSearchTitle | Common::SearchFlagSearchKeywords;

    QVERIFY(!Helpers::hasSearchMatch("x:empty", &metadata, flags));
    QVERIFY(Helpers::hasSearchMatch("x:empty", &metadata, flags | Common::SearchFlagReservedTerms));
}
