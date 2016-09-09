//
//  AutoDetect.swift
//  OremiaMobile2
//
//  Created by Zumatec on 08/08/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import Foundation
class AutoDetect: NSObject {
    let api = APIController()
    var ipAdress:[String] = []
    var subDomain = ""
    var cpt = 0
    var success: String->Void = {defaut->Void in }
    var failure: Bool->Void = {defaut->Void in }
    
    func getServerIpAdress(success: String->Void, failure: Bool->Void) {
        self.success = success
        self.failure = failure
        self.ipAdress = getIFAddresses()
        getSubDomain()
        if self.ipAdress.count > 0 && subDomain != ""{
            self.cpt += 1
            SimplePingHelper.ping("\(self.subDomain).\(cpt)", target: self, sel: "pingResult:")
        }
    }
    
    func pingResult(success:NSNumber){
        if cpt < 256 {
            if(success.boolValue){
                preference.ipServer = "\(self.subDomain).\(self.cpt)"
                if(checkFileupdate()){
                    self.api.updateServerAdress("\(self.subDomain).\(self.cpt)")
                    self.success("\(self.subDomain).\(self.cpt)")
                }else{
                    self.cpt += 1
                    SimplePingHelper.ping("\(self.subDomain).\(self.cpt)", target: self, sel: "pingResult:")
                }
            }else {
                cpt += 1
                SimplePingHelper.ping("\(self.subDomain).\(cpt)", target: self, sel: "pingResult:")
            }
        }else{
            self.failure(false)
        }
        
    }
    
    func getIFAddresses() -> [String] {
        var addresses = [String]()
        
        var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
        if getifaddrs(&ifaddr) == 0 {
            
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr.memory.ifa_next }
                
                let flags = Int32(ptr.memory.ifa_flags)
                var addr = ptr.memory.ifa_addr.memory
                
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        
                        var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            if let address = String.fromCString(hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return addresses
    }
    
    func getSubDomain(){
        let ip = self.ipAdress[0].characters.split{$0 == "."}.map(String.init)
        if ip.count == 4 {
            self.subDomain = "\(ip[0]).\(ip[1]).\(ip[2])"
        }
    }
    
    func checkFileupdate()->Bool{
        let urlPath = "http://\(preference.ipServer)/scripts/updater.php"
        let url: NSURL = NSURL(string: urlPath)!
        let request1: NSURLRequest = NSURLRequest(URL: url)
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil
        do{
            let dataVal = try NSURLConnection.sendSynchronousRequest(request1, returningResponse: response)
            
            return true
            
        }catch let error as NSError
        {
            
            print(error.localizedDescription)
            return false
        }
        return false
    }
}