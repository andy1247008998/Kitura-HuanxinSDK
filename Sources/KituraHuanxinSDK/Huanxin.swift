//
// Created by ailion on 17-9-24.
//

//import Kitura
import KituraNet
import KituraRequest
//import HeliumLogger
import LoggerAPI
import SwiftyJSON
import Foundation

class Huanxin{

    var domain:String
    var orgName:String
    var appName:String
    var baseURL:String

    var client_id:String
    var client_secret:String

    var token:HuanxinToken?

    init(domain:String, orgName:String, appName:String, client_id:String, client_secret:String) {
        self.domain = domain
        self.orgName = orgName
        self.appName = appName
        self.baseURL = "\(domain)/\(orgName)/\(appName)"

        self.client_id = client_id
        self.client_secret = client_secret
    }

    func parseHuanxinResponse(data:Data?) -> HuanxinResponse{
        let json = JSON(data: data!)
        //print("json = \(json)")
        let action = json["action"].rawString()
        let application = json["application"].rawString()

        var params: [String] = []
        if json["params"].isEmpty {

        } else {
            for (index, param) in json["params"] {
                let paramsString = param.stringValue
                params.append(paramsString)
            }
        }

        let path = json["path"].rawString()
        let uri = json["uri"].rawString()

        var entities: [String: String] = [:]
        let entitiesDict = json["entities"]
        if entitiesDict.isEmpty {

        } else {
            for (key, value) in entitiesDict {
                entities[key] = value.rawString()
            }
        }



        var data: [String] = []
        if json["data"].isEmpty {

        } else {
            for (index, user) in json["data"] {
                let userString = user.stringValue
                data.append(userString)
            }
        }

        //print("data = \(data)")

        let timestamp = json["timestamp"].int
        let duration = json["duration"].int
        let organization = json["organization"].rawString()
        let applicationName = json["applicationName"].rawString()
        let count = json["count"].int

        let huanxinResponse = HuanxinResponse(action: action, application: application, params: params, path: path, uri: uri, entities: entities, timestamp: timestamp, duration: duration, organization: organization, applicationName: applicationName, count: count)
        return huanxinResponse
    }

    func getToken(result:@escaping(HuanxinToken?)->()){

        if let token = self.token {
            if let _ = token.access_token {
                if let expires_in = token.expires_in {
                    if expires_in > 600 {
                        result(self.token)
                        return
                    }
                }
            }
        }

        KituraRequest.request(.post,
                "\(self.baseURL)/token",
                parameters: [
                    "grant_type": "client_credentials",
                    "client_id": "\(client_id)",
                    "client_secret": "\(client_secret)",
                ],
                encoding: JSONEncoding.default,
                headers: ["Content-Type": "application/json"]
        ).response {
            request, response, data, error in
            // do something with data
            let json = JSON(data: data!)
            let access_token = json["access_token"].rawString()
            let expires_in = json["expires_in"].int
            let application = json["application"].rawString()
            let token: HuanxinToken? = HuanxinToken(access_token: access_token, expires_in: expires_in, application: application)
            self.token = token
            //print("token is = \(token)")
            result(token)
        }

    }

    func registerUser(username:String, password:String, nickname:String?, withToken:Bool,result:@escaping(HuanxinResponse,HuanxinError?)->()){

        getToken(){ token in

            let headers: [String: String]
            if (withToken == true) {
                headers = [
                    "Content-Type": "application/json",
                    "Authorization": "Bearer \(token!.access_token!)"
                ]
            } else {
                headers = [
                    "Content-Type": "application/json"
                ]
            }

            KituraRequest.request(.post,
                    "\(self.baseURL)/users",
                    parameters: [
                        "grant_type": "client_credentials",
                        "username": "\(username)",
                        "password": "\(password)",
                    ],
                    encoding: JSONEncoding.default,
                    headers: headers
            ).response {
                request, response, data, error in

                // do something with data
                let huanxinResponse = self.parseHuanxinResponse(data: data)
                result(huanxinResponse, nil)
            }
        }
    }


//    func registerMultipleUsers(users:[HuanxinUser], nickname:String?, withToken:Bool,result:@escaping(HuanxinResponse,HuanxinError?)->()){
//        getToken() { token in
//            KituraRequest.request(.post,
//                    "\(self.baseURL)/users",
//                    parameters: [
//                        "grant_type": "client_credentials",
//                        //users
//                    ],
//                    encoding: JSONEncoding.default,
//                    headers: [
//                        "Content-Type": "application/json",
//                        "Authorization": "Bearer \(token!)"
//                    ]
//            ).response {
//                request, response, data, error in
//                // do something with data
//                let huanxinResponse = self.parseHuanxinResponse(data: data)
//                result(huanxinResponse, nil)
//            }
//        }
//    }

