import ImageIO
import Foundation

/// 起動直後に小さな AVIF を1枚デコードして、デコーダーの準備を先に済ませておく。
enum AVIFWarmup {
    // 16×16px・480バイトの AVIF。ネットを使わずに済むようコードに埋め込む
    private static let tinyAVIF = "AAAAIGZ0eXBhdmlmAAAAAE1pUHJhdmlmbWlhZm1pZjEAAAEhbWV0YQAAAAAAAAAhaGRscgAAAAAAAAAAcGljdAAAAAAAAAAAAAAAAAAAAAAkZGluZgAAABxkcmVmAAAAAAAAAAEAAAAMdXJsIAAAAAEAAAAOcGl0bQAAAAAAAQAAACNpaW5mAAAAAAABAAAAFWluZmUCAAAAAAEAAGF2MDEAAAAAgWlwcnAAAABgaXBjbwAAABNjb2xybmNseAACAAIABoAAAAAMY2xsaQDLAEAAAAAUaXNwZQAAAAAAAAAQAAAAEAAAAAlpcm90AAAAABBwaXhpAAAAAAMICAgAAAAMYXYxQ4EADAAAAAAZaXBtYQAAAAAAAAABAAEGgQIDBYaEAAAAHmlsb2MAAAAARAAAAQABAAAAAQAAAVEAAACPAAAAAW1kYXQAAAAAAAAAnxIACg0AAAABn/n/8CBAQNCAMnwQAbIAMMMMKMPgPa6N0o6I3OOKyqpfcUyEM45Iad9qMkxWKXuyoutDUyATWvEiqG1SPMIy7AybTkbaDC9OXLF8w609F5nIrEFkYNvun8g/x5wGFdkzNavNhqxFHjFUZbOnAmBP2FrkcqY7GUDbNhNVWfKjPe/iAPOJg90r"

    static func run() {
        guard let data = Data(base64Encoded: tinyAVIF),
              let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, [kCGImageSourceShouldCacheImmediately: true] as CFDictionary)
        else { return }
        _ = image.dataProvider?.data
    }
}
