//
//  RecordingModel.swift
//
//  Created by devdchaudhary on 18/04/23.
//

import Foundation

public struct Recording: Hashable {

    public let uid: UUID
    public var fileURL: URL
    
    public init(fileURL: URL) {
        uid = UUID()
        self.fileURL = fileURL
    }
    
}

public struct SampleModel: Hashable {
    
    let id: UUID
    let sample: Float
    
    public init(sample: Float) {
        id = UUID()
        self.sample = sample
    }
    
}

public struct RecordingSampleModel: Hashable {
    
    let id: UUID
    public var sample: Int
    
    init(sample: Int) {
        id = UUID()
        self.sample = sample
    }
    
}
