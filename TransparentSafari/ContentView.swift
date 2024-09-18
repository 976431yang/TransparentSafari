//
//  ContentView.swift
//  TransparentSafari
//
//  Created by 杨奇 on 2024/9/18.
//

import SwiftUI
import WebKit


struct ContentView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var webView = WKWebView()
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack {
                    Button(action: {
                        webView.goBack()
                    }) {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(!webView.canGoBack)
                    
                    Button(action: {
                        webView.goForward()
                    }) {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(!webView.canGoForward)
                    
                    Button(action: {
                        webView.reload()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    
                    TextField("Enter URL", text: $viewModel.urlString, onCommit: {
                        loadURL()
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading)
                    
                    Spacer()
                    
                    Slider(value: $viewModel.opacity, in: 0...1, step: 0.01)
                        .frame(width: 150)
                }
                .padding(EdgeInsets(top: 10, leading: 80, bottom: 0, trailing: 20))
                
                WebViewWrapper(url:$viewModel.url, lastUrl: $viewModel.lastUrl, webView: $webView, reqCallBack: { req in
                    //viewModel.urlString = req.url?.absoluteString ?? viewModel.urlString
                    viewModel.loadUrlString(req.url?.absoluteString ?? viewModel.urlString)
                })
                //                .opacity(opacity)
                .transformEffect(CGAffineTransform(scaleX: viewModel.scale, y: viewModel.scale))
                .frame(width: (geometry.size.width) / viewModel.scale,
                       height: (geometry.size.height - 40) / viewModel.scale)
                .padding(EdgeInsets(top: 40, leading: 0, bottom: 0, trailing: 0))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(viewModel.opacity))
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                if let window = NSApplication.shared.windows.first {
                    window.isOpaque = false
                    window.backgroundColor = .gray
                    window.alphaValue = CGFloat(viewModel.opacity)
                }
                configureWebView()
                loadURL()
            }
            .onChange(of: viewModel.opacity) { newValue in
                if let window = NSApplication.shared.windows.first {
                    window.alphaValue = CGFloat(newValue)
                }
            }
        }
    }
    
    func configureWebView() {
        // 设置自定义用户代理
        let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Safari/605.1.15"
        webView.customUserAgent = userAgent
    }
    
    func loadURL() {
        var formattedURL = viewModel.urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !formattedURL.starts(with: "http://") && !formattedURL.starts(with: "https://") {
            formattedURL = "http://\(formattedURL)"
        }
        
        viewModel.loadUrlString(formattedURL)
        
//        if let validURL = URL(string: formattedURL) {
//            let request = URLRequest(url: validURL)
//            webView.load(request)
//        } else {
//            // 处理无效URL
//            print("Invalid URL: \(formattedURL)")
//        }
    }
}

struct WebViewWrapper: NSViewRepresentable {
    @Binding var url: URL
    @Binding var lastUrl: URL?
    @Binding var webView: WKWebView
    var reqCallBack: (URLRequest)->()
    
    func makeNSView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        if ((lastUrl?.absoluteString ?? "") != url.absoluteString) {
            lastUrl = url
            let request = URLRequest(url: url)
            nsView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, reqCallBack)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebViewWrapper
        
        var reqCallBack: (URLRequest)->()
        
        init(_ parent: WebViewWrapper, _ callBack:@escaping (URLRequest)->() ) {
            self.parent = parent
            self.reqCallBack = callBack
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            // 处理导航错误
            print("Navigation error: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // 处理导航动作
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
//            webView.load(navigationAction.request)
            self.reqCallBack(navigationAction.request)
            return nil;
        }
    }
}

extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
               object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}


struct ContentView_Previews: PreviewProvider {
    
    @StateObject static var viewModel = ViewModel()

    static var previews: some View {
        ContentView().frame(minWidth: 10, minHeight: 10)
            .environmentObject(viewModel)
    }
}
