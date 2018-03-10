//
//  PIWebViewController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/14/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import NJKWebViewProgress

class PIWebViewController: UIViewController, UIWebViewDelegate, UISearchControllerDelegate, UITextFieldDelegate,NJKWebViewProgressDelegate{
    
    public var url: NSURL!
    private var webView = UIWebView()
    private var webProgressView = NJKWebViewProgressView()
    private var webProgressProxy = NJKWebViewProgress()
    private var pageBackwardButton = UIBarButtonItem()
    private var pageForwardButton = UIBarButtonItem()
    private var exportPageButton = UIBarButtonItem()
    private var searchController: UISearchController!
    private var searchTextField = UITextField()
    private var searchView = UIView()
    private var secureButton = UIButton()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        //Setup view
        self.view.backgroundColor = UIColor.white
        
        //Setup NavigationBar
        self.setupNavigationBar()
        
        //Setup View
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Add ProgressBar for displaying webpage loading status
        if(url != nil){
            self.navigationController?.navigationBar.addSubview(webProgressView)
        }
        else{
            webProgressView.removeFromSuperview()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //Hide Navigation Toolbar after dismissing view
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.isToolbarHidden = true
        
        //Stop Loading Webpage after dismissing view and remove delegate
        webView.stopLoading()
        webView.delegate = nil;
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        // Remove progress view
        // because UINavigationBar is shared with other ViewControllers
        webProgressView.removeFromSuperview()
    }
    
    //Setup NavigationBar
    func setupNavigationBar(){
        //Setup Navigation Items
        let cancelButton = UIBarButtonItem(image: UIImage(named:"cancel"), style: .plain, target: self, action: #selector(self.cancelButtonPressed))
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        //Setup Save Button
        let saveBtn = UIButton.init(type: .custom)
        saveBtn.frame = CGRect(x: 0, y: 0, width: 70, height: 35)
        saveBtn.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        saveBtn.setTitleColor(UIColor.white, for: .normal)
        saveBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        saveBtn.addTarget(self, action: #selector(self.saveButtonPressed), for: .touchUpInside)
        saveBtn.backgroundColor = PIColor.primary
        saveBtn.layer.cornerRadius = 2
        saveBtn.clipsToBounds = true
        let saveButton = UIBarButtonItem(customView: saveBtn)
        self.navigationItem.rightBarButtonItem = saveButton
        
        //Setup Search TextField
        searchView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 34))
        searchView.layer.borderColor = PIColor.faintGray.cgColor
        searchView.layer.borderWidth = 1
        
        searchTextField.frame = CGRect(x: 2, y: 2, width: 196, height: 30)
        searchTextField.textColor = UIColor.darkGray
        searchTextField.tintColor = PIColor.primary
        searchTextField.backgroundColor = UIColor.white
        searchTextField.placeholder = NSLocalizedString("Enter link or search", comment: "")
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.autocorrectionType = .no
        searchTextField.autocapitalizationType = .none
        searchTextField.spellCheckingType = .no
        searchTextField.leftViewMode = .always
        searchTextField.returnKeyType = .search
        searchTextField.delegate = self
        searchTextField.becomeFirstResponder()
        secureButton = UIButton(frame: CGRect(x: 6, y: 6, width: 22, height: 22))
        if(url != nil){
            if(url.scheme == "https"){
                secureButton.setImage(UIImage(named:"secure"), for: .normal)
                searchTextField.leftView = secureButton
            }
            else{
                searchTextField.leftView = nil
            }
            searchTextField.text = url.host
        }
        else{
            searchTextField.text = nil
        }
        searchView.addSubview(searchTextField)
        self.navigationItem.titleView = searchView
    }
    
    //Setup View
    func setupView(){
        //Setup WebView
        self.setupWebView()
    }
    
    func setupWebView(){
        //Setup WebView
        webView = UIWebView(frame: self.view.frame)
        webView.delegate = self
        webView.backgroundColor = UIColor.white
        webView.scalesPageToFit = true
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.scrollView.bounces = false
        self.view.addSubview(webView)
        
        //Setup WebView Progress Bar & Set Delegates
        webProgressProxy = NJKWebViewProgress()
        webView.delegate = webProgressProxy
        webProgressProxy.webViewProxyDelegate = self
        webProgressProxy.progressDelegate = self
        
        let progressBarHeight: CGFloat = 2
        let navigationBarBounds = self.navigationController?.navigationBar.bounds
        let barFrame = CGRect(x: 0, y: (navigationBarBounds?.size.height)! - progressBarHeight, width: (navigationBarBounds?.size.width)!, height: progressBarHeight);
        webProgressView.frame = barFrame
        webProgressView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        webProgressView.progressBarView.backgroundColor = PIColor.primary
        
        //Setup WebView Toolbar
        self.setupWebViewToolbar()
        
        //Load WebView URL
        if(url != nil){
            webView.loadRequest(NSURLRequest.init(url: url as URL) as URLRequest)
        }
    }
    
