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
import MessageInputBar

class FeedViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,MessageInputBarDelegate {
   
    var posts = [PFObject]()
    var myRefreshControl:UIRefreshControl!
    let commentBar=MessageInputBar()
    var showsCommentBar = false

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        commentBar.inputTextView.placeholder="Add a comment..."
        commentBar.sendButton.title="Post"
        commentBar.delegate=self
        tableView.delegate=self
        tableView.dataSource=self
        tableView.keyboardDismissMode = .interactive
        let center=NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        myRefreshControl=UIRefreshControl()
        myRefreshControl.addTarget(self, action:#selector(onRefresh), for:.valueChanged)
        tableView.insertSubview(myRefreshControl, at: 0)
    }
    
    @objc func keyboardWillBeHidden(note:Notification){
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //create the comment
        
        //clear and dismiss the input
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar
    }
    
    
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post=posts[section]
        let comments=(post["comments"] as? [PFObject]) ?? []
        return comments.count+2
       }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments=(post["comments"] as? [PFObject]) ?? []
        if indexPath.row == 0 {
            let cell=tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            let user=post["author"] as! PFUser
            cell.usernameLabel.text=user.username
            cell.captionLabel.text=post["caption"] as? String
            let imageFile=post["image"] as! PFFileObject
            let urlString=imageFile.url!
            let url=URL(string:urlString)!
            cell.photoView.af_setImage(withURL: url)
            return cell
        }
        else if indexPath.row <= comments.count   {
            let cell=tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment=comments[indexPath.row - 1]
            let user=comment["user"] as! PFUser
            cell.nameLabel.text=user.username
            cell.commentLabel.text=comment["text"] as? String
            return cell
        }
        else{
            let cell=tableView.dequeueReusableCell(withIdentifier: "AddCommentCell") as! UITableViewCell
            return cell
        }
       }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadPosts()
    }
    
    func loadPosts(){
        let query = PFQuery(className:"Posts")
        query.includeKeys(["author","comments","comments.user"])
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
    
    @IBAction func onLogout(_ sender: Any) {
        PFUser.logOut()
        let main=UIStoryboard(name: "Main", bundle: nil)
        let loginViewController=main.instantiateViewController(withIdentifier: "LoginViewController")
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        delegate.window?.rootViewController=loginViewController
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post=posts[indexPath.section]
        let comments=(post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row==comments.count+1{
            showsCommentBar=true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
        }
        /*comment["text"]="this is a random comment"
        comment["post"]=post
        comment["user"]=PFUser.current()!
        
        post.add(comment,forKey:"comments")
        
        post.saveInBackground { (success, error) in
            if success{
                print("comment saved")
            }
            else{
                print("Error saving comment")
            }
        }*/
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
