//
//  Feed.swift
//  SGNewsReader
//
//  Created by Gabor Sornyei on 2022. 03. 19..
//

import Foundation

public struct Feed {
    var title: String = ""
    var link: String = ""
    var description: String = ""
    var language: String = ""
    var imageURL: URL?
    var pubDate: Date?
    
    var items: [FeedItem] = []
    
}

public struct FeedItem {
    var title: String = ""
    var link: String = ""
    var description: String = ""
    var author: String = ""
    var imageLink: String = ""
    var pubDate: Date?
    var content: String = ""
}

