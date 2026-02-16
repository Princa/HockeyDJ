//
//  YouTubeMusicService.swift
//  HockeyDJ
//
//  Created on 2026-02-16
//

import Foundation

enum YouTubeMusicError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case parseError
    case apiKeyMissing
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid YouTube URL. Please check the URL and try again."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .parseError:
            return "Failed to parse YouTube data. Please try again."
        case .apiKeyMissing:
            return "YouTube API key is missing. Please configure the app settings."
        case .invalidResponse:
            return "Received an invalid response from YouTube API."
        }
    }
}

class YouTubeMusicService: ObservableObject {
    @Published var isLoading: Bool = false

    func importPlaylist(url: String) async throws -> [Song] {
        guard URL(string: url) != nil else {
            throw YouTubeMusicError.invalidURL
        }

        if Config.useSampleData {
            let playlistId = extractPlaylistId(from: url)
            let videoId = extractVideoId(from: url)

            if let playlistId {
                return createSampleSongs(count: 5, prefix: "Playlist \(playlistId.prefix(6)) Song")
            } else if let videoId {
                return createSampleSongs(count: 1, prefix: "Video", videoId: videoId)
            }

            throw YouTubeMusicError.invalidURL
        }

        guard Config.isYouTubeMusicEnabled else {
            throw YouTubeMusicError.apiKeyMissing
        }

        let playlistId = extractPlaylistId(from: url)
        let videoId = extractVideoId(from: url)

        if let playlistId {
            return try await fetchPlaylistSongs(playlistId: playlistId)
        } else if let videoId {
            return try await fetchSingleVideo(videoId: videoId)
        }

        throw YouTubeMusicError.invalidURL
    }

    private func extractPlaylistId(from url: String) -> String? {
        guard let urlComponents = URLComponents(string: url),
              let queryItems = urlComponents.queryItems,
              let listParam = queryItems.first(where: { $0.name == "list" }),
              let playlistId = listParam.value,
              !playlistId.isEmpty else {
            return nil
        }

        return playlistId
    }

    private func extractVideoId(from url: String) -> String? {
        if url.contains("youtu.be/") {
            return url
                .components(separatedBy: "youtu.be/")
                .last?
                .components(separatedBy: "?")
                .first
        }

        guard url.contains("youtube.com") || url.contains("music.youtube.com") else {
            return nil
        }

        guard let urlComponents = URLComponents(string: url),
              let queryItems = urlComponents.queryItems,
              let vParam = queryItems.first(where: { $0.name == "v" }),
              let videoId = vParam.value,
              !videoId.isEmpty else {
            return nil
        }

        return videoId
    }

    private func fetchPlaylistSongs(playlistId: String) async throws -> [Song] {
        let videoIds = try await fetchPlaylistVideoIds(playlistId: playlistId)

        guard !videoIds.isEmpty else {
            return []
        }

        return try await fetchSongsFromVideoIds(videoIds)
    }

    private func fetchSingleVideo(videoId: String) async throws -> [Song] {
        return try await fetchSongsFromVideoIds([videoId])
    }

    private func fetchPlaylistVideoIds(playlistId: String) async throws -> [String] {
        var nextPageToken: String?
        var videoIds: [String] = []

        repeat {
            var components = URLComponents(string: "\(Config.youtubeAPIBaseURL)/playlistItems")
            var queryItems: [URLQueryItem] = [
                URLQueryItem(name: "part", value: "contentDetails"),
                URLQueryItem(name: "maxResults", value: String(Config.maxYouTubeResults)),
                URLQueryItem(name: "playlistId", value: playlistId),
                URLQueryItem(name: "key", value: Config.youtubeAPIKey)
            ]

            if let nextPageToken {
                queryItems.append(URLQueryItem(name: "pageToken", value: nextPageToken))
            }

            components?.queryItems = queryItems

            guard let url = components?.url else {
                throw YouTubeMusicError.invalidURL
            }

            let response: PlaylistItemsResponse = try await performRequest(url: url)
            videoIds.append(contentsOf: response.items.map(\.contentDetails.videoId))
            nextPageToken = response.nextPageToken
        } while nextPageToken != nil

        return videoIds
    }

