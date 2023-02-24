//
//  ContentView.swift
//  Feedbackly iOS Demo
//
//  Created by Işılsu Çitim on 20.02.2023.
//

import SwiftUI
import WebKit

struct ContentView: View {
    @State var title: String = ""
    @State var error: Error? = nil
    var body: some View {
        NavigationView {
            // With GeometryReader you can set webview's frame as you wish.
            GeometryReader { geometry in
                WebView(title: $title)
                    .onLoadStatusChanged { loading, error in
                        if loading {
                            self.title = "Loading…"
                        }
                        else {
                            if let error = error {
                                self.error = error
                                if self.title.isEmpty {
                                    self.title = "Error"
                                }
                            }
                            else if self.title.isEmpty {
                                self.title = "Some Place"
                            }
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height / 3)
                    .navigationBarTitle(title)
            }
        }
        }
}

struct WebView: UIViewRepresentable {
    @Binding var title: String
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil

    func makeCoordinator() -> WebView.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        view.loadFileURL(Bundle.main.url(forResource: "demo", withExtension: "html")!, allowingReadAccessTo: Bundle.main.url(forResource: "demo", withExtension: "html")!)
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }

    func onLoadStatusChanged(perform: ((Bool, Error?) -> Void)?) -> some View {
        var copy = self
        copy.loadStatusChanged = perform
        return copy
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.loadStatusChanged?(true, nil)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("survey loaded")
            // Remove survey close button
            webView.evaluateJavaScript("FBLY.action('setOptions', {hideCloseButton: true})")
            // Add Metadata
            webView.evaluateJavaScript("FBLY.addMeta('userAge', '25')")
            // Web widget hooks
            webView.evaluateJavaScript("""
                    FBLY.action('onSurveyLoaded', () => {
                        console.log("onSurveyLoaded")
                    })

                    FBLY.action('onClose', () => {
                        console.log("onClose")
                        FBLY.clearProperties()
                        FBLY.clearMeta()
                    })

                    FBLY.action('onSurveyFinished', () => {
                        console.log("onSurveyFinished")
                        FBLY.clearProperties()
                        FBLY.clearMeta()
                    })
            """)
            parent.title = webView.title ?? ""
            parent.loadStatusChanged?(false, nil)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.loadStatusChanged?(false, error)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
