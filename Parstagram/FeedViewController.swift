//
//  FeedViewController.swift
//  Parstagram
//
//  Created by user163612 on 2/26/20.
//  Copyright © 2020 user163612. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    var posts = [PFObject]()
    var myRefreshControl:UIRefreshControl!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate=self
        tableView.dataSource=self
        myRefreshControl=UIRefreshControl()
        myRefreshControl.addTarget(self, action:#selector(onRefresh), for:.valueChanged)
        tableView.insertSubview(myRefreshControl, at: 0)
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        let post = posts[indexPath.row]
        let user=post["author"] as! PFUser
        cell.usernameLabel.text=user.username
        cell.captionLabel.text=post["caption"] as? String
        let imageFile=post["image"] as! PFFileObject
        let urlString=imageFile.url!
        let url=URL(string:urlString)!
        print(url)
        cell.photoView.af_setImage(withURL: url)
        
        return cell
       }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadPosts()
    }
    
    func loadPosts(){
        let query = PFQuery(className:"Posts")
        query.includeKey("author")
        query.limit = 20
        query.findObjectsInBackground { (posts,error) in
            if posts != nil{
                self.posts=posts!
                self.tableView.reloadData()
            }
        }    }
    
    @objc func onRefresh(){
        run(after:2){
            self.loadPosts()
            self.myRefreshControl.endRefreshing()
        }
    }
    
    func run(after wait:TimeInterval,closure:@escaping () ->Void){
        let queue=DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now(), execute: closure)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
