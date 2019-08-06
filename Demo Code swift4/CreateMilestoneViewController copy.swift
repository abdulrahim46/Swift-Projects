//
//  CreateMilestoneViewController.swift
//  qilo
//
//  Created by Himanshu on 14/08/18.
//  Copyright © 2018 Qilo Technologies. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire
public protocol CreateMilestoneEventListener:class{
    func milestoneCreated()
}
class CreateMilestoneViewController: BaseViewController {
    var milestone:Milestone?
    var goalSetting:GoalSettingDetails?
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var viewGoalPicker: UITextField!
    @IBOutlet weak var goalPickerViewBottomLine: UIView!
    @IBOutlet weak var tfMilestone: UITextField!
    @IBOutlet weak var tfAssignee: UITextField!
    @IBOutlet weak var tfStartDate: UITextField!
    @IBOutlet weak var tfEndDate: UITextField!
    @IBOutlet weak var rbProgress: RadioButton!
    @IBOutlet weak var rbMetric: RadioButton!
    @IBOutlet weak var rbTask: RadioButton!
    @IBOutlet weak var tvManageTaskAlert: UITextView!
    @IBOutlet weak var lbStartDate: UILabel!
    @IBOutlet weak var lbEndDate: UILabel!
    @IBOutlet weak var lbStartValue: UILabel!
    @IBOutlet weak var lbTargetValue: UILabel!
    @IBOutlet weak var tfStartValue: UITextField!
    @IBOutlet weak var tfTargetValue: UITextField!
    @IBOutlet weak var stackFooterButtons: UIStackView!
    @IBOutlet weak var cnstrntFoortButtons: NSLayoutConstraint!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnCreate: UIButton!
    private var defaultColor : UIColor?
    @IBOutlet weak var metricStartValueBottomLine: UIView!
    @IBOutlet weak var metricTargetValueBottomLine: UIView!
    private let htFooterButtons = 60
    var orgMilestoneName = "Milestone"
    var mGoals:[Goal] = []
    var select:[String] = ["At Least", "At Most", "In Range Of"]
    var goalName:String?
    private var activityIndicator:ActivityIndicator?
    weak var eventListener:CreateMilestoneEventListener?
    var milestoneType = Constants.MILESTONE_PROGRESS_TYPE_PERCENTAGE
    var selectedGoal:Goal?
    //var button = dropDownBtn()
    var manageTaskAlert = "You can add tasks in milestone by selecting manage task from milestone menu option"
    var users:[UserDetails] = []
    var assignee:UserDetails?
    @IBOutlet weak var tvMilestoneTypeWarning: UITextView!
    var goalTableView:UITableView = {
       let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width - 24, height: 0))
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.masksToBounds = true
        tableView.layer.shadowOpacity = 0.5
        tableView.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        tableView.layer.shadowColor = UIColor.gray.cgColor
        tableView.separatorStyle = .none
        return tableView
    }()
    var assigneeTableView:UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width - 24, height: 0))
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.masksToBounds = true
        tableView.layer.shadowOpacity = 0.5
        tableView.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        tableView.layer.shadowColor = UIColor.gray.cgColor
        return tableView
    }()
    
    var metricTargetswitchContainer:UIView={
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.clipsToBounds = true
        return view
    }()
    var lbMetricTargetOption:UILabel={
       let label = UILabel.init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Metric Target Option"
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.backgroundColor = UIColor.clear
        return label
    }()
    var tfMetricTragetOption:UITextField={
       let textField = UITextField.init()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textField.tintColor = UIColor.white
        return textField
    }()
    var dividerView:UIView={
       let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray
        return view
    }()

    var btnMetricTargetOptionsInfo:UIButton = {
        let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        orgMilestoneName = (TemporarySingleton.sharedInstance.getOrgDetails()?.milestoneName)!
        manageTaskAlert = "You can add tasks in \(orgMilestoneName) by selecting manage task from \(orgMilestoneName) menu option"
        hideKeyboardWhenTappedAround()
        goalName = (TemporarySingleton.sharedInstance.getOrgDetails()?.goalName)!
        setupViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.setChildNavigationController(title: "Create \(orgMilestoneName)")
        getGoals()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        UIView.transition(with: stackFooterButtons, duration: 0.5, options: .showHideTransitionViews, animations: {
            
        }) { (true) in
            self.cnstrntFoortButtons.constant = 0
            self.stackFooterButtons.isHidden = true
        }
        self.view.setNeedsLayout()
        //self.scrollView.layoutIfNeeded()
       
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.viewDidLayoutSubviews()
    }
    private func setupViews(){
        scrollView.delegate = self
         activityIndicator = ActivityIndicator.init(self.view)
        tfMilestone.placeholder = "Enter name of \(orgMilestoneName)"
        tvMilestoneTypeWarning.text = "How will you measure \(orgMilestoneName) progress?"
        viewGoalPicker.text = "Select "+goalName!
        defaultColor = CommonUtil.getUIColor(hexCode: Constants.UNIVERSAL_COLOR)
        viewGoalPicker.tintColor = defaultColor
        tfEndDate.tintColor = UIColor.clear
        tfStartDate.tintColor = UIColor.clear
        lbStartDate.textColor = defaultColor
        lbEndDate.textColor = defaultColor
        lbStartDate.isHidden = true
        lbEndDate.isHidden = true
        metricTargetswitchContainer.isHidden = true
        tfMilestone.tintColor = defaultColor
        tfAssignee.tintColor = defaultColor
        tfAssignee.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        tfStartValue.tintColor = defaultColor
        tfTargetValue.tintColor = defaultColor
        tfStartValue.placeholder = ""
        tfTargetValue.placeholder = ""
        btnCancel.backgroundColor = defaultColor!
        btnCreate.backgroundColor = defaultColor!
        rbProgress.backgroundColor = UIColor.clear
        rbMetric.backgroundColor = UIColor.clear
        rbTask.backgroundColor = UIColor.clear
        rbProgress.setTitleColor(UIColor.gray, for: .normal)
        rbProgress.setTitleColor(defaultColor, for: .selected)
        rbMetric.setTitleColor(UIColor.gray, for: .normal)
        rbMetric.setTitleColor(defaultColor, for: .selected)
        rbTask.setTitleColor(UIColor.gray, for: .normal)
        rbTask.setTitleColor(defaultColor, for: .selected)
        rbProgress.isSelected = true
        tvManageTaskAlert.isHidden = true
        showMetricView(false)
        contentView.addSubview(goalTableView)
        goalTableView.backgroundColor = UIColor.white
        //goalTableView.separatorStyle = .none
        goalTableView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        goalTableView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        goalTableView.topAnchor.constraint(equalTo: goalPickerViewBottomLine.bottomAnchor).isActive = true
        goalTableView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        goalTableView.isHidden = true
        
        contentView.addSubview(assigneeTableView)
        assigneeTableView.backgroundColor = UIColor.white
        assigneeTableView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        assigneeTableView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        assigneeTableView.topAnchor.constraint(equalTo: tfAssignee.bottomAnchor,constant:2).isActive = true
        assigneeTableView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        assigneeTableView.isHidden = true
        
        contentView.addSubview(metricTargetswitchContainer)
        metricTargetswitchContainer.isHidden = true
        metricTargetswitchContainer.topAnchor.constraint(equalTo: tfTargetValue.bottomAnchor, constant: 8).isActive = true
        metricTargetswitchContainer.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant:-24).isActive = true
        metricTargetswitchContainer.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant:24).isActive = true
        metricTargetswitchContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        //metricTargetswitchContainer.heightAnchor.constraint(equalToConstant: 200).isActive = true
        metricTargetswitchContainer.clipsToBounds = true
        metricTargetswitchContainer.addSubview(lbMetricTargetOption)
        lbMetricTargetOption.leftAnchor.constraint(equalTo: metricTargetswitchContainer.leftAnchor).isActive = true
        lbMetricTargetOption.topAnchor.constraint(equalTo: metricTargetswitchContainer.topAnchor,constant: 4).isActive = true
        lbMetricTargetOption.heightAnchor.constraint(equalToConstant: 30).isActive = true
        lbMetricTargetOption.widthAnchor.constraint(equalToConstant: 160).isActive = true
        metricTargetswitchContainer.addSubview(btnMetricTargetOptionsInfo)
        btnMetricTargetOptionsInfo.leftAnchor.constraint(equalTo: lbMetricTargetOption.rightAnchor).isActive = true
        btnMetricTargetOptionsInfo.widthAnchor.constraint(equalToConstant: 30).isActive = true
        btnMetricTargetOptionsInfo.heightAnchor.constraint(equalToConstant: 30).isActive = true
        btnMetricTargetOptionsInfo.topAnchor.constraint(equalTo: lbMetricTargetOption.topAnchor).isActive = true
        btnMetricTargetOptionsInfo.setImage(UIImage.init(named: "ic_info")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnMetricTargetOptionsInfo.tintColor = UIColor.lightGray
                btnMetricTargetOptionsInfo.addTarget(self, action: #selector(showInfotext), for: .touchUpInside)
        metricTargetswitchContainer.addSubview(tfMetricTragetOption)
        tfMetricTragetOption.leftAnchor.constraint(equalTo: lbMetricTargetOption.leftAnchor).isActive = true
        tfMetricTragetOption.rightAnchor.constraint(equalTo: metricTargetswitchContainer.rightAnchor).isActive = true
        tfMetricTragetOption.topAnchor.constraint(equalTo: lbMetricTargetOption.bottomAnchor, constant: 4).isActive = true
        tfMetricTragetOption.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnMetricTargetOptionsInfo.bottomAnchor.constraint(equalTo: lbMetricTargetOption.bottomAnchor).isActive = true
        tfMetricTragetOption.delegate = self
        metricTargetswitchContainer.addSubview(dividerView)
        dividerView.leftAnchor.constraint(equalTo: tfMetricTragetOption.leftAnchor).isActive = true
        dividerView.rightAnchor.constraint(equalTo: tfMetricTragetOption.rightAnchor).isActive = true
        dividerView.topAnchor.constraint(equalTo: tfMetricTragetOption.bottomAnchor).isActive = true
        dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        tfMetricTragetOption.rightView = UIImageView.init(image: UIImage.init(named: "ic_expand"))
        tfMetricTragetOption.rightViewMode = .always
        metricTargetswitchContainer.isHidden = true
        let ivAddMilestone = UIImageView.init(image: UIImage(named: "ic_edit")?.withRenderingMode(.alwaysTemplate))
        ivAddMilestone.tintColor = UIColor.gray
        tfMilestone.leftView = ivAddMilestone;
        tfMilestone.leftViewMode = .always
        
        let ivAssignee = UIImageView.init(image: UIImage(named: "ic_account")?.withRenderingMode(.alwaysTemplate))
        ivAssignee.tintColor = UIColor.gray
        tfAssignee.leftView = ivAssignee;
        tfAssignee.leftViewMode = .always
        
        let ivStartDtCal = UIImageView.init(image: UIImage(named: "ic_calendar")?.withRenderingMode(.alwaysTemplate))
        ivStartDtCal.tintColor = UIColor.gray
        tfStartDate.rightView = ivStartDtCal
        tfStartDate.rightViewMode = .always
       
        
        let ivEndDtCal = UIImageView.init(image: UIImage(named: "ic_calendar")?.withRenderingMode(.alwaysTemplate))
        ivEndDtCal.tintColor = UIColor.gray
        tfEndDate.rightView = ivEndDtCal
        tfEndDate.rightViewMode = .always
        

        let ivDropDown = UIImageView.init(image: UIImage.init(named: "ic_expand")?.withRenderingMode(.alwaysTemplate))
        ivDropDown.tintColor = UIColor.gray
        viewGoalPicker.rightView = ivDropDown
        viewGoalPicker.rightViewMode = .always
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        contentView.frame.size = scrollView.contentSize
        viewGoalPicker.delegate = self
        tfStartDate.delegate = self
        tfEndDate.delegate = self
        tfMilestone.delegate = self
        tfAssignee.delegate = self
        tfStartValue.keyboardType = .decimalPad
        tfTargetValue.keyboardType = .decimalPad
        tfStartValue.delegate = self
        tfTargetValue.delegate = self
    }
    //Show/hide metric fields
    private func showMetricView(_ flag:Bool){
        lbStartValue.isHidden = !flag
        lbTargetValue.isHidden = !flag
        tfStartValue.isHidden = !flag
        tfTargetValue.isHidden = !flag
        metricStartValueBottomLine.isHidden = !flag
        metricTargetValueBottomLine.isHidden = !flag
    }
    override func viewDidLayoutSubviews() {
        //super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize.init(width: scrollView.bounds.width, height: UIScreen.main.bounds.height+200)
        contentView.frame.size = scrollView.contentSize
        contentView.sizeToFit()
//        metricTargetswitchContainer.frame.size = CGSize.init(width: metricTargetswitchContainer.bounds.width, height: 300)
        //metricTargetswitchContainer.sizeToFit()
        //super.viewDidLayoutSubviews()
        
    }
    @objc private func showInfotext(){
        print("some info about this button")
        let infoString = "At Least - User can go beyond target value when doing check-in\n\nAt Most -  User can go beyond target value when doing check-in\n\nIn-Range Of - You achieve 100% if your achieved value is in-between start and target value"
        CommonUtil.showAlertDialog(context: self, error: infoString, title:"Info")
    }
    func onSelectedPriority(_ selectedItem:Any){
        tfMetricTragetOption.resignFirstResponder()
    }
    @objc private func showMetricTargetOptions(){
        tfMetricTragetOption.loadDropdownData(defaultRow:0,data: select, selectionHandler: onSelectedPriority(_:))
    }
    
    @IBAction func clickAction(_ sender: Any) {
        switch sender {
        case rbProgress as RadioButton:
            rbProgress.isSelected = true
            rbMetric.isSelected = false
            rbTask.isSelected = false
            showMetricView(false)
            tvManageTaskAlert.text = ""
            tvManageTaskAlert.isHidden = true
            milestoneType = Constants.MILESTONE_PROGRESS_TYPE_PERCENTAGE
            metricTargetswitchContainer.isHidden = true
            //button.isHidden = true
            tfStartValue.text = ""
            tfTargetValue.text = ""
        case rbMetric as RadioButton:
            rbMetric.isSelected = true
            rbProgress.isSelected = false
            rbTask.isSelected = false
            showMetricView(true)
            metricTargetswitchContainer.isHidden = false
            tvManageTaskAlert.text = ""
            tvManageTaskAlert.isHidden = true
            milestoneType = Constants.MILESTONE_PROGRESS_TYPE_METRIC
            tfMetricTragetOption.text = select[0]
        case rbTask as RadioButton:
            rbTask.isSelected = true
            rbMetric.isSelected = false
            rbProgress.isSelected = false
            showMetricView(false)
            tvManageTaskAlert.text = manageTaskAlert
            tvManageTaskAlert.isHidden = false
            milestoneType = Constants.MILESTONE_PROGRESS_TYPE_TODO
            metricTargetswitchContainer.isHidden = true
            //button.isHidden = true
            tfStartValue.text = ""
            tfTargetValue.text = ""
        case btnCancel as UIButton:
            self.navigationController?.popViewController(animated: true)
            break;
        case btnCreate as UIButton:
            createMilestone()
            break;
        default:
            break
        }
    }
    // MARK:- Get all goals you are contributing in
    private func getGoals(){
        activityIndicator?.show(startAnimate: true)
        let url = GoalApiMethods.sharedInstance.getGoals()
        let headers = NetworkRequestBuilder.sharedInstance.addBasicHeaders()
        let request = Alamofire.request(URL(string: url)!, method: .post, parameters: [:], encoding: JSONEncoding.default, headers: headers)
        request.validate()
        request.responseJSON { (response) in
            self.activityIndicator?.dismiss()
            debugPrint(request)
            debugPrint(response)
            switch response.result{
            case .success:
                if let data = response.result.value{
                    if let goals = Mapper<Goal>().mapArray(JSONObject: data){
                        if(!goals.isEmpty && goals[0].status == nil){
                            for goal in goals{
                                if(goal.goalStatus! == Constants.GOAL_IN_PROGRESS){
                                    self.mGoals.append(goal)
                                }
                                
                            }
                        }
                       
                    }
                }
                if(self.mGoals.count > 0){
                    self.goalTableView.reloadData()
                    self.goalTableView.dataSource = self
                    self.goalTableView.delegate = self
                }
            case .failure(let error):
                debugPrint(error.localizedDescription)
            }
        }
        
    }
    // MARK:- Show/Hide footer buttons
    func showFooterButtons(_ flag:Bool){
        if(flag){
            cnstrntFoortButtons.constant = CGFloat(htFooterButtons)
        }
        else{
            cnstrntFoortButtons.constant = 0
        }
        stackFooterButtons.isHidden = !flag
    }
    // MARK: - NEW VALUE HAS BEEN ENTERED IN TEXT FIELD
    @objc private func textFieldDidChange (_ textField: UITextField){
        // fetch assignee names from serevr
        if textField != tfAssignee{
            return
        }
        goalTableView.isHidden = true
        let enteredText = textField.text
        if  enteredText! != ""{
            let userNameSuggestionData = UserNameSuggestionData()
            userNameSuggestionData.empFullName = enteredText
            userNameSuggestionData.orgId = TemporarySingleton.sharedInstance.getUserDetails()?.org_id!
            let url = MainApiMethods.sharedInstance.getUserNameSuggestion()
            let parameters = userNameSuggestionData.getDataDict()
            let headers = NetworkRequestBuilder.sharedInstance.addBasicHeaders()
            let request = Alamofire.request(URL(string:url)!, method: .post, parameters: parameters , encoding: JSONEncoding.default, headers: headers)
            request.validate()
                .responseJSON{ (response)->Void in
                    switch response.result{
                    case .success:
                        debugPrint(request)
                        debugPrint(response)
                        let response = response.result.value!
                        let users = Mapper<UserDetails>().mapArray(JSONArray: response as! [[String : Any]])
                        if users.count>0{
                            //SHOW User names in Table View
                            self.users = users
                            self.assigneeTableView.reloadData()
                            self.assigneeTableView.dataSource = self
                            self.assigneeTableView.delegate = self
                            self.assigneeTableView.isHidden = false
                            self.metricTargetswitchContainer.isHidden = true
                        }
                    case .failure(let error):
                        print("ERROR:\(error.localizedDescription)")
                    }
            }
        }
        else{
            assignee = nil
            self.assigneeTableView.isHidden = true
        }
        
    }
    
    //MARK:- another date selected from date picker
    @objc  func startDateChanged(sender:UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "yyyy-MM-dd"
        tfStartDate.text = dateFormatter.string(from: sender.date)
        sender.resignFirstResponder()
        tfStartDate.resignFirstResponder()
        lbStartDate.isHidden = false
    }
    //MARK:- another date selected from date picker
    @objc  func endDateChanged(sender:UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "yyyy-MM-dd"
        tfEndDate.text = dateFormatter.string(from: sender.date)
        sender.resignFirstResponder()
        tfEndDate.resignFirstResponder()
        lbEndDate.isHidden = false
    }
    // MARK:- Create milestone here
    private func createMilestone(){
        if(selectedGoal == nil){
            showError(error: "Select a \(goalName!) first")
            return
        }
        if(tfMilestone.text! == ""){
            showError(error: "Enter name of the \(orgMilestoneName)")
            return
        }
        if((tfMilestone.text?.count)! > 100){
            showError(error: "\(orgMilestoneName) name length can't be greater than 100")
            return
        }
        if(assignee == nil || tfAssignee.text! == ""){
            showError(error:"Enter name of the \(orgMilestoneName) owner")
            return
        }
        if(tfStartDate.text! == ""){
            if(!CommonUtil.isDateValid(tfStartDate.text!)){
                showError(error:"Enter \(orgMilestoneName) start date")
                return
            }
           
        }
        
        if(tfEndDate.text! == ""){
            if(!CommonUtil.isDateValid(tfEndDate.text!)){
                showError(error:"Enter \(orgMilestoneName) end date")
                return
            }
        }
        
        var createMilestoneData:CreateMilestoneData? = nil
        switch milestoneType {
        case Constants.MILESTONE_PROGRESS_TYPE_PERCENTAGE:
            createMilestoneData = CreateProgressBasedMIlestoneData()
            break
        case Constants.MILESTONE_PROGRESS_TYPE_METRIC:
            if(tfStartValue.text == ""){
                showError(error: "Enter metric start value")
                return
            }
            if(tfTargetValue.text == ""){
                showError(error: "Enter metric target value")
                return
            }
            createMilestoneData = CreateMetricBasedMilestoneData()
            if let startValue = Double(tfStartValue.text!){
                createMilestoneData?.metricStartValue = startValue
                createMilestoneData?.metricCurrentValue = startValue
            }
            else{
                showError(error: "Enter metric start value")
                return
            }
            if let targetValue = Double(tfTargetValue.text!){
                createMilestoneData?.metricTargetValue = targetValue
            }
            else{
                showError(error: "Enter metric target value")
                return
            }
            if let salesTarget = selectedGoal?.salesTarget{
                createMilestoneData?.salesTarget = salesTarget
            }

            if let metricTragetOption = tfMetricTragetOption.text{
                switch metricTragetOption{
                case "At Least":
                    createMilestoneData?.metricMilestoneTargetCondition = "AT_LEAST"
                case "At Most":
                    createMilestoneData?.metricMilestoneTargetCondition = "AT_MOST"
                case "In Range Of":
                    createMilestoneData?.metricMilestoneTargetCondition = "IN_RANGE"
                default:
                  createMilestoneData?.metricMilestoneTargetCondition = "AT_LEAST"
                }
            }
        case Constants.MILESTONE_PROGRESS_TYPE_TODO:
            createMilestoneData = CreateToDoBasedMIlestoneData()
            break
        default:
            break
        }
        if createMilestoneData == nil{
            return
        }
        createMilestoneData?.createdBy = TemporarySingleton.sharedInstance.getUserDetails()?.user_id!
        createMilestoneData?.createdByName = TemporarySingleton.sharedInstance.getUserDetails()?.full_name!
        createMilestoneData?.goalId = selectedGoal?.goalId!
        createMilestoneData?.goalName = selectedGoal?.goalName!
        createMilestoneData?.goalNature = selectedGoal?.goalNature!
        createMilestoneData?.goalOwnerEmail = selectedGoal?.goalOwnerEmail!
        createMilestoneData?.goalOwnerId = selectedGoal?.goalOwnerId!
        createMilestoneData?.goalOwnerLineManagerEmail = selectedGoal?.goalOwnerLineManagerEmail!
        createMilestoneData?.goalOwnerLineManagerId = selectedGoal?.goalOwnerLineManagerId!
        createMilestoneData?.goalOwnerLineManagerName = selectedGoal?.goalOwnerLinerManagerName!
        createMilestoneData?.goalOwnerName = selectedGoal?.goalOwnerName!
        createMilestoneData?.milestoneDueDate = tfEndDate.text!
        createMilestoneData?.milestoneName = tfMilestone.text!
        createMilestoneData?.milestoneOwnerEmail = assignee?.email!
        createMilestoneData?.milestoneOwnerId = assignee?.user_id!
        createMilestoneData?.milestoneOwnerLineManagerEmail = assignee?.line_manager_email!
        createMilestoneData?.milestoneOwnerLineManagerId = assignee?.line_manager_id!
        createMilestoneData?.milestoneOwnerLineManagerName = assignee?.line_manager_name!
        createMilestoneData?.milestoneOwnerName = assignee?.full_name!
        createMilestoneData?.milestoneStartDate = tfStartDate.text!
        createMilestoneData?.orgId = TemporarySingleton.sharedInstance.getUserDetails()?.org_id!
        createMilestoneData?.publishedAsGoal = 0
        let params = createMilestoneData?.getData()
        let headers = NetworkRequestBuilder.sharedInstance.addBasicHeaders()
        activityIndicator?.show()
        let request = Alamofire.request(URL(string: GoalApiMethods.sharedInstance.createMilestone())!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
        request.validate()
        request.responseJSON { (response) in
            debugPrint(request)
            debugPrint(response)
            self.activityIndicator?.dismiss()
            switch response.result{
            case .success:
                if let data = response.result.value{
                    if let basicResponse = Mapper<BasicResponse>().map(JSONObject: data){
                        if (basicResponse.status != nil && basicResponse.status! == Constants.SUCCESS){
                            self.showError(error: "\(self.orgMilestoneName) created successfully")
                            self.resetPage()
                            if self.eventListener != nil{
                                self.eventListener?.milestoneCreated()
                            }
                        }
                        else if(basicResponse.message != nil){
                            self.showError(error: basicResponse.message!)
                        }
                        else{
                            self.showError(error: self.commonErrorMessage)
                        }
                    }
                }
            case .failure(let error):
                debugPrint(error.localizedDescription)
                if(TemporarySingleton.sharedInstance.isConnectedToNetwork()){
                    self.showError(error: self.commonErrorMessage)
                }
                else{
                    CommonUtil.showAlertDialog(context: self, error: Constants.youAreNotConnectedToInternet)
                }
            }
        }
        
        
    }
    // MARk:- Reset everything once milestone is created
    func resetPage(){
        viewGoalPicker.text = "Select "+goalName!
        tfMilestone.text = ""
        tfAssignee.text = ""
        tfStartDate.text = ""
        tfEndDate.text = ""
        lbStartDate.isHidden = true
        lbEndDate.isHidden = true
        assignee = nil
        selectedGoal = nil
        tfStartValue.text = ""
        tfTargetValue.text = ""
        showFooterButtons(false)
    }
    
    
}

extension CreateMilestoneViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == goalTableView){
            return mGoals.count
            
        }
        else if tableView == assigneeTableView{
            return users.count
        }
