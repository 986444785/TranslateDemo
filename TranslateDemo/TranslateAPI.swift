//
//  TranslateAPI.swift
//  TranslateDemo
//
//  Created by zang qilong on 10/11/16.
//  Copyright © 2016 zang qilong. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

private let azureClientId:String = "co_s12e_one_dev"
private let azureClientSecret:String = "P/f+PIcfR6nwZt4m00OSgq+aFh/9WVwabpdvccZHIBM="
private let fromLanguage = "zh-CHS"
private let toLanguage = "en"

enum TranslateError:Error {
    case URLInvalied
    case ResultNotExist
}

enum TranslateAPI {
    case Token
    case Translate(text:String)
    
    var path:String {
        switch self {
        case .Token:
            return "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13/"
        case .Translate:
            return "https://api.microsofttranslator.com/V2/Http.svc/Translate"
        }
    }
    
    var method:HTTPMethod {
        switch self {
        case .Token:
            return HTTPMethod.post
            
        case .Translate:
            return HTTPMethod.get
        }
    }
    
    var body:[String: Any] {
        switch self {
        case .Token:
            return ["client_id": azureClientId,
                    "client_secret": azureClientSecret,
                    "scope": "http://api.microsofttranslator.com",
                    "grant_type": "client_credentials"]
        case .Translate(let text):
            return ["to": toLanguage,
                    "from": fromLanguage,
                    "text": text,
                    "contentType": "text/plain"]
        }
    }
    
}

extension TranslateAPI: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        let url = try self.path.asURL()
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        switch self {
        case .Token:
            urlRequest = try URLEncoding.httpBody.encode(urlRequest, with: body)
        case .Translate(_):
            urlRequest = try URLEncoding.queryString.encode(urlRequest, with: body)
        }
        
        return urlRequest
    }
}

class AccessTokenAdapter: RequestAdapter {
    private let accessToken: String
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        guard let url = urlRequest.url else {
            throw TranslateError.URLInvalied
        }
        
        if url.absoluteString.hasPrefix("https://api.microsofttranslator.com") {
            urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        }
        
        return urlRequest
    }
}

class TranslateHandler {
    static let sharedInstance = TranslateHandler()
    
    private let sessionManager = SessionManager()
    private var tokenAdapter:AccessTokenAdapter?
    
    private init() {
   
    }
    
    func detectChinese(text:String?) -> Bool {
        guard let textExist = text else {
            return false
        }
        for word in textExist.characters {
            let scalers = String(word).unicodeScalars
            
            let unicode = scalers[scalers.startIndex].value
            
            if TextDrawable.isIdeographic(value: unicode) {
                return true
            }
        }
        return false
    }
    
    func fetchToken() {
        sessionManager.request(TranslateAPI.Token).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                UserDefaults.standard.saveTranslateToken(json["access_token"].string)
                if let token = UserDefaults.standard.getTranslateToken() {
                    self.tokenAdapter = AccessTokenAdapter(accessToken: token)
                    self.sessionManager.adapter = self.tokenAdapter
                }
                let timeSeconds = json["expires_in"].string
                if let seconds = timeSeconds {
                    let expireDate = Date(timeInterval: (seconds as NSString).doubleValue, since: Date())
                    UserDefaults.standard.saveExpiresTime(expireDate)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func translate(text:String, completion: @escaping (_ result:String) -> ()) -> Void {
        sessionManager.request(TranslateAPI.Translate(text: text)).validate().response { (response) in
            guard let data = response.data else {
                //throw TranslateError.ResultNotExist
                return
            }
            
            let xml:NSDictionary = XMLDictionaryParser.sharedInstance().dictionary(with: data) as NSDictionary
            completion(xml.innerText() as String)
        }
    }
}

private let tokenKey = "TranslateToken"
private let expireTimeKey = "TranslateTokenExpireTime"
extension UserDefaults {
    
    func saveTranslateToken(_ token:String?) {
        UserDefaults.standard.setValue(token, forKey: tokenKey)
        UserDefaults.standard.synchronize()
    }
    
    func getTranslateToken() -> String? {
        return UserDefaults.standard.value(forKey: tokenKey) as? String
    }
    
    func saveExpiresTime(_ time:Date) {
        UserDefaults.standard.setValue(time, forKey: expireTimeKey)
        UserDefaults.standard.synchronize()
    }
    
    func getExpireTime() -> Date? {
        return UserDefaults.standard.value(forKey: expireTimeKey) as? Date
    }
}
