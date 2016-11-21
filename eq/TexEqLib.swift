//
//  TexEqLib.swift
//
//  Created by Andrea Andreolli on 09/10/2016.
//  Copyright © 2016 Andrea Andreolli. All rights reserved.
//

import Foundation

class TexEq {
  
    var tempDir: URL!
    func tempDirAsString() -> String {
        let s1 = "\(tempDir)"
        let i1 = s1.index(s1.endIndex, offsetBy: -1)
        let s2 = s1.substring(to: i1)
        let i2 = s2.index(s2.startIndex, offsetBy: 16)
        return s2.substring(from: i2)
    }
    func texFile() -> URL {
        return tempDir.appendingPathComponent("eq.tex")
    }
    func texFileDirAsString() -> String {
        let s1 = "\(texFile())"
        let i1 = s1.index(s1.startIndex, offsetBy: 7)
        return s1.substring(from: i1)
    }
    func pdfFile() -> URL {
        return tempDir.appendingPathComponent("eq.pdf")
    }
    let blankImg = Bundle.main.urlForImageResource("blank.png")
    let errorImg = Bundle.main.urlForImageResource("error.png")
    
    
    func makeTempDir() {
        
        //generate unique temporary file path (updating tempDir) and create actual directory
        
        tempDir = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString, isDirectory: true)!
        do {
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            //TO BE IMPROVED: error handling here
        }
    }

    
    func makeTexFile(latexCode: String) {
        
        //generate string containing latex code
        let latexCode = "\u{5C}documentclass\u{7B}standalone\u{7D}\n"+"\u{5C}usepackage\u{7B}standalone\u{7D}\n"+"\u{5C}begin\u{7B}document\u{7D}\n"+"$\u{5C}displaystyle\n"+latexCode+"\n"+"$\n"+"\u{5C}end\u{7B}document\u{7D}"
        
        
        //write file
        do {
            try latexCode.write(to: texFile(), atomically: false, encoding: String.Encoding.utf8)
        }
        catch {
            //TO BE IMPROVED: error handling here
        }
    }
    
    
    func pdfIsMade() -> Bool {
        let texTask = Process()
        texTask.launchPath = "/Library/TeX/texbin/pdflatex"
        texTask.arguments = ["-output-directory="+tempDirAsString(), texFileDirAsString()]
        texTask.launch()
        let startingTime = Date()
        while (NSDate().timeIntervalSince(startingTime) < 3) {
            if (texTask.isRunning == false) {
                return true
            }
        }
        return false
    }
    
    func deleteTemp() {
        let filemanager = FileManager.default
        do {
            try filemanager.removeItem(at: tempDir)
        }
        catch {
            //TO BE IMPROVED: error handling here
        }
    }
    
    func stringIsEmpty(string: String) -> Bool {
        for char in string.characters {
            if (char != " ") {
                return false
            }
        }
        return true
    }
    
    func getEqPNG(latexCode: String, desiredResolution: CGFloat) -> Data {
        if stringIsEmpty(string: latexCode) {
            do {
                let blank = try Data(contentsOf: blankImg!)
                return blank
            }
            catch {
                //ERROR HANDLING HERE; since this thing accesses resource files, it is unlikely to have error
                return Data() // this needs to be replaced with anything that shuts down application and prints error message like "missing resources"
            }
        }
        makeTempDir()
        makeTexFile(latexCode: latexCode)
        if pdfIsMade() {
            let eq = PdfAsImg(pdfURL: pdfFile())
            deleteTemp()
            return eq.asPNG(desiredResolution:  desiredResolution)
        }
        else {
            do {
                let error = try Data(contentsOf: errorImg!)
                return error
            }
            catch {
                //ERROR HANDLING HERE; since this thing accesses resource files, it is unlikely to have error
                return Data() // this needs to be replaced with anything that shuts down application and prints error message like "missing resources"
            }
        }
    }
    
    
}


//Create tex file in temp folder

//Compile file

//Convert pdf to picture

//Access picture and delete old files