//        else{
//            return select.count
//        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style:UITableViewCell.CellStyle.default,reuseIdentifier:"cell")
        if(tableView == assigneeTableView){
            let user = users[indexPath.row]
            cell.textLabel?.text = (user.full_name!)+"-"+(user.email!)
        }
        else if tableView == goalTableView{
            let goal = mGoals[indexPath.row]
            cell.textLabel?.text = goal.goalName!
        }
        else{
            let option = select[indexPath.row]
            cell.textLabel?.text = option
        }
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       self.view.setNeedsLayout()
        //self.scrollView.layoutIfNeeded()
        if(tableView == goalTableView){
            selectedGoal = mGoals[indexPath.row]
            viewGoalPicker.text = selectedGoal?.goalName!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            var endDateInUtc:Date? = nil
            if(selectedGoal?.goalDueDate != nil){
                endDateInUtc = dateFormatter.date(from: (selectedGoal?.goalDueDate!)!)
            }
            dateFormatter.dateFormat = "yyyy-MM-dd" //- h:mm a
            dateFormatter.timeZone = TimeZone.current
            tfStartDate.text = dateFormatter.string(from: Date())
            lbStartDate.isHidden = false
            if(endDateInUtc != nil){
                 tfEndDate.text = dateFormatter.string(from: endDateInUtc!)
                lbEndDate.isHidden = false
            }
            goalTableView.isHidden = true
            if(selectedGoal?.goalOwnerId! == TemporarySingleton.sharedInstance.getUserDetails()?.user_id!){
                showFooterButtons(true)
            }
            else{
                switch goalSetting?.milestoneCreator!{
                case Constants.MS_CREATOR_GOAL_MS_OWNER:
                    showFooterButtons(true)
                case Constants.MS_CREATOR_GOAL_OWNER:
                    fallthrough
                case Constants.MS_CREATOR_NONE:
                    fallthrough
                default:
                    showFooterButtons(false)
                    //Show alert that user can't create milestone for this goal
                    let alert = UIAlertController(title: "Alert", message: "You don't own this "+goalName!+".\nOnly "+goalName!+" owner can create a \(orgMilestoneName)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
            }
        }
            if rbMetric.isSelected{
                metricTargetswitchContainer.isHidden = false
            }
    }
        else if tableView == assigneeTableView{
            assignee = users[indexPath.row]
            tfAssignee.text = (assignee?.full_name!)!+"-"+(assignee?.email!)!
            assigneeTableView.isHidden = true
            if rbMetric.isSelected{
                metricTargetswitchContainer.isHidden = false
            }
        }

}
   
}

