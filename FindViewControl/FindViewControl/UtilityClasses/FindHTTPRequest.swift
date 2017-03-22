//
//  FindHTTPRequest.swift
//  LAFDBrush
//
//  Created by KahunaOSx on 1/28/16.
//  Copyright © 2016 Kahuna Systems Pvt. Ltd. All rights reserved.
//

import UIKit
import Alamofire

protocol FindHTTPRequestDelegate: class {

    func httpRequest(_ requestHandler: FindHTTPRequest, requestCompletedWithResponseJsonObject jsonObject: AnyObject, forPath path: String)
    func httpRequest(_ requestHandler: FindHTTPRequest, requestFailedWithError failureError: Error, forPath path: String)
}

class FindHTTPRequest {

    static let sharedInstance = FindHTTPRequest()
    weak var delegate: FindHTTPRequestDelegate?
    var alamofireManager = Alamofire.SessionManager.default

    init() {

    }

    // MARK: - POST TO PATH

    func sendRequestAtPath(_ path: String, withParameters parameters: [String: AnyObject]?, timeoutInterval interval: Int) {

        var requestString = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters!, options: JSONSerialization.WritingOptions.prettyPrinted)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            print("\n\n Request : \(jsonString)")
            requestString = "Request : \(jsonString)"
        } catch let error as NSError {
            print(error)
        }

        self.alamofireManager.session.configuration.timeoutIntervalForRequest = TimeInterval(interval) // seconds
        self.alamofireManager.session.configuration.timeoutIntervalForResource = TimeInterval(interval)
        self.alamofireManager.session.configuration.httpMaximumConnectionsPerHost = 10

        let tokenToSet = ""
        let authheader = [ "Authorization": tokenToSet]

        Alamofire.request(path, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: authheader) .downloadProgress { progress in
            let percent = progress.completedUnitCount / progress.totalUnitCount
            print("percent DataReceived=============> \(percent)")

        }
            .responseJSON { response in

                let responseData = response.data as Data?

                let resultText = NSString(data: responseData!, encoding: String.Encoding.utf8.rawValue)

                print("\nPath :\(path) \n\n\(requestString)\n\nResponse :\(resultText)\n\n")

                if responseData == nil {

                    self.handleError(Constants.UnidentifiedError.emptyHTTPResponse, forPath: path)
                }
                    else if let error = response.error {
                   
                    self.handleError(error, forPath: path)
                }
                    else {
                    do {

                        let jsonObject = try JSONSerialization.jsonObject(with: responseData!, options: JSONSerialization.ReadingOptions(rawValue: 0))

                        self.handleResponse(jsonResponse: jsonObject as AnyObject, forPath: path)
                    }
                    catch let JSONError as NSError {
                        self.handleError(JSONError, forPath: path)
                    }
                }
        }
    }

    // MARK: - GET TO PATH

    func sendGetRequestAtPath(_ path: String, withParameters parameters: [String: AnyObject]?, timeoutInterval interval: Int) {

        print("\n\nURL: \(path)")

        Alamofire.request(path, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in

            let responseData = response.data as Data?
            let resultText = NSString(data: responseData!, encoding: String.Encoding.utf8.rawValue)
            print("GET Result :\(resultText)")

            if responseData == nil {
                self.handleError(Constants.UnidentifiedError.emptyHTTPResponse, forPath: path)
            }
                else if let error = response.error {
                self.handleError(error, forPath: path)
            }
                else {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: responseData!, options: JSONSerialization.ReadingOptions(rawValue: 0))
                    self.handleResponse(jsonResponse: jsonObject as AnyObject, forPath: path)
                }
                catch let JSONError as NSError {
                    self.handleError(JSONError, forPath: path)
                }
            }
        }
    }

    func documentDirectoryFilePath() -> String {
        let folderPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
        return folderPath as String
    }

   
    // MARK: - HANDLE RESPONSE AND ERROR

    func handleResponse(jsonResponse response: AnyObject, forPath path: String) {
        self.delegate?.httpRequest(self, requestCompletedWithResponseJsonObject: response, forPath: path)
    }

    func handleError(_ error: Error, forPath path: String) {
        self.delegate?.httpRequest(self, requestFailedWithError: error, forPath: path)
    }

   
    func getCurrentDate() -> String {
        let date = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        var dateString = dateFormatter.string(from: date)
        dateString = dateString.replacingOccurrences(of: " ", with: "T")

        return dateString
    }

    func getFormattedDateForServerTime(_ receivedDateString: String) -> String {
        let dateStringRe = "\(receivedDateString)"

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "US_en")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSzzz"
        let dateNew = formatter.date(from: dateStringRe)

        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var dateString = formatter.string(from: dateNew!)
        dateString = dateString.replacingOccurrences(of: " ", with: "T")
        return dateString
    }

    func cancelAllRequests() {
        self.alamofireManager.session.getTasksWithCompletionHandler {
            (dataTasks, uploadTasks, downloadTasks) -> Void in

            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
    }

}