    private func fetchSongsFromVideoIds(_ videoIds: [String]) async throws -> [Song] {
        var songs: [Song] = []

        for (batchIndex, chunk) in videoIds.chunked(into: 50).enumerated() {
            var components = URLComponents(string: "\(Config.youtubeAPIBaseURL)/videos")
            components?.queryItems = [
                URLQueryItem(name: "part", value: "snippet,contentDetails"),
                URLQueryItem(name: "id", value: chunk.joined(separator: ",")),
                URLQueryItem(name: "key", value: Config.youtubeAPIKey)
            ]

            guard let url = components?.url else {
                throw YouTubeMusicError.invalidURL
            }

            let response: VideosResponse = try await performRequest(url: url)

            let mappedSongs = response.items.enumerated().map { itemIndex, item in
                Song(
                    title: item.snippet.title,
                    artist: item.snippet.channelTitle,
                    youtubeId: item.id,
                    thumbnailURL: item.snippet.thumbnails.best?.url,
                    duration: item.contentDetails.duration.timeInterval,
                    startTime: 0,
                    endTime: nil,
                    order: (batchIndex * 50) + itemIndex
                )
            }

            songs.append(contentsOf: mappedSongs)
        }

        return songs
    }

    private func performRequest<T: Decodable>(url: URL) async throws -> T {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                throw YouTubeMusicError.invalidResponse
            }

            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw YouTubeMusicError.parseError
            }
        } catch let error as YouTubeMusicError {
            throw error
        } catch {
            throw YouTubeMusicError.networkError(error)
        }
    }

    private func createSampleSongs(count: Int, prefix: String, videoId: String? = nil) -> [Song] {
        var songs: [Song] = []

        for i in 0..<count {
            let sampleVideoId = videoId ?? "sample_\(UUID().uuidString.prefix(8))"
            let song = Song(
                title: "\(prefix) \(i + 1)",
                artist: "Sample Artist \(i + 1)",
                youtubeId: sampleVideoId,
                thumbnailURL: "https://img.youtube.com/vi/\(sampleVideoId)/default.jpg",
                duration: Double.random(in: 120...300),
                startTime: 0,
                order: i
            )
            songs.append(song)
        }

        return songs
    }
}

private struct PlaylistItemsResponse: Decodable {
    let nextPageToken: String?
    let items: [PlaylistItem]
}

private struct PlaylistItem: Decodable {
    let contentDetails: PlaylistItemContentDetails
}

private struct PlaylistItemContentDetails: Decodable {
    let videoId: String
}

private struct VideosResponse: Decodable {
    let items: [VideoItem]
}

private struct VideoItem: Decodable {
    let id: String
    let snippet: VideoSnippet
    let contentDetails: VideoContentDetails
}

private struct VideoSnippet: Decodable {
    let title: String
    let channelTitle: String
    let thumbnails: VideoThumbnails
}

private struct VideoThumbnails: Decodable {
    let `default`: VideoThumbnail?
    let medium: VideoThumbnail?
    let high: VideoThumbnail?
    let standard: VideoThumbnail?
    let maxres: VideoThumbnail?

    var best: VideoThumbnail? {
        maxres ?? standard ?? high ?? medium ?? `default`
    }
}

private struct VideoThumbnail: Decodable {
    let url: String
}

private struct VideoContentDetails: Decodable {
    let duration: String
}

private extension String {
    var timeInterval: TimeInterval {
        let pattern = #"PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: self, range: NSRange(startIndex..<endIndex, in: self)) else {
            return 0
        }

        func component(at index: Int) -> Int {
            let range = match.range(at: index)
            guard range.location != NSNotFound,
                  let swiftRange = Range(range, in: self) else {
                return 0
            }
            return Int(self[swiftRange]) ?? 0
        }

        let hours = component(at: 1)
        let minutes = component(at: 2)
        let seconds = component(at: 3)

        return TimeInterval(hours * 3600 + minutes * 60 + seconds)
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
