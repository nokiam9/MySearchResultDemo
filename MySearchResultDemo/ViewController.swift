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
        
        // 调用storyboard的类方法建立一个ViewController的实例，identifier入参是该ViewController的标识符
        // 本例中就是那个没有入口的NavigateView，其segue指向了SearchResultTableVIewController的Class
        searchResultsController = (self.storyboard?.instantiateViewControllerWithIdentifier("SearchResultsController"))! as UIViewController
        
        //初始化UISearchController的实例，如果搜索结果显示在原始tableView，则入参直接置为nil，否则入参为新的tableView
        //UISearchController类的内部包含了searchResultController和searchBar两个控件
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

