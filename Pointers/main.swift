import Foundation

// TODO Adjust the path to point to the sample text file
let path = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads/test.txt").path

guard let file = fopen(path, "r") else { fatalError() }
defer { fclose(file) }
fseek(file, 0, SEEK_END)
let size = ftell(file)
rewind(file)
let ptr = UnsafeMutableRawPointer.allocate(bytes: size, alignedTo: 1)
guard fread(ptr, 1, size, file) == size else { fatalError() }

let lineFeed = "\n".utf8CString.first!
let chars = ptr.bindMemory(to: CChar.self, capacity: size)
var lineCount = 0
for idx in 0..<size {
    if chars[idx] == lineFeed {
        lineCount += 1
    }
}
print(lineCount)

let lines = UnsafeMutablePointer<UnsafeMutablePointer<CChar>>.allocate(capacity: lineCount)

var lineOffset = 0
var lineIdx = 0
for idx in 0..<size {
    guard chars[idx] == lineFeed else { continue }
    let lineLength = idx - lineOffset
    let line = UnsafeMutablePointer<CChar>.allocate(capacity: lineLength + 1)
    line.initialize(from: chars.advanced(by: lineOffset), count: lineLength)
    line[lineLength + 1] = 0
    lines[lineIdx] = line
    lineIdx += 1
    lineOffset = idx + 1
}

chars.deallocate(capacity: size)

for lineIdx in 0..<lineCount {
    let line = lines[lineIdx]
    let str = String(cString: line)
    print(str)
    line.deallocate(capacity: strlen(line) + 1)
}

lines.deallocate(capacity: lineCount)
