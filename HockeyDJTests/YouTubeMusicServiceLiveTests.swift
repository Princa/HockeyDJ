import XCTest
@testable import HockeyDJ

final class YouTubeMusicServiceLiveTests: XCTestCase {
    func testImportSingleVideoFromYouTubeAPI() async throws {
        guard Config.isYouTubeMusicEnabled else {
            XCTFail("YouTube API key must be configured for this live integration test.")
            return
        }

        let service = YouTubeMusicService()
        let url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

        let songs = try await service.importPlaylist(url: url)

        XCTAssertFalse(songs.isEmpty, "Expected at least one song from YouTube API.")

        guard let first = songs.first else {
            XCTFail("Expected first song after successful import.")
            return
        }

        XCTAssertEqual(first.youtubeId, "dQw4w9WgXcQ")
        XCTAssertFalse(first.title.isEmpty)
        XCTAssertFalse(first.artist.isEmpty)
        XCTAssertGreaterThan(first.duration, 0)
    }
}
