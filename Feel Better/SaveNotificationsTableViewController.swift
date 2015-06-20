//
//  SaveNotificationsTableViewController.swift
//  Feel Better
//
//  Created by Arthur Jacunas de Brum on 19/06/15.
//  Copyright (c) 2015 Arthur Brum. All rights reserved.
//

import UIKit

class SaveNotificationsTableViewController: UITableViewController {

    @IBOutlet weak var datePickerTime: UIDatePicker!
    
    // 0 for water and 1 for food
    var typeOfschedule: Int = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePickerTime.enabled = false;
        
        self.clearsSelectionOnViewWillAppear = false

        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationItem.rightBarButtonItem?.action = "editTime:"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDrink", name: "modifyListNotification", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 1
    }
    
    func scheduleLocalNotification() {
        var localNotification = UILocalNotification()
        
        // Handle older notifications
        //UIApplication.sharedApplication().cancelAllLocalNotifications()
        var test = UIApplication.sharedApplication().scheduledLocalNotifications
        //Fazer um for percorrendo todas notificacoes e usar UIApplication.sharedApplication().cancelLocalNotification(notificacao) na certa
        
        if (typeOfschedule == 0){
            localNotification.alertBody = "Hey, you should drink some water!"
            localNotification.alertAction = "View List"
            localNotification.category = "waterCategory"
        }else{
            localNotification.alertBody = "Hey, you should eat something!"
            localNotification.alertAction = "View List"
            localNotification.category = "foodCategory"
        }
        
        localNotification.fireDate = fixNotificationDate(datePickerTime.date)
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        println(test.description)
    }
    
    
    

    // MARK:  - Actions of the notification
    
    func editTime(sender: AnyObject){
        if (self.navigationItem.rightBarButtonItem?.title == "Edit"){
            self.navigationItem.rightBarButtonItem?.title = "Done"
            self.datePickerTime.enabled = true
            
        }else if (self.navigationItem.rightBarButtonItem?.title == "Done"){
            self.navigationItem.rightBarButtonItem?.title = "Edit"
            self.datePickerTime.enabled = false
            self.scheduleLocalNotification()
        }
        
    }
    
    
    // MARK: - Auxiliar Methods
    func fixNotificationDate(dateToFix: NSDate) -> NSDate {
        var dateComponets: NSDateComponents = NSCalendar.currentCalendar().components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitHour | .CalendarUnitMinute, fromDate: dateToFix)
        
        dateComponets.second = 0
        
        var fixedDate: NSDate! = NSCalendar.currentCalendar().dateFromComponents(dateComponets)
        
        return fixedDate
    }
    
    
    

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
