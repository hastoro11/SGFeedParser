//
//  AtomFeedParser.swift
//  SGNewsReader
//
//  Created by Gabor Sornyei on 2022. 03. 19..
//

import Foundation
import FaviconFinder
import SwiftSoup

// MARK: - AtomParser
class AtomParser: NSObject {
    var parser: XMLParser?
    var feed: Feed = Feed()
    
    var currentString: String = ""
    var inEntry: Bool = false
    var currentItem: FeedItem = FeedItem()
    
    init(url: URL) {
        super.init()
        self.parser = XMLParser(contentsOf: url)
        parser?.delegate = self
    }
    
    func parse(completion: @escaping (Feed) -> Void) {
        parser?.parse()
        completion(feed)
    }
    
    func parse() async -> Feed {
        parser?.parse()
        return await withCheckedContinuation({ cont in
            if let imageURL = URL(string: feed.link) {
                FaviconFinder(url: imageURL).downloadFavicon { result in
                    switch result {
                    case let .success(icon):
                        self.feed.imageURL = icon.url
                    case .failure(_):
                        break
                    }
                    cont.resume(returning: self.feed)
                }
            }
        })
    }
}

// MARK: - AtomParserDelegate
extension AtomParser: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if elementName == "entry" {
            currentItem = FeedItem()
            inEntry = true
        }
        
        if elementName == "entry"
            || elementName == "title"
            || elementName == "link"
            || elementName == "subtitle"
            || elementName == "updated"
            || elementName == "published"
            || elementName == "name" {
            currentString = ""
        }
        if elementName == "link" {
            if let link = attributeDict["href"] {
                if !inEntry {
                    feed.link = link
                } else {
                    currentItem.link = link
                }
            }
        }

        print(elementName)
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentString += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentString = currentString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Feed elements
        if !inEntry {
            if elementName == "title" {
                feed.title = currentString
            } else if elementName == "subtitle" {
                feed.description = currentString
            } else if elementName == "updated" {
//                let formatter = ISO8601DateFormatter()
//                feed.pubDate = formatter.date(from: currentString)
                feed.pubDate = Util.buildDateFromString(currentString)
            }
        }
        
        // Entry elements
        if inEntry {
            if elementName == "name" {
                currentItem.author = currentString
            } else if elementName == "title" {
                currentItem.title = currentString
            } else if elementName == "subtitle" {
                currentItem.description = currentString
            } else if elementName == "content" {
                currentItem.content = currentString
                let doc: Document = try! SwiftSoup.parse(currentString)
                let elements = try? doc.getElementsByTag("p")
                for p in elements  ?? Elements() {
                    currentItem.description.append(try! p.text() + "\n")
                }
            } else if elementName == "published" {
                currentItem.pubDate = Util.buildDateFromString(currentString)
            }
        }
        
        if elementName == "entry" {
            if currentItem.imageLink.isEmpty {
                let doc = try! SwiftSoup.parse(currentItem.content)
                let img = try! doc.getElementsByTag("img")
                currentItem.imageLink = try! img.attr("src")
            }
            feed.items.append(currentItem)
            inEntry = false
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        if let url = URL(string: feed.link) {
            FaviconFinder(url: url).downloadFavicon { result in
                if case let .success(icon) = result {
                    self.feed.imageURL = icon.url
                }
            }
        }
    }
}
