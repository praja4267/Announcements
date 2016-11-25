

import UIKit

class SideViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var sideTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        sideTableView.dataSource=self
        sideTableView.delegate=self
        self.sideTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.sideTableView.tableFooterView=UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 0.1))
        self.automaticallyAdjustsScrollViewInsets = false;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
        if indexPath.row == 0 {
            cell.textLabel?.text = "Home"
        }else {
            cell.textLabel?.text = "Title \(indexPath.row)"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            let cntl = self.storyboard?.instantiateInitialViewController()
           UIApplication.sharedApplication().keyWindow?.rootViewController = cntl;
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
