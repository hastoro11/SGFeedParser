//
//  FeedParser.swift
//  SGNewsReader
//
//  Created by Gabor Sornyei on 2022. 03. 18..
//

import Foundation
import FaviconFinder
import SwiftSoup

// MARK: - FeedParser
public class FeedParser: NSObject {
    enum FeedType {
        case rss
        case atom
    }
    
    var parser: XMLParser?
    var url: URL!
    var feedType: FeedType?
    
    public init(url: URL) {
        super.init()
        self.url = url
        self.parser = XMLParser(contentsOf: url)
        self.parser?.delegate = self
    }
    
    public func parse(completion: @escaping (Feed) -> Void) {
        parser?.parse()
        switch feedType {
        case .rss:
            RSSParser(url: self.url).parse(completion: completion)
        case .atom:
            AtomParser(url: self.url).parse(completion: completion)
        case .none:
            break
        }
    }
    
    public func parse() async -> Feed? {
        parser?.parse()
        switch feedType {
        case .atom:
            return await AtomParser(url: url).parse()
        case .rss:
            return await RSSParser(url: url).parse()
        default:
            return nil
        }
    }
}

// MARK: - FeedParserDelegate
extension FeedParser: XMLParserDelegate {
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "feed" {
            self.feedType = .atom
        } else if elementName == "rss" {
            self.feedType = .rss
        }
    }
}
