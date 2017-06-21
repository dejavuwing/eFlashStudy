//
//  youtubeWebController.swift
//  eFlashStudy
//
//  Created by nGle on 2017. 6. 20..
//  Copyright © 2017년 Tongchun. All rights reserved.
//

import UIKit
import WebKit

class YoutubeWebController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    var webView = WKWebView()
    var progressBar: UIProgressView!
    var selectedChannel: String!

    var viewUrl: String = "https://www.youtube.com/channel/"

    override func viewDidLoad() {
        super.viewDidLoad()

        viewUrl += selectedChannel
        webView = WKWebView(frame: CGRect(x:0, y:65, width: self.view.frame.width, height: self.view.frame.height))

        let myURL = URL(string: viewUrl)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        view.addSubview(webView)

        progressBar = UIProgressView(frame: CGRect(x: 0, y: 64, width: self.view.frame.width, height: 50))
        progressBar.progress = 0.0
        progressBar.tintColor = UIColor.red
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        view.addSubview(progressBar)

        self.view.addSubview(webView)
        addPullToRefreshToWebView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {

            progressBar.alpha = 1.0
            progressBar.progress = Float(webView.estimatedProgress)

            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, //Time duration you want,
                    delay: 0.1,
                    options: [.curveEaseInOut],
                    animations: { () -> Void in
                        self.progressBar.alpha = 0.0},
                    completion: { (finished: Bool) -> Void in
                        self.progressBar.progress = 0})
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }

    @IBAction func goToBack(_ sender: UIBarButtonItem) {
        webView.goBack()
    }

    // 땡겨서 refresh
    func addPullToRefreshToWebView(){
        let refreshController: UIRefreshControl = UIRefreshControl()

        refreshController.bounds = CGRect(x: 0, y: 50, width: refreshController.bounds.size.width, height: refreshController.bounds.size.height)
        refreshController.addTarget(self, action: #selector(YoutubeWebController.refreshWebView(_:)), for: UIControlEvents.valueChanged)
        refreshController.attributedTitle = NSAttributedString(string: "Pull down to refresh...")
        webView.scrollView.addSubview(refreshController)
    }

    func refreshWebView(_ refresh: UIRefreshControl){
        webView.reload()
        refresh.endRefreshing()
    }

}
