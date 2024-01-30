//
//  AudioRequest.swift
//  AudioExample
//
//  Created by cyf on 2024/1/26.
//  Copyright © 2024 Dimitrios Chatzieleftheriou. All rights reserved.
//

import Foundation
import MobileCoreServices
import AudioStreaming

class AudioRequest {
    var request: URLRequest?

    var params: [String: Any] = [:]

    init(
        url: String,
        filePath: String,
        fileFieldName: String,
        params: [String: Any]
    ) {
        self.params = params
        self.request = makeFormDataRequest(
            fileFieldName: fileFieldName,
            file: filePath,
            url: url
        )
    }

    private func makeFormDataRequest(
        fileFieldName: String,
        file: String,
        url: String
    ) -> URLRequest? {
        guard let uploadUrl = URL(string: url) else { return nil }
        let fileUrl = NSURL.init(fileURLWithPath: file) as URL
        // 创建URLRequest
        var request = URLRequest(url: uploadUrl)
        request.httpMethod = "POST"

        request.setValue(
            "token..",
            forHTTPHeaderField: "Authorization"
        )

        request.setValue(
            "ua",
            forHTTPHeaderField: "User-Agent"
        )
        // 生成boundary字符串，用于multipart/form-data请求
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        // 创建http body
        var body = Data()
        // 添加文件数据
        let fileData = try? Data(contentsOf: fileUrl)
        let fileName = fileUrl.lastPathComponent
        let mineType = "audio/wav"
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fileFieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mineType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData!)
        body.append("\r\n".data(using: .utf8)!)
        
        var str = ""
        for item in params.keys {
            if let value = params[item] {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                str.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(item)\"\r\n\r\n".data(using: .utf8)!)
                str.append("Content-Disposition: form-data; name=\"\(item)\"\r\n\r\n")
                body.append("\(value)\r\n".data(using: .utf8)!)
                str.append("\(value)\r\n")
            }
        }
        // 结束标记
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        return request
    }
}


extension URL {
    func mimeType() -> String {
        let pathExtension = self.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue() {
            if let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimeType as String
            }
        }
        return "application/octet-stream" // 默认值
    }
}
