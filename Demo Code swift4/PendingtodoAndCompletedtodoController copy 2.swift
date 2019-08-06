//
//  PendingtodoAndCompletedtodoController.swift
//  qilo
//
//  Created by Abdul on 12/03/19.
//  Copyright © 2019 Qilo Technologies. All rights reserved.
//
import UIKit
import XLPagerTabStrip
import Alamofire
import ObjectMapper
class PendingtodoAndCompletedtodoController: ButtonBarPagerTabStripViewController {
    var todo:Todo?
    var mCurrentUser:Reporter?
    private var isTeamLeader = false
    var mUser:Reporter?
    var collectionView:UICollectionView?
    var todos:[Todo]?
    var isReload = false
    private  var activityIndicator:ActivityIndicator?
    func setUser(_ user:Reporter){
        mCurrentUser = user
    }
    var itemInfo: IndicatorInfo = "Todoslok"
    weak var todoActionListener:TodoActionListener?
//    init(itemInfo: IndicatorInfo) {
//        self.itemInfo = itemInfo
//        super.init(nibName: nil, bundle: nil)
//    }
//    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
//        return itemInfo
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
//    private var refreshControl:UIRefreshControl = {
//        let refreshControl = UIRefreshControl()
//        refreshControl.attributedTitle = NSAttributedString(string:"")
//        refreshControl.addTarget(self, action: #selector(reloadGoals), for: .valueChanged)
//        return refreshControl
//    }()
    private var emptyLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "You have no Todos blah blah"
        return label
    }()


    // var isBackPressed = false
   // var ifGoalHasSingleParticipant = true
    private var defaultColor : UIColor!
    private var pageTitle = ""
   // var orgMilestoneName = "Milestone"
    override func viewDidLoad() {
        self.lockOrientation(.portrait)
 //       orgMilestoneName = (TemporarySingleton.sharedInstance.getOrgDetails()?.milestoneName)!
//        if let goalName = goal?.goalName{
//            pageTitle = goalName
//        }
        defaultColor = CommonUtil.getUIColor(hexCode: Constants.UNIVERSAL_COLOR)
        setButtonBar()
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = pageTitle
        // ifGoalHasSingleParticipant = true
        //checkIfGoalhasSingleParticipant()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.title = pageTitle
    }
    
    //MARK:- configure views
    private func setupViews(){
        buttonBarView.alwaysBounceHorizontal = true
        buttonBarView.selectedBar.backgroundColor = UIColor.groupTableViewBackground
        buttonBarView.backgroundColor = defaultColor
    }
    
    //MARK:- Customize Bar button
    private func setButtonBar(){
        // change selected bar color
        settings.style.buttonBarBackgroundColor = UIColor.white
        settings.style.buttonBarItemBackgroundColor = UIColor.white
        settings.style.selectedBarBackgroundColor = defaultColor
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 13)
        settings.style.selectedBarHeight = 3
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = UIColor.darkGray
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor.darkGray
            newCell?.label.textColor = UIColor.black
        }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        var itemInfo = IndicatorInfo.init(stringLiteral: "Pending".uppercased())
        let tos = PendingTodosController.init(itemInfo: itemInfo)
        tos.todo = todo
        tos.mCurrentUser = mCurrentUser
        itemInfo = IndicatorInfo.init(stringLiteral: "completed".uppercased())
        let comp = CompletedTodosController.init(itemInfo: itemInfo)
        comp.todo = todo
        var controllers = [BaseViewController]()
        controllers.append(tos)
        controllers.append(comp)
        guard isReload else {
            return controllers
        }
        var childViewControllers = controllers as [Any]
        for index in childViewControllers.indices {
            let nElements = childViewControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index {
                childViewControllers.swapAt(index, n)
            }
        }
        let nItems = 1 + (arc4random() % 8)
        return Array(childViewControllers.prefix(Int(nItems))) as! [UIViewController]
    }
   

    
    
    
    //reporteeList
//    func getReporteeList(){
//        activityIndicator = ActivityIndicator.init(self.view)
//        activityIndicator?.show()
//        if mCurrentUser != nil{
//            let reporteeDetailsData = ReporteeDetailsData.init(orgId: mCurrentUser?.orgId!, userId: mCurrentUser?.userId!, dataFor: "teamLeader")
//            let params = reporteeDetailsData.getData()
//            let headers = NetworkRequestBuilder.sharedInstance.addBasicHeaders()
//            let url = TodoApiMethods.sharedInstance.getReporteeDetails()
//            let request = Alamofire.request(URL(string:url)!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
//            request.validate()
//            request.responseJSON { (response) in
//                self.activityIndicator?.dismiss()
//                switch response.result{
//                case .success:
//                    if let data = response.result.value{
//                        if let reporters = Mapper<Reporter>().mapArray(JSONObject: data){
//                            if reporters.count>0{
//                                self.isTeamLeader = true
//                                self.buttonBarView.selectedBar.backgroundColor = self.defaultColor!
//                                self.reloadPagerTabStripView()
//                            }
//                            else{
//                                self.isTeamLeader = false
//                            }
//                        }
//                        else{
//                            self.isTeamLeader = false
//                        }
//                    }
//                    else{
//                        self.isTeamLeader = false
//                    }
//
//                    break
//                case .failure(let error):
//                    print(error.localizedDescription)
//                    self.isTeamLeader = false
//                    break
//                }
//            }
//        }else{
//            let url  = TodoApiMethods.sharedInstance.getAllReportee()
//            let headers = NetworkRequestBuilder.sharedInstance.addBasicHeaders()
//            let request  = Alamofire.request(URL(string:url)!, method: .get, parameters: [:], encoding: URLEncoding.default, headers: headers)
//            request.validate()
//            request.responseJSON { (response) in
//                debugPrint(request)
//                debugPrint(response)
//                self.activityIndicator?.dismiss()
//                switch response.result{
//                case .success:
//                    if let data = response.result.value{
//                        if let reportees = Mapper<Reportee>().mapArray(JSONObject: data){
//                            if reportees.count>0{
//                                self.isTeamLeader = true
//                                self.buttonBarView.selectedBar.backgroundColor = self.defaultColor!
//                                self.reloadPagerTabStripView()
//                            }
//                            else{
//                                self.isTeamLeader = false
//                            }
//                        }
//                        else{
//                            self.isTeamLeader = false
//                        }
//                    }
//                    else{
//                        self.isTeamLeader = false
//                    }
//                    break
//                case .failure(let error):
//                    print("ERROR : \(error.localizedDescription)")
//                    self.isTeamLeader = false
//                    //REMOVE MY TEAM TAB
//                }
//            }
//        }
//
//    }
//
//    func showData(){
//        emptyLabel.isHidden = true
//        collectionView?.isHidden = false
//        collectionView?.reloadData()
//        collectionView?.collectionViewLayout.invalidateLayout()
//        collectionView?.delegate = self
//        collectionView?.dataSource = self
//    }
//
}



//extension PendingtodoAndCompletedtodoController: IndicatorInfoProvider {
//    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
//        return itemInfo
//    }
//}