    func getUser(username:String, result:@escaping(HuanxinResponse,HuanxinError?)->()){
        getToken() { token in
            KituraRequest.request(.get,
                    "\(self.baseURL)/users/\(username)",
                    headers: ["Authorization": "Bearer \(token!)"]
            ).response {
                request, response, data, error in

                // do something with data
                let huanxinResponse = self.parseHuanxinResponse(data: data)
                result(huanxinResponse, nil)
            }
        }
    }

    func huanxinGetUsersCompleted(limit:Int, cursor:String?, result:@escaping(HuanxinResponse,HuanxinError?)->()){
        getToken() { token in
            KituraRequest.request(.get,
                    "\(self.baseURL)/users",
                    parameters: [
                        "limit":"\(limit)"
                    ],
                    headers: ["Authorization":"Bearer \(token!)"]
            ).response {
                request, response, data, error in

                // do something with data
                let huanxinResponse = self.parseHuanxinResponse(data: data)
                result(huanxinResponse, nil)
            }
        }
    }

    func deleteUser(username:String, result:@escaping(HuanxinResponse,HuanxinError?)->()) {
        getToken() { token in
            KituraRequest.request(.delete,
                    "\(self.baseURL)/users/\(username)",
                    headers: ["Authorization": "Bearer \(token!)"]
            ).response {
                request, response, data, error in
                // do something with data
                let huanxinResponse = self.parseHuanxinResponse(data: data)
                result(huanxinResponse, nil)
            }
        }
    }

    func resetPassword(username:String,password:String, result:@escaping(HuanxinResponse,HuanxinError?)->()){
        getToken() { token in
            KituraRequest.request(.put,
                    "\(self.baseURL)/users/\(username)/password",
                    parameters: [
                        "newpassword": "\(password)"
                    ],
                    headers: ["Authorization": "Bearer \(token!)"]
            ).response {
                request, response, data, error in
                // do something with data
                let huanxinResponse = self.parseHuanxinResponse(data: data)
                result(huanxinResponse, nil)
            }
        }
    }

    func resetNickname(username:String,nickname:String, result:@escaping(HuanxinResponse,HuanxinError?)->()){
        getToken() { token in
            KituraRequest.request(.put,
                    "\(self.baseURL)/users/\(username)",
                    parameters: [
                        "nickname": "\(nickname)"
                    ],
                    headers: ["Authorization": "Bearer \(token!)"]
            ).response {
                request, response, data, error in
                // do something with data
                let huanxinResponse = self.parseHuanxinResponse(data: data)
                result(huanxinResponse, nil)
            }
        }
    }


    func addFriend(owner_username:String,friend_username:String, result:@escaping(HuanxinResponse,HuanxinError?)->()){
        getToken() { token in
            KituraRequest.request(.post,
                    "\(self.baseURL)/users/\(owner_username)/contacts/users/\(friend_username)",
                    headers: ["Authorization": "Bearer \(token!)"]
            ).response {
                request, response, data, error in
                // do something with data
                let huanxinResponse = self.parseHuanxinResponse(data: data)
                result(huanxinResponse, nil)
            }
        }
    }

    func removeFriend(owner_username:String,friend_username:String, result:@escaping(HuanxinResponse,HuanxinError?)->()){
        getToken() { token in
            KituraRequest.request(.delete,
                    "\(self.baseURL)/users/\(owner_username)/contacts/users/\(friend_username)",
                    headers: ["Authorization": "Bearer \(token!)"]
            ).response {
                request, response, data, error in
                // do something with data
                let huanxinResponse = self.parseHuanxinResponse(data: data)
                result(huanxinResponse, nil)
            }
        }
    }

    func getContactList(owner_username:String, result:@escaping(HuanxinResponse,HuanxinError?)->()){
        getToken() { token in
            KituraRequest.request(.get,
                    "\(self.baseURL)/users/\(owner_username)/contacts/users",
                    headers: ["Authorization": "Bearer \(token!.access_token!)"]
            ).response {
                request, response, data, error in

                // do something with data
                let huanxinResponse = self.parseHuanxinResponse(data: data)
                result(huanxinResponse, nil)
            }
        }
    }

    func getBlockedUserList(owner_username:String, result:@escaping(HuanxinResponse,HuanxinError?)->()){
        getToken() { token in
            KituraRequest.request(.get,
                    "\(self.baseURL)/users/\(owner_username)/blocks/users",
                    headers: ["Authorization": "Bearer \(token!)"]
            ).response {
                request, response, data, error in
                // do something with data
                let huanxinResponse = self.parseHuanxinResponse(data: data)
                result(huanxinResponse, nil)
            }
        }
    }