    func setupWebViewToolbar(){
        //Setup Navigation Toolbar Appearance & Abilities
        self.navigationController?.isToolbarHidden = false;
        self.navigationController?.toolbar.backgroundColor = UIColor.white
        self.navigationController?.toolbar.tintColor = UIColor.lightGray
        
        //Setup Navigation Toolbar
        pageBackwardButton = UIBarButtonItem(image: UIImage(named:"back"), style: .plain, target: self, action: #selector(self.pageBackwardButtonPressed))
        pageForwardButton = UIBarButtonItem(image: UIImage(named:"forward"), style: .plain, target: self, action: #selector(self.pageForwardButtonPressed))
        exportPageButton = UIBarButtonItem(image: UIImage(named:"safari"), style: .plain, target: self, action: #selector(self.exportPageButtonPressed))
        let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let toolbarItems = [pageBackwardButton, pageForwardButton, flexibleSpaceItem, flexibleSpaceItem, flexibleSpaceItem,exportPageButton]
        
        self.navigationController?.toolbar.sizeToFit()
        self.setToolbarItems(toolbarItems, animated: false)
    }
    
    //WebView Delegates
    func webViewDidStartLoad(_ webView: UIWebView) {
        if !webProgressView.isDescendant(of: (self.navigationController?.view)!){
           self.navigationController?.navigationBar.addSubview(webProgressView)
        }
        //Hide the activity indicator in the status bar
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if(webView.canGoBack){
            pageBackwardButton.isEnabled = true
        }
        else{
            pageBackwardButton.isEnabled = false
        }
        
        if(self.webView.canGoForward){
            pageForwardButton.isEnabled = true
        }
        else{
            pageForwardButton.isEnabled = false
        }
        
        //Determine if website has SSL
        let currentURL = URL(string: (self.webView.request?.url?.absoluteString)!)
        if(currentURL?.scheme == "https"){
            secureButton.setImage(UIImage(named:"secure"), for: .normal)
            searchTextField.leftView = secureButton
        }
        else{
            searchTextField.leftView = nil
        }
        searchTextField.text = currentURL?.host
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        //Hide the activity indicator in the status bar
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        if(webView.canGoBack){
            pageBackwardButton.isEnabled = true
        }
        else{
            pageBackwardButton.isEnabled = false
        }
        
        if(self.webView.canGoForward){
            pageForwardButton.isEnabled = true
        }
        else{
            pageForwardButton.isEnabled = false
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        //Hide the activity indicator in the status bar
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        if(webView.canGoBack){
            pageBackwardButton.isEnabled = true
        }
        else{
            pageBackwardButton.isEnabled = false
        }
        
        if(self.webView.canGoForward){
            pageForwardButton.isEnabled = true
        }
        else{
            pageForwardButton.isEnabled = false
        }
        
        let code = (error as NSError).code
        if(code == NSURLErrorCancelled){
            return
        }
    }
    
    //BarButton Delegates
    func cancelButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveButtonPressed(){
        let webViewImagesVC = WebViewImagesController()
        webViewImagesVC.currentWebString = (self.webView.request?.url?.absoluteString)!
        let navVC = NavigationController(rootViewController: webViewImagesVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    func pageBackwardButtonPressed(){
        webView.goBack()
    }
    
    func pageForwardButtonPressed(){
        webView.goForward()
    }
    
    func exportPageButtonPressed(){
        //Open URL in Safari
        if #available(iOS 10.0, *) {
            UIApplication.shared.open((webView.request?.url)!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL((webView.request?.url)!)
        }
    }
    
    //NJKWebViewProgressDelegate
    func webViewProgress(_ webViewProgress: NJKWebViewProgress!, updateProgress progress: Float) {
        webProgressView.setProgress(progress, animated: true)
    }
    
    //TextField Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.loadPage(string: textField.text!)
        
        return true
    }
    
    func loadPage(string: String?){
        if (string?.hasPrefix("http://"))!{
            self.webView.loadRequest(NSURLRequest(url: NSURL(string: string!)! as URL) as URLRequest)
        }
        else if (string?.hasPrefix("www."))!{
            let finalSearchString = String(format: "http://%@", string!)
            self.webView.loadRequest(NSURLRequest(url: NSURL(string: finalSearchString)! as URL) as URLRequest)
        }
        else{
            let searchString = string?.replacingOccurrences(of: " ", with: "+")
            let googleString = "http://google.com/search?q="
            let finalSearchString = String(format: "%@%@", googleString, searchString!)
            self.webView.loadRequest(NSURLRequest(url: NSURL(string: finalSearchString)! as URL) as URLRequest)
        }
    }
}
