import UIKit
import WebKit
import AdjustSdk

private var Joaunode = [String]()
//internal var HuntOrderKrajs = [String()]

//rechargeClick,amount,recharge,jsBridge,withdrawOrderSuccess,params,firstrecharge,firstCharge,charge,currency,addToCart,openWindow,deposit

let Brie = Joaunode[0]              //jsBridge
let amt = Joaunode[1]     //amount
let ren = Joaunode[2]      //currency
let OpWin = Joaunode[3]      //openWindow

//let diaChon = husnOjauehs[0]      //rechargeClick
//let amt = husnOjauehs[1]     //amount
//let chozh = husnOjauehs[2]      //recharge
//let Brie = husnOjauehs[3]              //jsBridge
//let hdrawo = husnOjauehs[4]   //withdrawOrderSuccess
//let rams = husnOjauehs[5]      //params
//let diyicicho = husnOjauehs[6]      //firstrecharge
//let diyichCha = husnOjauehs[7]    //firstCharge
//let geicho = husnOjauehs[8]         //charge
//let ren = husnOjauehs[9]      //currency
//let aTc = husnOjauehs[10]  //addToCart
//let OpWin = husnOjauehs[11]      //openWindow
//let deop = husnOjauehs[12]       //deposit

extension UnaofmeyfViewController: AdjustDelegate {
    public func adjustEventTrackingSucceeded(_ eventSuccessResponse: ADJEventSuccess?) {
        print(eventSuccessResponse as Any)
    }

    public func adjustEventTrackingFailed(_ eventFailureResponse: ADJEventFailure?) {
        print(eventFailureResponse as Any)
    }
}

internal class UnaofmeyfViewController: UIViewController,WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {

    var dloein: Maheyaue?
    var vieijs: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if dloein!.wpaonre != nil {
            view.backgroundColor = UIColor.init(hexString: dloein!.wpaonre!)
        }
        
        let aaq = ADJConfig(appToken: dloein!.setrae!, environment: ADJEnvironmentProduction)
        aaq?.delegate = self
        Adjust.initSdk(aaq)
        
        Joaunode = dloein!.reioav!.components(separatedBy: ",")
//        HuntOrderKrajs = [aTc,diaChon, diyicicho, hdrawo, geicho, chozh, diyichCha, deop]
        let usrScp = WKUserScript(source: dloein!.lismpo!, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let usCt = WKUserContentController()
        usCt.addUserScript(usrScp)
        let cofg = WKWebViewConfiguration()
        cofg.userContentController = usCt
        cofg.allowsInlineMediaPlayback = true
        cofg.userContentController.add(self, name: Brie)
        cofg.defaultWebpagePreferences.allowsContentJavaScript = true
        vieijs = WKWebView(frame: .zero, configuration: cofg)
        vieijs!.allowsBackForwardNavigationGestures = true
        vieijs?.uiDelegate = self
        vieijs?.navigationDelegate = self
        view.addSubview(vieijs!)
        vieijs?.load(URLRequest(url:URL(string: dloein!.doaivu!)!))
        
        if (dloein?.msoiuns!)! > 0 {
            let btn = JuaoybView()
            btn.frame = CGRect(x: view.frame.width - 120, y: view.frame.height - 120, width: 51, height: 51)
            view.addSubview(btn)
            btn.jsoeun = { [weak self] in
//                self?.vieijs?.reload()
                self?.vieijs?.goBack()
            }
            btn.lspoiv = { [self] in
                vieijs?.load(URLRequest(url:URL(string: dloein!.doaivu!)!))
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let ws = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let statusBarManager = ws.statusBarManager {
            
            let statusBarHeight = dloein!.toisal!.contains("V") ? statusBarManager.statusBarFrame.height : 0
            let bottomHeight = dloein!.toisal!.contains("I") ? view.safeAreaInsets.bottom : 0
            vieijs?.frame = CGRectMake(0, statusBarHeight, view.bounds.width, view.bounds.height - statusBarHeight - bottomHeight)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        let ul = navigationAction.request.url
        if ((ul?.absoluteString.hasPrefix(webView.url!.absoluteString)) != nil) {
            UIApplication.shared.open(ul!)
//            webView.load(navigationAction.request)
        }
        return nil
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == Brie {
            let dic = message.body as! [String : String]
  
            WEiaoene(dic, dloein!.gdiaope!)
        }
    }
    
    override var shouldAutorotate: Bool {
        false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }
}


//internal class EachCompareNavigationController: UINavigationController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        isNavigationBarHidden = true
//    }
//    
//    override var shouldAutorotate: Bool {
//        return topViewController?.shouldAutorotate ?? super.shouldAutorotate
//    }
//
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return topViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
//    }
//}
