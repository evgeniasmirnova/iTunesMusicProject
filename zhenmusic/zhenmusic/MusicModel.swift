import Foundation

struct TrackList: Codable, Hashable {
    let resultCount: Int
    let results: [SongInfo]
}

struct SongInfo: Codable, Hashable {
    let kind: Kind?
    let artistName: String
    let collectionName: String?
    let trackName: String?
    let previewUrl: String?
    let artworkUrl100: String?
}

enum Kind: String, Codable {
    case song = "song"
    case tvEpisode = "tv-episode"
    case featureMovie = "feature-movie"
    case musicVideo = "music-video"
    case podcast = "podcast"
}
