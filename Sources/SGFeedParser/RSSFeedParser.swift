//
//  RSSFeedParser.swift
//  SGNewsReader
//
//  Created by Gabor Sornyei on 2022. 03. 19..
//

import Foundation
import FaviconFinder
import SwiftSoup

// MARK: - RSSParser
class RSSParser: NSObject {
    var parser: XMLParser?
    var feed: Feed = Feed()
    
    var inItem: Bool = false
    var inImage: Bool = false
    
    var currentString: String = ""
    
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
        return await withCheckedContinuation { cont in
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
        }
    }
}

// MARK: - RSSParserDelegate
extension RSSParser: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "item" {
            inItem = true
            currentItem = FeedItem()
        }
        if elementName == "image" {
            inImage = true
        }
        if elementName == "media:content" || elementName == "enclosure" {
            if let url = attributeDict["url"] {
                currentItem.imageLink = url
            }
        }
        if elementName == "title"
            || elementName == "link"
            || elementName == "description"
            || elementName == "lastBuildDate"
            || elementName == "pubDate"
            || elementName == "dc:creator"
            || elementName == "author"
            || elementName == "media:content"
            || elementName == "language" {
            currentString = ""
        }
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentString += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentString = currentString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Channel elements
        if !inItem {
            if !inImage && elementName == "title" {
                feed.title = currentString
            } else if !inImage && elementName == "link" {
                feed.link = currentString
            } else if elementName == "description" {
                feed.description = currentString
            } else if elementName == "language" {
                feed.language = currentString
            } else if elementName == "lastBuildDate" || elementName == "pubDate" {
                feed.pubDate = Util.buildDateFromString(currentString)
            }
        }
        
        // Item elements
        if inItem {
            if elementName == "title" {
                currentItem.title = currentString
            } else if elementName == "link" {
                currentItem.link = currentString
            } else if elementName == "description" {
                currentItem.content = currentString
                let doc: Document = try! SwiftSoup.parse(currentString)
                let elements = (try? doc.getElementsByTag("p")) ?? Elements()
                if elements.isEmpty() {
                    currentItem.description = (try? doc.text()) ?? "content"
                } else {
                    for p in elements {                        
                        let text = (try? p.text()) ?? ""
                        currentItem.description.append(text+"\n")
                    }
                }
                
            } else if elementName == "dc:creator" {
                currentItem.author = currentString
            } else if elementName == "pubDate" {
                currentItem.pubDate = Util.buildDateFromString(currentString)
            } else if elementName == "author" {
                currentItem.author = currentString
            }
        }
        
        if elementName == "item" {
            if currentItem.imageLink.isEmpty {
                let doc: Document = try! SwiftSoup.parse(currentItem.content)
                let img = try! doc.getElementsByTag("img")
                currentItem.imageLink = (try? img.attr("src")) ?? ""
            }
            inItem = false
            feed.items.append(currentItem)
        }
        if elementName == "image" {
            inImage = false
        }
    }
  
    
}
