//
//  NLUILogListTableViewCell.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 23/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

class NLUILogListTableViewCell: UITableViewCell {

    @IBOutlet weak var httpStatusLbl: UILabel!
    @IBOutlet weak var urlPathLbl: UILabel!
    @IBOutlet weak var httpMethodLbl: UILabel!
    @IBOutlet weak var requestStartTimeLbl: UILabel!
    @IBOutlet weak var requestDurationLbl: UILabel!
    @IBOutlet weak var bottomDividerView: UIView!
    let dateFormatter: DateFormatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.urlPathLbl.textColor = NLUIAppColor.titleColor
        self.httpMethodLbl.textColor = UIColor.gray
        self.requestStartTimeLbl.textColor = UIColor.gray
        self.requestDurationLbl.textColor = UIColor.gray
        self.dateFormatter.dateFormat = "hh:mm:ss a"
    }
    
    func configureViews(withData data: NLLogData) {
        
        if let scheme = data.urlRequest.url?.scheme,
            let host = data.urlRequest.url?.host {
            urlPathLbl.text = "\(scheme)://\(host)\(data.urlRequest.url?.path ?? "")"
        } else {
            urlPathLbl.text = data.urlRequest.url?.absoluteString ?? "No URL found"
        }
        updateHTTPStatus(data.state, response: data.response)
        httpMethodLbl.text = data.urlRequest.httpMethod
        
        if let startDate = data.startTime {
            requestStartTimeLbl.text = dateFormatter.string(from: startDate)
        }
        else {
            requestStartTimeLbl.text = ""
        }
        
        requestDurationLbl.text = data.getDurationString()
        self.selectionStyle = UITableViewCell.SelectionStyle.none
    }
    
    private func updateHTTPStatus(_ status: NLSessionState?, response: URLResponse?) {
        
        func updateStatusLabel(color: UIColor, message: String) {
            self.httpStatusLbl.backgroundColor = color
            self.httpStatusLbl.text = message
        }
        
        func updateStatusFromResponse() {
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                if 100...299 ~= statusCode {
                    updateStatusLabel(color: NLUIHTTPStatusColor.status2xx, message: "\(statusCode)")
                } else if 300...399 ~= httpResponse.statusCode {
                    updateStatusLabel(color: NLUIHTTPStatusColor.status3xx, message: "\(statusCode)")
                } else {
                    updateStatusLabel(color: NLUIHTTPStatusColor.status4xx5xx, message: "\(statusCode)")
                }
            } else {
                updateStatusLabel(color: NLUIHTTPStatusColor.cancelled, message: "?")
            }
        }
        
        if response != nil {
            updateStatusFromResponse()
            return
        }
        
        guard let reqtStatus = status
        else {
            updateStatusLabel(color: NLUIHTTPStatusColor.cancelled, message: "?")
            return
        }
        
        switch reqtStatus {
        case .running:
            updateStatusLabel(color: NLUIHTTPStatusColor.running, message: "\u{29D6}")
        case .canceling:
            updateStatusLabel(color: NLUIHTTPStatusColor.cancelled, message: "Cancelled")
        case .suspended:
            updateStatusLabel(color: NLUIHTTPStatusColor.cancelled, message: "Suspended")
        case .unknown:
            updateStatusLabel(color: NLUIHTTPStatusColor.cancelled, message: "?")
        case .completed:
            updateStatusFromResponse()
        }
        
    }
}
