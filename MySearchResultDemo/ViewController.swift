//
//  ViewController.swift
//  MySearchResultDemo
//
//  Created by imac on 15/12/19.
//  Copyright © 2015年 caogo.cn. All rights reserved.
//

import UIKit

var airlines: [String] = []
var filteredAirlines: [String] = []

func readJson() {
    // 使用NSBund了方法获取当前配置下的资源文件目录，json文件就存在这里
    if let path = NSBundle.mainBundle().pathForResource("airlineData", ofType: "json") {
        let data = NSData(contentsOfFile: path)
        var json: AnyObject?
        do {
            // 注意： NJJSONSerialization的方法可能产生上层错误，为确保安全必须使用try方式，并用do catch的方式处理可能的错误
            try json = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            
            // 本json的格式中，airlines是第一层标示，下层是6000多个key－value的字典
            if let topic = json?.objectForKey("airlines") {
                for index in 0 ... topic.count - 1 {
                    let name = topic[index].objectForKey("Name") as! String
                    airlines.append(name)
                }
                print("Sucess: read \(topic.count) records sucessful! ")
            }
            else {
                print("Error: can't find topic airlines")
                exit(-103)
            }
        } catch {
            print("Error: reading json file failed!")
            exit(-102)
        }
    }
    else {
        print("Error: file airlineData.json isn't exist!")
        exit(-101)
    }
}


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating   {

    @IBOutlet weak var tableView: UITableView!
    var searchController: UISearchController!
    var searchResultsController: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        readJson()
        
        // 调用storyboard的类方法建立一个ViewController的实例，identifier入参是那个没有入口的NavigateView的stroryBoard的标识符
        // NavigateView的segue指向了SearchResultTableVIewController的Class
        searchResultsController = (self.storyboard?.instantiateViewControllerWithIdentifier("SearchResultsController"))! as UIViewController
        
        //初始化UISearchController的实例，如果搜索结果显示在原始tableView，则入参直接置为nil，否则入参为新的tableView
        //UISearchController类的内部包含了searchResultController和searchBar两个控件
        /*-------------------
        注意：本例中将搜索结果显示在一个新的tableView中，如果需要将搜索结果显示在原始tableView中，则：
        1、不需要定义searchResultsController
        2、searchController＝UISearchController()，即class的初始化直接赋值nil，说明搜索结果就在tableView中显示
        3、继续设置searchController的searchResultsUpdater和searchBar.frame，以及将searchBar控件置为最顶层
        4、重定义tableView的dataSource接口，注意可以通过searchController.active判断当前状态是基本view还是搜索view，相应设置row和cell的参数
        5、重定义updateSearchResultsForSearchController方法，继续设置filteredAirlines的结果数据，但不需要显示新的tableView，直接调用tableView.reloadData即可完成
        6、说明，搜索结果在同一个view时，搜索结果数据列表是不可编辑的灰色显示，但可以在搜索框数据输入的同时，动态显示搜索结果
        --------------------*/
        searchController = UISearchController(searchResultsController: searchResultsController)
        
        if searchController != nil {
            //设置searchResultsController的属性，说明搜索结果的协议方法updateSearchResultsForSearchController在哪里（也就是本文件的最后一个func）
            searchController.searchResultsUpdater = self
            
            //设置searchController的searchBar的显示位置
            searchController.searchBar.frame = CGRectMake(  searchController.searchBar.frame.origin.x,
                searchController.searchBar.frame.origin.y,
                searchController.searchBar.frame.size.width,
                44.0)
            
            //将searchBar控件置为最顶层
            self.tableView.tableHeaderView = self.searchController.searchBar
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return airlines.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Airline")! as UITableViewCell
        cell.textLabel?.text = airlines[indexPath.row]
        
        return cell
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        //从searchBar取得输入的搜索文本，并过滤信息到filterNamelist数组
        let searchStr = searchController.searchBar.text
        filteredAirlines = airlines.filter() {$0.rangeOfString(searchStr!) != nil}
        
        // 从searchController中取得searchResultsController的信息（就是之前初始化searchController的入参），也是是那个没有入口的导航View
        let navController = (self.searchController.searchResultsController) as! UINavigationController
        
        // 将SearchResultsTableViewController的tableView置为最顶层，并刷新数据；否则就只显示searchBar，而看不到更新的搜索数据了
        let vc = navController.topViewController as! SearchResultTableViewController
        vc.tableView.reloadData()

    }

}

