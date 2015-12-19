//
//  ViewController.swift
//  MySearchResultDemo
//
//  Created by imac on 15/12/19.
//  Copyright © 2015年 caogo.cn. All rights reserved.
//

import UIKit

var airlines: [String] = []
var filterAirlines: [String] = []

func readJson() {
    if let path = NSBundle.mainBundle().pathForResource("airlineData", ofType: "json") {
        let data = NSData(contentsOfFile: path)
        
        var json: AnyObject?
        do {
            try json = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
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


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        readJson()
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
}