extension CreateMilestoneViewController:UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.view.setNeedsLayout()
        
        switch textField {
        case tfMetricTragetOption:
            textField.resignFirstResponder()
            showMetricTargetOptions()
        case viewGoalPicker:
            assigneeTableView.isHidden = true
            metricTargetswitchContainer.isHidden = true
            if(mGoals.count > 0){
                goalTableView.isHidden = false
            }
            else{
                self.showError(error: "No "+goalName!+" to create \(orgMilestoneName)")
            }
            
            return false
            
        case tfStartDate:
            let datePickerView:UIDatePicker = UIDatePicker()
            datePickerView.datePickerMode = .date
            textField.inputView = datePickerView
            datePickerView.minimumDate = Date()
            if(selectedGoal != nil){
                if(selectedGoal?.goalDueDate != nil){
                    if  let maxDate = CommonUtil.toLocalDate(inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: "yyyy-MM-dd", inputDate:(selectedGoal?.goalDueDate!)!){
                        datePickerView.maximumDate = maxDate
                    }
                }
            }
            datePickerView.addTarget(self, action: #selector(startDateChanged), for: UIControl.Event.valueChanged)
            return true
        case tfEndDate:
            let datePickerView:UIDatePicker = UIDatePicker()
            datePickerView.datePickerMode = .date
            textField.inputView = datePickerView
            datePickerView.minimumDate = Date()
            if(selectedGoal != nil){
                if(selectedGoal?.goalDueDate != nil){
                    if  let maxDate = CommonUtil.toLocalDate(inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outputFormat: "yyyy-MM-dd", inputDate:(selectedGoal?.goalDueDate!)!){
                        datePickerView.maximumDate = maxDate
                    }
                }
            }
            datePickerView.addTarget(self, action: #selector(endDateChanged), for: UIControl.Event.valueChanged)
            return true
        default:
            break
        }
       
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}

