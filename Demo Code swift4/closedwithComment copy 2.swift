//
//  closedwithComment.swift
//  qilo
//
//  Created by Abdul on 27/02/19.
//  Copyright © 2019 Qilo Technologies. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

protocol ClosedwithCommentSelectionListener:class{
    func onClosedwithCommentSelected(_ option:String)
}
class ClosedwithCommentSelectionController:UIViewController, UITextViewDelegate {
   var todoclose:Todo?
    
    weak var optionSelectionListener:ClosedwithCommentSelectionListener?
    var parentView:UIView={
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 10
        return view
    }()
    var commentLabel:UILabel={
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Enter Your Comment(Optional)"
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    var commentText:UITextView={
        let textView = UITextView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = ""
        textView.textColor = UIColor.darkGray
        textView.font = UIFont.systemFont(ofSize: 13)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.tintColor = CommonUtil.getUIColor(hexCode: Constants.UNIVERSAL_COLOR)
        return textView
    }()
    var writeMessageText: UILabel!={
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Enter your comment"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.lightGray
        return label
    }()

    private var refreshControl:UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string:"")
        refreshControl.addTarget(self, action: #selector(refreshPage), for: .valueChanged)
        return refreshControl
    }()
    var cancelButton:UIButton={
       let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(CommonUtil.getUIColor(hexCode: Constants.UNIVERSAL_COLOR), for: .normal)
        button.tintColor = UIColor.blue
        button.titleLabel?.font = .systemFont(ofSize: 14)
        return button
    }()
    var submitButton:UIButton={
        let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(CommonUtil.getUIColor(hexCode: Constants.UNIVERSAL_COLOR), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.tintColor = UIColor.blue
        
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupViews(){
        self.view.backgroundColor = UIColor.clear
        view.addSubview(parentView)
        parentView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        parentView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        parentView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        parentView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        parentView.elevate(10)
        parentView.addSubview(commentLabel)
        commentLabel.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 12).isActive = true
        commentLabel.leftAnchor.constraint(equalTo: parentView.leftAnchor, constant:12).isActive = true
        //commentLabel.centerXAnchor.constraint(equalTo: parentView.centerXAnchor).isActive = true
        parentView.addSubview(commentText)
        commentText.leftAnchor.constraint(equalTo: parentView.leftAnchor, constant:12).isActive = true
        commentText.heightAnchor.constraint(equalToConstant: 100).isActive = true
        commentText.rightAnchor.constraint(equalTo: parentView.rightAnchor, constant: -12).isActive = true
        commentText.topAnchor.constraint(equalTo: commentLabel.bottomAnchor, constant: 6).isActive = true
        commentText.delegate = self
        commentText.addSubview(writeMessageText)
        parentView.addSubview(submitButton)
        submitButton.rightAnchor.constraint(equalTo: commentText.rightAnchor).isActive = true
        submitButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        submitButton.topAnchor.constraint(equalTo: commentText.bottomAnchor, constant: 12).isActive = true
        parentView.addSubview(cancelButton)
        cancelButton.addTarget(self, action: #selector(clickAction(_:)), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(clickAction(_:)), for: .touchUpInside)
        cancelButton.rightAnchor.constraint(equalTo: submitButton.leftAnchor, constant: -12).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        cancelButton.topAnchor.constraint(equalTo: commentText.bottomAnchor, constant: 12).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        submitButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    
    private func dismisController(){
        //self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func clickAction(_ sender: Any) {
        switch sender{
        case cancelButton as UIButton:
            dismisController()
            
        case submitButton as UIButton:
            submitComment()
        default:
            break
        }
    }
    
    
    @objc private func refreshPage(){
        refreshControl.beginRefreshing()
    }
    
    func resetPage(){
        commentText.text! = ""
        dismiss(animated: true, completion: nil)
    }
    
    
    private func submitComment(){
        //todoclose = [Todo]()
        let headers = NetworkRequestBuilder.sharedInstance.addBasicHeaders()
        let commenttext = commentText.text!
        if commenttext == "" || commenttext == writeMessageText.text! {
            showError(error: "Please enter a comment")
            return
        }
        var closetodoData = CloseTodoData()
        closetodoData.action? = (todoclose?.action!)!
        closetodoData.created_by? = (todoclose?.created_by!)!
        closetodoData.todo_comment = commenttext
        closetodoData.todo_complete_dt? = (todoclose?.todo_complete_dt!)!
        closetodoData.todo_description? = (todoclose?.todo_description!)!
        closetodoData.todo_due_dt? = (todoclose?.todo_due_dt!)!
        closetodoData.todo_due_time? = (todoclose?.todo_due_time!)!
        closetodoData.todo_id? = (todoclose?.todo_id!)!
        closetodoData.todo_owner_email? = (todoclose?.todo_owner_email!)!
        closetodoData.todo_owner_id? = (todoclose?.todo_owner_id!)!
        closetodoData.todo_owner_name? = (todoclose?.todo_owner_name!)!
        closetodoData.todo_type? = (todoclose?.todo_type!)!
        closetodoData.updated_by? = (todoclose?.updated_by!)!
        closetodoData.updation_dt? = (todoclose?.updation_dt!)!
        closetodoData.who_is_asking_name? = (todoclose?.who_is_asking_name!)!
        
        
//       let user = TemporarySingleton.sharedInstance.getUserDetails()!
//        closetodoData.created_by? = user.created_by!
//        closetodoData.updated_by? = user.updated_by!
//        closetodoData.updation_dt? = user.updation_dt!
        let params = closetodoData.getData()
        let closetodoRequest = Alamofire.request(URL(string:TodoApiMethods.sharedInstance.closetodoComment())!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
        let serviceManager = WebServiceManager2.init(requests: [closetodoRequest])
        serviceManager.start { (success, error, ressponse, requestPosition) in
            debugPrint(closetodoRequest)
            debugPrint(ressponse)
                        if error != nil{
                            if self.refreshControl.isRefreshing {
                                self.refreshControl.endRefreshing()
                            }
                            debugPrint("SOME ERROR OCCURRED \(error?.localizedDescription ?? " ")")
                            if TemporarySingleton.sharedInstance.isConnectedToNetwork(){
                                self.showError(error: "Something went wrong, Please contact system admin")
                            }
                            else{
                                CommonUtil.showAlertDialog(context: self, error: Constants.youAreNotConnectedToInternet)
                            }
            
                            return
                        }
            
                            if let apiResponse = ressponse{
                                    if let data = apiResponse.result.value{
                                    if requestPosition == 0{
                                        if self.refreshControl.isRefreshing {
                                            self.refreshControl.endRefreshing()
                                        }
                                    }
                                        if let comment = Mapper<Todo>().mapArray(JSONObject:data){
                                            if comment[0].status != Constants.NO_DATA{
//                                                var comments = Todo(todoType:Constants.TODO_TYPE_WORK,todoDescription: "")
                                                if requestPosition == 0{
                                                
                                                    self.showError(error: "Done, Thank you")
                                                    self.resetPage()

                                                }
                                                else{
                                                    self.showError(error: Constants.commonErrorMessage)
                                                }
                                                
                                            }
                                            
                                        }

     }
    }
  }
}
    
 
    
    //setting the characters limit to 500
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if range.length + range.location > commentText.text.count{
            
            return false
        }
        let newlength = commentText.text.count + text.count - range.length
        return newlength <= 500
    }
    
    
    
    //private let messagePlaceHolderText = "Write a comment"
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.writeMessageText.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
    }
    
}
