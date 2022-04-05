//
//  M3uError.swift
//  WebHunt
//
//  Created by Hemin Won on 2022/4/5.
//  Copyright © 2022 HeminWon. All rights reserved.
//

import Foundation

public enum M3uError: Error {
    case invalidEXTM3U
}

extension M3uError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidEXTM3U:
            return "#EXTM3U "
        }
    }
}
