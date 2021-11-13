//
//  NavigationHelper.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 13.11.2021.
//

import Cocoa
import SwiftUI

protocol ListNavigationControllerType: AnyObject {
    associatedtype T: NSView
    typealias Item = T
    
    var items: [Item] { get }
}

final class NavigationHelper: ListNavigationControllerType {
    typealias T = NSView
    private(set) var items: [Item] = []
    
    private let window: NSWindow
    
    init(window: NSWindow) {
        self.window = window
    }
    
    func switchSubView<T>(to view: T) where T: NSView {
        items.append(view)
        
        window.contentView = view
        
        if items.count > 1 {
            addBackButton()
        }
    }
    
    func pop() {
        items.removeLast()
        
        self.window.contentView = items.last
        
        if items.count > 1 {
            addBackButton()
        }
    }
    
    private func addBackButton() {
        let barView = NavigationBar(toggleBack: { [weak self] in
            print("Did tap navigation bar")
            self?.pop()
        })
        
        let barHostingView = NSHostingView(rootView: barView)
        barHostingView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: 100)
        
        window.contentView = barHostingView
    }
}