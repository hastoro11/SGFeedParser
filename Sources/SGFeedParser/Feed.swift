//
//  Feed.swift
//  SGNewsReader
//
//  Created by Gabor Sornyei on 2022. 03. 19..
//

import Foundation

public struct Feed {
    
    public init(title: String = "", link: String = "", description: String = "", language: String = "", imageURL: URL? = nil, pubDate: Date? = nil, items: [FeedItem] = []) {
        self.title = title
        self.link = link
        self.description = description
        self.language = language
        self.imageURL = imageURL
        self.pubDate = pubDate
        self.items = items
    }
    
    public var title: String = ""
    public var link: String = ""
    public var description: String = ""
    public var language: String = ""
    public var imageURL: URL?
    public var pubDate: Date?
    
    public var items: [FeedItem] = []
    
}

public struct FeedItem {
    public var title: String = ""
    public var link: String = ""
    public var description: String = ""
    public var author: String = ""
    public var imageLink: String = ""
    public var pubDate: Date?
    public var content: String = ""
}

