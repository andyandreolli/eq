//
//  PdfAsImg.swift
//  eq
//
//  Created by Andrea Andreolli on 18/10/2016.
//  Copyright © 2016 Andrea Andreolli. All rights reserved.
//

import Foundation

class PdfAsImg {
        
    let pdfImageRep: NSPDFImageRep
    
    
    init(pdfURL: URL) {
        let pdfData = NSData(contentsOf: pdfURL)
        pdfImageRep = NSPDFImageRep(data: pdfData as! Data)!
    }
    
    
    func asPNG(desiredResolution: CGFloat) -> Data {
        
        //First the desired size is created
        let scaleFactor = desiredResolution/72.0 //default resolution for pdf is 72ppi
        let size = NSMakeSize(pdfImageRep.size.width * scaleFactor, pdfImageRep.size.height * scaleFactor)
        
        //destinationRect is the rectangle that I'll draw to; sourceRect indicates the portion of the imagerep that will be drawn
        let sourceRect = NSMakeRect(0,0,pdfImageRep.size.width,pdfImageRep.size.height)
        let destinationRect = NSMakeRect(0, 0, size.width, size.height)
        
        //idk why but this is needed (I think drawing is not possible without any istance of NSImage)
        let image = NSImage(size: size)
        image.lockFocus()
        
        //drawing the image and converting it to png
        pdfImageRep.draw(in: destinationRect, from: sourceRect, operation: NSCompositeSourceOver, fraction: 1.0, respectFlipped: false, hints: [String: String]())
        let bitmap = NSBitmapImageRep(focusedViewRect: destinationRect)
        let PNGData = bitmap?.representation(using: NSPNGFileType, properties: [String: String]())
        
        return PNGData!
    }
    
}
