//
//  WKWebviewLabel.swift
//  clear-webview
//
//  Created by Lee Irvine on 5/31/19.
//  Copyright © 2019 kezzi.co. All rights reserved.
//

import UIKit
import WebKit

class WKWebviewLabel: UILabel {

    @IBInspectable var linkColor: UIColor?
    
    var innerHtml: String = ""

    private var webview: WKWebView!
    
    override init(frame: CGRect) {
        self.webview = WKWebView(frame: frame)
        super.init(frame: frame)

        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        self.webview = WKWebView(frame: CGRect.zero)
        super.init(coder: aDecoder)

        self.setup()
    }

    private func setup() {
        self.webview.alpha = 0.0
        
        guard let innerHtml = self.text else {
            return
        }
        
        self.innerHtml = innerHtml
        self.text = stripHtml(htmlString: innerHtml)
        
        self.webview.navigationDelegate = self
        self.addSubview(self.webview)
        self.webview.pinEdges(to: self)
        
        self.layoutHtml()
    }
    
    private func stripHtml(htmlString: String) -> String {
        guard let htmlStringData = htmlString.data(using: .unicode) else { fatalError() }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.unicode.rawValue
        ]
        
        let attributedHTMLString = try! NSAttributedString(data: htmlStringData, options: options, documentAttributes: nil)
        let string = attributedHTMLString.string

        return string
    }
    
    private func layoutHtml() {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.textColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        let fontSize = self.font.pointSize
        
        let style = """
            @font-face {
                font-family: '\(self.font.fontName)'; src: url('\(self.font.fontName).ttf');
            }
        
            html, body {
                font-family: \(self.font.fontName);
                color: rgba( \(Int(r*255)), \(Int(g*255)), \(Int(b*255)), \(a));
                font-size:\(fontSize)px;
                margin: 0px; padding: 0px; background-color: transparent; }
            a {
                text-decoration: none;
                color: rgba( \(Int(r*255)), \(Int(g*255)), \(Int(b*255)), \(a)); }
        """
        
        let html = """
        <html>
        <head>
            <meta name=viewport content=width=device-width, initial-scale=1>
            <style>\(style)</style>
        </head>
        <body>
            \(innerHtml)
        </body align="center">
        </html>
        """
        
        self.webview.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
        self.setNeedsDisplay()

    }

}

extension WKWebviewLabel : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webview.isOpaque = false
        self.webview.backgroundColor = .clear
        self.webview.scrollView.backgroundColor = .clear
        self.webview.scrollView.isScrollEnabled = false
        self.webview.isUserInteractionEnabled = true
        self.isUserInteractionEnabled = true
        
        self.textColor = .clear
        self.webview.alpha = 1.0
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated  {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

}
