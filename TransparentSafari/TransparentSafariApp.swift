//
//  TransparentSafariApp.swift
//  TransparentSafari
//
//  Created by 杨奇 on 2024/9/18.
//

import SwiftUI


class ViewModel: ObservableObject {
    
    @Published var opacity: Double = 0.8
    @Published var scale: Double = 0.75
    @Published var urlString: String = "https://www.bilibili.com"
    @Published var url: URL = URL(string: "https://www.bilibili.com")!
    @Published var lastUrl: URL?
    
    func loadUrlString(_ urlString: String) {
        self.urlString = urlString
        if let url = URL(string: urlString) {
            self.url = url
        }
    }
    
}



@main
struct TransparentSafariApp: App {
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 10, minHeight: 10)
                .environmentObject(viewModel)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            CommandGroup(replacing: .appTermination) {
                Button("Quit") {
                    NSApp.terminate(nil)
                }
                .keyboardShortcut("q")
            }
            CommandGroup(after: .newItem) {
                Button(action: {
                    viewModel.opacity = 0.6
                    if let window = NSApplication.shared.windows.first {
                        window.alphaValue = CGFloat(viewModel.opacity)
                    }
                }) {
                    Text("Set Opacity to 0.6")
                }
                .keyboardShortcut("s", modifiers: [.command])
                
                Button(action: {
                    viewModel.opacity += 0.01;
                    if let window = NSApplication.shared.windows.first {
                        window.alphaValue = CGFloat(viewModel.opacity)
                    }
                }) {
                    Text("Increse Alpha")
                }
                .keyboardShortcut(.upArrow, modifiers: [.command])
                
                Button(action: {
                    viewModel.opacity -= 0.01;
                    if let window = NSApplication.shared.windows.first {
                        window.alphaValue = CGFloat(viewModel.opacity)
                    }
                }) {
                    Text("Reduce Alpha")
                }
                .keyboardShortcut(.downArrow, modifiers: [.command])
                
            }
            CommandMenu("BookMark") {
                Button("Baidu") {
                    viewModel.loadUrlString("https://www.baidu.com")
                }
                Button("BiliBili") {
                    viewModel.loadUrlString("https://www.bilibili.com")
                }
                Button("DouYin") {
                    viewModel.loadUrlString("https://www.douyin.com")
                }
            }
            CommandMenu("Scale") {
                Button("0.1") {
                    setScale(0.1)
                }
                Button("0.25") {
                    setScale(0.25)
                }
                Button("0.5") {
                    setScale(0.5)
                }
                Button("0.75") {
                    setScale(0.75)
                }
                Button("1.0") {
                    setScale(1.0)
                }
            }
            CommandMenu("Alpha") {
                Button("0.05") {
                    setScale(0.05)
                }
                Button("0.1") {
                    setAplha(0.1)
                }
                Button("0.15") {
                    setAplha(0.15)
                }
                Button("0.2") {
                    setAplha(0.2)
                }
                Button("0.3") {
                    setAplha(0.3)
                }
                Button("0.4") {
                    setAplha(0.4)
                }
                Button("0.5") {
                    setAplha(0.5)
                }
                Button("0.6") {
                    setAplha(0.6)
                }
                Button("0.7") {
                    setAplha(0.7)
                }
                Button("0.8") {
                    setAplha(0.8)
                }
                Button("1.0") {
                    setAplha(1.0)
                }
                Button("增加(command+↑)") {
                    setScale(viewModel.opacity+0.1)
                }
                Button("减少(command+↓)") {
                    setScale(viewModel.opacity-0.1)
                }
            }
        }
    }
    
    func setScale(_ scale: Double) {
        viewModel.scale = scale
    }
    func setAplha(_ scale: Double) {
        viewModel.opacity = scale
        if let window = NSApplication.shared.windows.first {
            window.alphaValue = CGFloat(viewModel.opacity)
        }
    }
}


