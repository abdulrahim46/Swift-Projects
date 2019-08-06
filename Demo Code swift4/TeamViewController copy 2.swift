//
//  TeamViewController.swift
//  Qilo
//
//  Created by Abdul on 11/03/19.
//  Copyright © 2017 Qilo Technologies. All rights reserved.
//



import UIKit
import XLPagerTabStrip
import Alamofire
import ObjectMapper
class TeamViewController: BaseViewController,IndicatorInfoProvider {
    var canSearchMultiple = true
    let TAG_SUGGESTION = 0
    let TAG_ADDED = 1
    var assignee:UserDetails?
    var users:[UserDetails] = []
    var addedUsers:[UserDetails]!
    var listener:SearchColleageActionListener!
    weak var todoActionListener:TodoActionListener?
    //var mCurrentUser:Reporter?
    var reporter:Reporter?
    var mUser:UserDetails?
   
    var reporters=[Reporter]()
    var itemInfo: IndicatorInfo = "My team"
    var collectionView:UICollectionView!
    var reporteeCellId = "reporterCell"
    
    var searchText:UITextField={
        let textField = UITextField.init()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.systemFont(ofSize: 14, weight: .medium)
       // textField.tintColor = UIColor.white
        textField.textColor = UIColor.black
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.placeholder = "search your team"
        return textField
    }()
    var searchUser:UITableView={
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width - 24, height: 0))
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.masksToBounds = true
        tableView.layer.shadowOpacity = 0.5
        tableView.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        tableView.layer.shadowColor = UIColor.gray.cgColor
        tableView.isScrollEnabled = true
        return tableView
    }()
    var dividerView:UIView={
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    private var refreshControl:UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string:"")
        refreshControl.addTarget(self, action: #selector(reloadTeam), for: .valueChanged)
        return refreshControl
    }()
    private var emptyLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "You have no team"
        return label
    }()
    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let cellnib = UINib.init(nibName: "ReporterCell", bundle: nil)
        collectionView.register(cellnib, forCellWithReuseIdentifier: reporteeCellId)
        if let floawLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            floawLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            floawLayout.estimatedItemSize = CGSize(width:self.collectionView.bounds.width,height:60)
        }
        //getTeamProgress()
        loadReporters()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         searchUser.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reloadTeam(){
        collectionView.delegate = nil
        collectionView.dataSource = nil
        reporters.removeAll()
        loadReporters()
        searchUser.delegate = nil
        searchUser.dataSource = nil
        searchText.text = ""
    }
    
    //MARK:- set up views
    private func setupViews(){
        view.addSubview(emptyLabel)
        view.backgroundColor = .white
        view.addConstraint(NSLayoutConstraint(item: emptyLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: emptyLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: -50))
        view.addSubview(searchText)
        searchText.topAnchor.constraint(equalTo:self.view.topAnchor, constant:20).isActive = true
        searchText.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant:10).isActive = true
        searchText.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant:-10).isActive = true
        searchText.heightAnchor.constraint(equalToConstant: 30).isActive = true
        searchText.delegate = self
        view.addSubview(dividerView)
        dividerView.leftAnchor.constraint(equalTo: searchText.leftAnchor).isActive = true
        dividerView.rightAnchor.constraint(equalTo: searchText.rightAnchor).isActive = true
        dividerView.topAnchor.constraint(equalTo: searchText.bottomAnchor).isActive = true
        dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.addSubview(searchUser)
        searchUser.backgroundColor = UIColor.white
        searchUser.leftAnchor.constraint(equalTo: searchText.leftAnchor).isActive = true
        searchUser.rightAnchor.constraint(equalTo: searchText.rightAnchor).isActive = true
        searchUser.topAnchor.constraint(equalTo: searchText.bottomAnchor,constant:2).isActive = true
        searchUser.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        searchUser.isHidden = true
        let flowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant:20).isActive = true
        collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor.groupTableViewBackground
        collectionView.isHidden = false
        collectionView.addSubview(refreshControl)
        collectionView.alwaysBounceVertical = true
        collectionView.bounces = true
    }
    
    //MARK:- Populate collection view with data
    func showData(){
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    @objc private func textFieldDidChange(_ textField:UITextField){
        if textField != searchText{
            return
        }
         self.collectionView.isHidden = true
        let enteredText = textField.text
        if enteredText! != "" {
            let url = GoalApiMethods.sharedInstance.searchEmpByName()
            let parameters = ["includeMrgClause":0,"name":enteredText ?? ""] as [String : Any]
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
                            self.searchUser.allowsSelection = true
                            self.users = users
                            self.searchUser.reloadData()
                            self.searchUser.dataSource = self
                            self.searchUser.delegate = self
                            self.searchUser.isHidden = false
                        }
                    case .failure(let error):
                        print("ERROR:\(error.localizedDescription)")
                    }
            }
        }
        else{
            assignee = nil
            self.searchUser.isHidden = true
            self.collectionView.isHidden = false
        }

        
    }

    //MARK:-Load your team here
    func loadReporters(){
        self.searchUser.isHidden = true
        self.emptyLabel.isHidden = true
        self.collectionView.isHidden = false
        refreshControl.beginRefreshing()
        var orgId = TemporarySingleton.sharedInstance.getUserDetails()?.org_id!
        var userId = TemporarySingleton.sharedInstance.getUserDetails()?.user_id!
        if reporter != nil{
            orgId = reporter?.orgId!
            userId = reporter?.userId!
        }
        let reporteeDetailsData = ReporteeDetailsData.init(orgId: orgId, userId: userId, dataFor: "teamLeader")
        let params = reporteeDetailsData.getData()
        let headers = NetworkRequestBuilder.sharedInstance.addBasicHeaders()
        let url = GoalApiMethods.sharedInstance.getReporteeDetails()
        let request = Alamofire.request(URL(string:url)!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
        request.validate()
        request.responseJSON { (response) in
            debugPrint(request)
            debugPrint(response)
            self.refreshControl.endRefreshing()
            switch response.result{
            case .success:
                if let data = response.result.value{
                    if let reporters = Mapper<Reporter>().mapArray(JSONObject: data){
                        if reporters.count>0{
                            for reporter in reporters{
                                reporter.orgId = TemporarySingleton.sharedInstance.getUserDetails()?.org_id!
                            }
                            self.reporters = reporters
                            self.showData()
                        }
                        else{
                            self.emptyLabel.isHidden = false
                            self.collectionView.isHidden = true
                        }
                    }
                    else{
                        self.showError(error: Constants.commonErrorMessage)
                    }
                }
                else{
                    self.showError(error: Constants.commonErrorMessage)
                }
                break
            case .failure(let error):
                print("ERROR : \(error.localizedDescription)")
                if TemporarySingleton.sharedInstance.isConnectedToNetwork(){
                    self.showError(error: Constants.commonErrorMessage)
                }
                else{
                    CommonUtil.showAlertDialog(context: self, error: Constants.youAreNotConnectedToInternet)
                }
            }
        }
        
    }
    
}


