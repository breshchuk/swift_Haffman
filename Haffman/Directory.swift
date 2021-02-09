//
//  Directory.swift
//  oit1
//
//  Created by dimam on 14.12.20.
//
import AEXML
import Foundation

class Directory {
    var arrayOfPaths = [String]()
    var arrayOfContent = [String : String]()
    let path : String
    
    init(path: String) {
        self.path = path
    }
    
    func getPathForFM(path: String) -> String {
        var check = 0
        var newPath = String()
        for i in path {
            if i == "/" && check < 2{
                check += 1
            }
            if check == 2 {
                newPath.append(i)
            }
        }
        return newPath
    }
    func getRootFolder(path: String) -> String {
        let newPath = path.split(separator: "/")
        return String(newPath.last!)
    }
    
    func getFolders(){
        let enumerator = FileManager.default.enumerator(atPath: path)
        let path2 = getPathForFM(path: path)
        
        while let filename = enumerator?.nextObject() as? String {
            if !filename.contains(".DS_Store") {
            arrayOfPaths.append(filename)
                if filename.contains(".txt"){
                    let path1 = FileManager.default.urls(for: .userDirectory, in: .allDomainsMask)[0].appendingPathComponent("\(path2)\(filename)")
                    do {
                       let content = try String(contentsOf: path1)
                       arrayOfContent[filename] = content
                    } catch {
                        print(error.localizedDescription)
                    }
                    }
            }
        }
    }
    
    func makeXML() {
        let directory = AEXMLDocument()
        let root = directory.addChild(name: "RootFolder",attributes: ["name": "\(getRootFolder(path: path))"])
        var dictionary = [String: AEXMLElement]()
        var order = [String]()
        for i in self.arrayOfPaths {
            if !i.contains("/") && i.contains(".txt") {
                for (key,value) in arrayOfContent {
                    if key == i {
                        root.addChild(name: "file",value: value, attributes: ["name": "\(i)"])
                        break
                    }
                }
                continue
            } else if !i.contains("/"){
                dictionary[i] = root.addChild(name: "folder",attributes: ["name": "\(i)"])
                order.append(i)
                continue
            }
            let splitStr = i.split(separator: "/")
            var needKey = String()
            for o in order {
                for j in splitStr {
                    if o.contains(j) {
                        needKey = o
                    }
                }
            }
            if i.contains(".txt") {
                for (key,value) in arrayOfContent {
                    if i == key {
                        dictionary[needKey]!.addChild(name: "file",value: value,attributes: ["name": "\(String(splitStr.last!))"])
                        break
                    }
                }
                    
            } else if i.contains("/") {
                dictionary[String(splitStr.last!)] = dictionary[needKey]!.addChild(name: "folder",attributes: ["name": "\(String(splitStr.last!))"])
                order.append(String(splitStr.last!))
            }
        }
       // print(directory.xml)
        do {
        try directory.xml.write(toFile: "/Users/dimam/Desktop/MyXML.xml", atomically: false, encoding: String.Encoding.utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteDirectory() {
        let path1 = FileManager.default.urls(for: .userDirectory, in: .allDomainsMask)[0].appendingPathComponent("\(getPathForFM(path: path))")
        do {
            try FileManager.default.removeItem(at: path1)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func makeDirectoryFromXMl(pathToDirectory pathD: String, xml: AEXMLElement) -> Void {
        if xml.children.count != 0 {
        for child in xml.children {
                createDirectoryAndFile(path: "\(pathD)\(child.attributes["name"]!)/",value: child.value ?? nil)
                makeDirectoryFromXMl(pathToDirectory: "\(pathD)\(child.attributes["name"]!)/", xml: child)
        }
        } else {
           // createDirectoryAndFile(path: "\(pathD)\(xml.attributes["name"]!)/",value: xml.value ?? nil)
            return
        }
    }
    
    func makeDirectory(toPathXML path: String,toPathDirectory pathD: String) {
        let pathToXml = FileManager.default.urls(for: .userDirectory, in: .allDomainsMask)[0].appendingPathComponent("\(getPathForFM(path: path))")
        var xmlDocument = AEXMLDocument()
        do {
            let data = try Data.init(contentsOf: pathToXml)
            xmlDocument = try AEXMLDocument(xml: data)
        }catch {
            print(error.localizedDescription)
        }
        let root = xmlDocument.root
        createDirectoryAndFile(path: "\(pathD)\(root.attributes["name"]!)/",value: root.value ?? nil)
        let rootPath = "\(pathD)\(root.attributes["name"]!)/"
        makeDirectoryFromXMl(pathToDirectory: rootPath, xml: root)
        do {
        try FileManager.default.removeItem(at: pathToXml)
        } catch {
            print(error.localizedDescription)
        }
        //print(xmlDocument.xml)
    }
    
    func createDirectoryAndFile(path: String,value: String?)  {
       // let path1 = FileManager.default.urls(for: .userDirectory, in: .allDomainsMask)[0].appendingPathComponent("\(getPathForFM(path: path))")
        if !path.contains(".txt") {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        } else {
            let pathToFile = FileManager.default.urls(for: .userDirectory, in: .allDomainsMask)[0].appendingPathComponent("\(getPathForFM(path: path))")
            do {
                try value!.write(to: pathToFile, atomically: false, encoding: String.Encoding.utf8)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
}
