//
//  TranslateService.swift
//  one
//
//  Created by zang qilong on 10/10/16.
//  Copyright © 2016 Super Effective. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class TranslateService: NSObject {
    let azureClientId:String = "自己的clientid"
    let azureClientSecret:String = "自己的clientscret"
    let tokenURL = "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13/"
    
    var token:String?
    var expire:NSDate?
    
    let from = "zh-CHS"
    let to = "en"
    
    func fetchBingToken() {
        let requestBody = ["client_id": azureClientId,
                           "client_secret": azureClientSecret,
                           "scope": "http://api.microsofttranslator.com",
                           "grant_type": "client_credentials"];
    
        Alamofire.request(URL(string: tokenURL)!, method: Alamofire.HTTPMethod.post, parameters: requestBody, encoding: URLEncoding.httpBody, headers: nil).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                print(value)
                if let json = value as? Dictionary<String, Any> {
                    if let value = json["access_token"] {
                        self.token = value as? String
                    }
                    let timeInterval = json["expires_in"] as! NSString
                    self.expire = NSDate.init(timeInterval: TimeInterval(timeInterval.floatValue), since: NSDate() as Date)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func convert(text:String, completion: @escaping (String) -> ()) {
        let base = "https://api.microsofttranslator.com/V2/Http.svc/Translate"
        guard let tokenExist = token else{
            print("token not exist")
            return
        }
        let header = ["Authorization": "bearer \(self.token!)"]
        
        let body = ["to": to,
                    "from": from,
                    "text": text,
                    "contentType": "text/plain"]
        
        Alamofire.request(URL(string: base)!, method: Alamofire.HTTPMethod.get, parameters: body, encoding: URLEncoding.queryString, headers: header).validate().response { (response) in
            if let dataExist = response.data {
               // print(dataExist)
                let xml:NSDictionary = XMLDictionaryParser.sharedInstance().dictionary(with: dataExist) as NSDictionary
                completion(xml.innerText() as String)
               
                
            }
        }
    }
    
}

extension String {
    func language() -> String? {
        let tagger = NSLinguisticTagger(tagSchemes: [NSLinguisticTagSchemeLanguage], options: 0)
        tagger.string = self
        return tagger.tag(at: 0, scheme: NSLinguisticTagSchemeLanguage, tokenRange: nil, sentenceRange: nil)
    }
}

