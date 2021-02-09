//
//  HTree.swift
//  oit1
//
//  Created by dimam on 29.10.20.
//

import Foundation

class HTree {
   private var Tree = [BinaryTree]()
   private var dict = [String: Int]()
   private var verseDict = [Int: [String]]()
   private var root : BinaryTree?
   private var decodeTree = [BinaryTree]()
    private let directory = Directory(path: "")
    
    fileprivate func parseFromFile(path: String) throws {

    let data = try String(contentsOfFile: path)

    for i in data {
        if dict[String(i)] == nil {
            dict[String(i)] = 0
        }
    }
    for i in data  {
        if dict[String(i)] != nil {
            dict[String(i)]! += 1
        }
      }
    }
    
    fileprivate func verse(){
        for (key,value) in dict {
            if verseDict[value] != nil {
                verseDict[value]?.append(key)
            } else {
                verseDict[value] = [key]
            }
    }
}
    fileprivate func checkSearch(a: (Bool,Int?),i: Int,leaf1: String, leaf2:String) -> (Bool) {
        if a.0 {
            Tree.append(.node(Tree[i], leaf1+leaf2, Tree[a.1!]))
            return true
        }
        return false
    }
    
    fileprivate func makeTree(leaf1: String, leaf2: String) -> () {
        if leaf1.count <= 1 && leaf2.count <= 1  {
            Tree.append(.node(.empty, leaf1 , .empty))
            Tree.append(.node(.empty, leaf2 , .empty))
            Tree.append(.node(Tree[Tree.count - 2], leaf1+leaf2 , Tree.last!))
            return
        } else  {
            for i in 0..<Tree.count {
                switch Tree[i] {
                case let .node(_, value , _) where value == leaf1:
                    if checkSearch(a: search(str: leaf2), i: i, leaf1: leaf1, leaf2: leaf2) {
                        return
                    }
                    Tree.append(.node(.empty ,leaf2 ,.empty ))
                    Tree.append(.node(Tree[i], leaf1+leaf2, Tree.last!))
                    return
                case let .node(_, value , _) where value == leaf2:
                    if checkSearch(a: search(str: leaf1), i: i, leaf1: leaf1, leaf2: leaf2) {
                        return
                    }
                    Tree.append(.node(.empty ,leaf1 ,.empty ))
                    Tree.append(.node(Tree[i], leaf1+leaf2, Tree.last!))
                    return
                default:
                    break
                }
            }
            
        }
    }
    
    fileprivate func search(str: String) -> (Bool,Int?) {
        for i in 0..<Tree.count {
            switch Tree[i] {
            case let .node(_, v, _) where v == str:
                return (true,i)
            default:
                break
            }
        }
        return (false,nil)
    }
    
    fileprivate func removeKey(minKey: Int) {
        if verseDict[minKey]!.isEmpty {
            verseDict.removeValue(forKey: minKey)
        }
    }
    
    fileprivate func makeDict(minKey: Int, check: Bool) -> () {
        if check {
        var b = verseDict[minKey]!
        if var a = verseDict[minKey+minKey] {
            a.insert(b[0]+b[1], at: 0)
            verseDict[minKey+minKey] = a
        } else {
            verseDict[minKey+minKey] = []
            verseDict[minKey+minKey]!.insert(b[0]+b[1], at: 0)
        }
        makeTree(leaf1: b[0], leaf2: b[1])
        b.remove(at: 1)
        b.remove(at: 0)
        verseDict[minKey] = b
        removeKey(minKey: minKey)
        } else {
            var newMinKey = 0
            let symbol = verseDict[minKey]!.last!
            let oldMinKey = minKey
            verseDict.removeValue(forKey: minKey)
            newMinKey = verseDict.keys.min()!
            var b = verseDict[newMinKey]!
            if var a = verseDict[oldMinKey+newMinKey]{
                a.insert(symbol+b[0], at: 0)
                verseDict[oldMinKey+newMinKey] = a
            } else {
                verseDict[oldMinKey+newMinKey] = []
                verseDict[oldMinKey+newMinKey]!.insert(symbol+b[0], at: 0)
            }
            makeTree(leaf1: symbol, leaf2: b[0])
            b.remove(at: 0)
            verseDict[newMinKey] = b
            removeKey(minKey: newMinKey)
        }
    }
    
    fileprivate func makeDecodeTable(toTablePath path: String) throws -> ()  {
            var str = ""
            for i in dict.keys {
               str.append(i)
               root?.search(searchValue: i,str: &str )
               str.append("\n")
               try str.write(toFile: path, atomically: false, encoding: String.Encoding.utf8)
            }
    }
    