extension TeamViewController:UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  (reporters.count)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reporteeCellId, for: indexPath) as! ReporterCell
        cell.widthConstraint.constant = collectionView.bounds.width
        cell.reporter = reporters[indexPath.row]
        cell.configure()
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "todoViewController") as! TodoViewController
        vc.setUser(reporters[indexPath.row])
        navigationController?.pushViewController(vc,animated: true)
    }
    
}
extension TeamViewController:UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
         self.view.setNeedsLayout()
        if textField == searchText{
            searchUser.isHidden = false
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
       //searchUser.isHidden = true
        //tableView.tag = TAG_ADDED
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(assignee == nil){
            users = [UserDetails]()
        }
        searchUser.allowsSelection = true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.endEditing(true)
        return true
    }
    
}

extension TeamViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let tag = tableView.tag
//        if tag == TAG_SUGGESTION && users != nil{
//            return users.count
//        }
//        else if tag == TAG_ADDED && addedUsers != nil{
//            return addedUsers.count
//        }
         return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style:UITableViewCell.CellStyle.default,reuseIdentifier:"cell")
        if(tableView == searchUser){
            let user = users[indexPath.row]
            cell.textLabel?.text = (user.full_name!)+"-"+(user.email!)
        }
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.setNeedsLayout()
        assignee = users[indexPath.row]
        searchText.text = (assignee?.full_name!)!+"-"+(assignee?.email!)!
        searchUser.isHidden = true
        collectionView.isHidden = false
//        let tag = tableView.tag
//        if tag == TAG_SUGGESTION{
//            searchText.text = ""
//            searchText.resignFirstResponder()
//           // self.tableView.tag = TAG_ADDED
//            let user = users[indexPath.row]
//            if(addedUsers == nil){
//                addedUsers = [UserDetails]()
//            }
//            var isAlreadyAdded = false
//            for addedUser in addedUsers{
//                if user.user_id! == addedUser.user_id!{
//                    isAlreadyAdded = true
//                }
//            }
//            if !isAlreadyAdded{
//                addedUsers.append(user)
//            }
//            addColleagues(addedUsers)
//
//        }
    }
}
