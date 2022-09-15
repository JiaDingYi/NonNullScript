#!/usr/bin/swift

import Files
import Foundation

let path = "/Users/wangzeyong/Desktop/KKWorld/Codeup/client_ios_private_party/ACKSearchModule/ACKSearchModule/Classes"
try Folder(path: path).subfolders.recursive.forEach { folder in
    for file in folder.files {
        guard file.extension == "h" else { continue }
        var str = try String(contentsOfFile: file.path, encoding: .utf8)
        if str.contains("@interface") || str.contains("@protocol"), !str.contains("NS_ASSUME_NONNULL_BEGIN") {
            // 以 #import 开头, 中间包含多个空格, 最后包含 < > 或者 " " 的写法
            let defaultPattern = "\\n\\s*#import\\s*[<\"](.*?)[\">]"
            let regex = try NSRegularExpression(pattern: defaultPattern,
                                                options: .caseInsensitive)
            let matches = regex.matches(in: str,
                                        options: .reportProgress,
                                        range: NSRange(location: 0, length: str.count))
            guard let lastImport = matches.last else {
                print(file.path)
                continue
            }
            let range = Range(lastImport.range, in: str)
            str.insert(contentsOf: "\nNS_ASSUME_NONNULL_BEGIN", at: range!.upperBound)
            str.append("\nNS_ASSUME_NONNULL_END")
            try! str.write(toFile: file.path, atomically: true, encoding: .utf8)
        }
    }
}