    func start(toFilePath pathF: String,toTablePath path: String) {
        do {
        try parseFromFile(path: pathF)
        }  catch {
            
        }
        verse()
        while true {
        if verseDict.count == 1{
                break
        }
            let minKey = verseDict.keys.min()!
            makeDict(minKey: minKey, check: verseDict[minKey]!.count >= 2)
            print(verseDict)
            root = Tree.last
    }
        print(root!)
        do {
         try makeDecodeTable(toTablePath: path)
        } catch {
            print("Invaild path")
        }
    }
    
   fileprivate func makeDecodeDict(toTablePath path: String) throws -> [Character: String] {
        let tableStr = try String(contentsOfFile: path)
        var arrayStr = [Character: String]()
        var check = true
        var key : Character = Character(" ")
        for i in tableStr {
           if check {
               arrayStr[i] = ""
               key = i
               check = false
               continue
           }
           if i != "\n" {
               arrayStr[key]!.append(i)
           } else {
               check = true
           }
       }
        return arrayStr
    }
    
    func decode(toTablePath pathT: String,decodeFilePath pathF: String) throws -> () {
         var i2 = String()
         var decodeStr = String()
         var data = Data()
         var str = String()
         let hafTable = try makeDecodeDict(toTablePath: pathT)
         let pathToFileURL = FileManager.default.urls(for: .userDirectory, in: .allDomainsMask)[0].appendingPathComponent("\(directory.getPathForFM(path: pathF))")
        do {
           data = try Data(contentsOf: pathToFileURL)
        } catch {
            print(error.localizedDescription)
        }
        let byteArr = [UInt8](data)
        let numberOfZeros = byteArr.last!
        var count = 0
        let bCount = byteArr.count
        for i in byteArr {
            count += 1
            if count == bCount - 1 {
                if numberOfZeros >= 1 {
                var temp = String(i, radix: 2)
                temp = temp.pad(string: temp, toSize: 8)
                temp.removeLast(Int(numberOfZeros))
                str.append(temp)
                break
                }
            } else {
            var temp = String(i, radix: 2)
            temp = temp.pad(string: temp, toSize: 8)
            str.append(temp)
        }
        }
        for i in str {
            i2.append(i)
        for (key,value) in hafTable {
            if i2 == value {
                decodeStr.append(key)
                i2.removeAll()
                break
            }
          }
        }
        try decodeStr.write(toFile: "/Users/dimam/Desktop/newXML.xml", atomically: false, encoding: String.Encoding.utf8)
        try FileManager.default.removeItem(at: pathToFileURL)
    }
    
    
    fileprivate func howManyZeroAdd(count: Int) -> (UInt8,String) {
        var str = String()
        if count % 8 == 0 {
            return (0,"")
        } else {
            for i in 1..<8 {
                if (count + i) % 8 == 0 {
                    for _ in 1...i {
                        str.append("0")
                    }
                    return (UInt8(i),str)
                }
            }
            return (0,"")
        }
    }
    
    func encode(pathToFile: String,toTablePath path: String) throws -> () {
        let arrayStr = try makeDecodeDict(toTablePath: path)
        var str = String()
        let pathForFM = directory.getPathForFM(path: pathToFile)
        let pathToFileURL = FileManager.default.urls(for: .userDirectory, in: .allDomainsMask)[0].appendingPathComponent("\(pathForFM)")
        let pathToEncodeFile = FileManager.default.urls(for: .userDirectory, in: .allDomainsMask)[0].appendingPathComponent("dimam/Desktop/encodeFile")
        do {
            str = try String(contentsOf: pathToFileURL)
        } catch {
            print(error.localizedDescription)
        }
        var encodeStr = String()
        for i in str {
            for (key,value) in arrayStr {
                if i == key {
                    encodeStr.append(value)
                    break
                }
            }
        }
        var count = 0
        var byteArr = [UInt8]()
        var tempStr = String()
        let eCount = encodeStr.count
        let hmza = howManyZeroAdd(count: eCount)
        for i in encodeStr {
            count += 1
            tempStr.append(i)
            if count == eCount {
                tempStr.append(hmza.1)
                byteArr.append(UInt8(tempStr,radix: 2)!)
                byteArr.append(hmza.0)
                tempStr.removeAll()
            } else if tempStr.count == 8 {
                byteArr.append(UInt8(tempStr,radix: 2)!)
                tempStr.removeAll()
            }
        }
        let data2 = Data(bytes: byteArr, count: byteArr.count)
        try data2.write(to: pathToEncodeFile)
        try FileManager.default.removeItem(at: pathToFileURL)
}
}