    func addBlockedUser(owner_username:String, blocked_users:[String], result:@escaping(HuanxinResponse,HuanxinError?)->()){
        getToken() { token in
            KituraRequest.request(.post,
                    "\(self.baseURL)/users/\(owner_username)/blocks/users",
                    parameters: [
                        "usernames": "\(blocked_users)"
                    ],
                    headers: ["Authorization": "Bearer \(token!)"]
            ).response {
                request, response, data, error in
                // do something with data
                let huanxinResponse = self.parseHuanxinResponse(data: data)
                result(huanxinResponse, nil)
            }
        }
    }

    func huanxinRemoveBlockedUserCompleted(owner_username:String, blocked_username:String, result:@escaping(HuanxinResponse,HuanxinError?)->()){
        getToken() { token in
            KituraRequest.request(.delete,
                    "\(self.baseURL)/users/\(owner_username)/blocks/users/\(blocked_username)",
                    headers: ["Authorization": "Bearer \(token!)"]
            ).response {
                request, response, data, error in
                // do something with data
                let huanxinResponse = self.parseHuanxinResponse(data: data)
                result(huanxinResponse, nil)
            }
        }
    }

    func getUserStatus(username:String, result:@escaping(HuanxinResponse,HuanxinError?)->()){
        getToken() { token in
            KituraRequest.request(.get,
                    "\(self.baseURL)/users/\(username)/status",
                    headers: [
                        "Content-Type": "application/json",
                        "Authorization": "Bearer \(token!)"
                    ]
            ).response {
                request, response, data, error in
                // do something with data
                let huanxinResponse = self.parseHuanxinResponse(data: data)
                result(huanxinResponse, nil)
            }
        }
    }

    func getUserOfflineMessageCount(username:String, result:@escaping(HuanxinResponse,HuanxinError?)->()){
        getToken() { token in
            KituraRequest.request(.get,
                    "\(self.baseURL)/users/\(username)/offline_msg_count",
                    headers: [
                        "Content-Type": "application/json",
                        "Authorization": "Bearer \(token!)"
                    ]
            ).response {
                request, response, data, error in
                // do something with data
                let huanxinResponse = self.parseHuanxinResponse(data: data)
                result(huanxinResponse, nil)
            }
        }
    }

    func getUserOfflineMessageStatus(username:String, message_id:Int, result:@escaping(HuanxinResponse,HuanxinError?)->()){
        getToken() { token in
            KituraRequest.request(.get,
                    "\(self.baseURL)/users/\(username)/offline_msg_status\(message_id)",
                    headers: [
                        "Content-Type": "application/json",
                        "Authorization": "Bearer \(token!)"
                    ]
            ).response {
                request, response, data, error in
                // do something with data
                let huanxinResponse = self.parseHuanxinResponse(data: data)
                result(huanxinResponse, nil)
            }
        }
    }

    func deactivateUser(username:String, result:@escaping(HuanxinResponse,HuanxinError?)->()){
        getToken() { token in
            KituraRequest.request(.post,
                    "\(self.baseURL)/users/\(username)/deactivate",
                    headers: [
                        "Content-Type": "application/json",
                        "Authorization": "Bearer \(token!)"
                    ]
            ).response {
                request, response, data, error in
                // do something with data
                let huanxinResponse = self.parseHuanxinResponse(data: data)
                result(huanxinResponse, nil)
            }
        }
    }

    func activateUser(username:String, result:@escaping(HuanxinResponse,HuanxinError?)->()){
        getToken() { token in
            KituraRequest.request(.post,
                    "\(self.baseURL)/users/\(username)/deactivate",
                    headers: [
                        "Content-Type": "application/json",
                        "Authorization": "Bearer \(token!)"
                    ]
            ).response {
                request, response, data, error in
                // do something with data
                let huanxinResponse = self.parseHuanxinResponse(data: data)
                result(huanxinResponse, nil)
            }
        }
    }

    func disconnectUser(username:String, result:@escaping(HuanxinResponse,HuanxinError?)->()){
        getToken() { token in
            KituraRequest.request(.get,
                    "\(self.baseURL)/users/\(username)/disconnect",
                    headers: [
                        "Content-Type": "application/json",
                        "Authorization": "Bearer \(token!)"
                    ]
            ).response {
                request, response, data, error in
                // do something with data
                let huanxinResponse = self.parseHuanxinResponse(data: data)
                result(huanxinResponse, nil)
            }
        }
    }
}
