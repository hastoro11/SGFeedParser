import Foundation
public struct SGFeedParser {
    public private(set) var parser: FeedParser

    public init(url: URL) {
        parser = FeedParser(url: url)
    }
}
