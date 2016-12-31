//
//  SourceEditorCommand.swift
//  XShared
//
//  Created by Nikita Ermolenko on 31/12/2016.
//  Copyright © 2016 Nikita Ermolenko. All rights reserved.
//

import Foundation
import XcodeKit
import AppKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let selectedText = self.selectedText(from: invocation.buffer)
        if !selectedText.isEmpty {
            var pasteboardString = ""
            pasteboardString += "```"
            pasteboardString += "\n"
            pasteboardString += selectedText
            pasteboardString += "\n"
            pasteboardString += "```"
            
            NSPasteboard.general().declareTypes([NSPasteboardTypeString], owner: nil)
            NSPasteboard.general().setString(pasteboardString, forType: NSPasteboardTypeString)
        }
        
        completionHandler(nil)
    }
    
    private func selectedText(from buffer: XCSourceTextBuffer) -> String {
        var text = ""
        
        for (index, selection) in buffer.selections.enumerated() {
            if index > 0 {
                text.append("\n")
            }
            let range = selection as! XCSourceTextRange
            
            if range.start.line == range.end.line {
                let line = buffer.substring(by: range.start.line, from: range.start.column, to: range.end.column)
                text.append(line)
                continue
            }
            
            let firstLine = buffer.substring(by: range.start.line, from: range.start.column, to: nil)
            text.append(firstLine)
            
            if range.end.line - range.start.line > 1 {
                for line in (range.start.line+1)...(range.end.line-1) {
                    let line = buffer.lines[line] as! String
                    text.append(line)
                }
            }

            let lastLine = buffer.substring(by: range.end.line, from: 0, to: range.end.column)
            text.append(lastLine)
        }
        return text
    }
}

fileprivate extension XCSourceTextBuffer {
    
    func substring(by index: Int, from: Int, to: Int?) -> String {
        let line = lines[index] as! String
        let lineLetters = line.characters.map { String($0) }
        let lineLettersSlice = lineLetters[from..<(to ?? line.characters.count)]
        return lineLettersSlice.joined()
    }
}
