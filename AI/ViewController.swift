//
//  ViewController.swift
//  AI
//
//  Created by 田中颯太 on 2017/03/27.
//  Copyright © 2017年 田中颯太. All rights reserved.
//

import UIKit
import Photos
import SwiftyJSON


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    //表示するイメージ
    @IBOutlet var images: UIImageView!
    //テスト用
    @IBOutlet var textView: UITextView!
    var selectedimage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        images.image = UIImage(named: "pa")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //カメラロールから選ぶ
    @IBAction func startimage (){
        self.selectFromCameralole()
        
    }
    //写真を撮る
    @IBAction func startphoto () {
        opencamera()
    }
    @IBAction func sendData () {
        callApi(image: selectedimage)
        self.textView.text = ""
    }
    
    
    //UIImagePickerControllerに関しての記述
    func opencamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerControllerSourceType.camera
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        } else {
            _ = UIAlertController(title: "カメラ使用できません", message: "現在カメラを使うことが許可されておりません。設定から許可してください", preferredStyle: .actionSheet)
        }
    }
    func selectFromCameralole(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        } else {
            _ = UIAlertController(title: "アルバムが使用できません", message: "現在アルバムを使うことが許可されておりません。設定から許可してください", preferredStyle: .actionSheet)
        }
        
    }
    //imagesに撮った,選択した画像を代入。
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] {
            selectedimage = image as? UIImage
        }
        picker.dismiss(animated: true, completion: nil)
        images.image = selectedimage
    }
    
    //ImagePickerControllerの記述終わり
    
    //IBMにデータを送信するプログラムに関しての記述。
    func callApi(image: UIImage) {
        print ("canSendData")
        // 解析結果はAppDelegateの変数を経由してSubViewに渡す
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // API呼び出し準備
        let APIKey = "0e2b258a7464b736c81feaf313de6f19bd5ced06" // APIKeyを取得してここに記述   捨て垢(yahoo)使用中
        let url = "https://gateway-a.watsonplatform.net/visual-recognition/api/v3/classify?api_key=" + APIKey + "&version=2016-05-20"
        guard let destURL = URL(string: url) else {
            print ("url is NG: " + url) // debugF
            return
        }
        var request = URLRequest(url: destURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = UIImageJPEGRepresentation(image, 1)
        
        var dataStr:String?
        
        // activityIndicator始動
        // WatsonAPIコール
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if error == nil {
                
                
                //                appDelegate.analyzedFaces = self.interpretJson(image: image, json: json)
                
                // リクエストは非同期のため画面遷移をmainQueueで行わないとエラーになる
                OperationQueue.main.addOperation(
                    {
                        //　activityIndicator停止
                        
                        //                        if appDelegate.analyzedFaces.count > 0 {
                        //                            // 顔解析結果あり
                        //                            self.performSegue(withIdentifier: "ShowResult", sender: self)
                        //                        } else {
                        //                            // 顔解析結果なし
                        //                            let actionSheet = UIAlertController(title:"エラー", message: "顔検出されませんでした", preferredStyle: .alert)
                        //                            let actionCancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: {action in
                        //                            })
                        //                            actionSheet.addAction(actionCancel)
                        //                            self.present(actionSheet, animated: true, completion: nil)
                        //                        }
                        
                        
                        // APIレスポンス：正常
                        let json = JSON(data: data!)
                        print(json)
                        
                        print(json["images_processed"])
                        //                print(json.dictionaryValue)
                        
                        //                let jsonDictionary:Dictionary = json.dictionaryValue
                        
                        var classes : Dictionary = ["class": String(), "score": Float()] as [String : Any]
                        
                        classes["class"] =  json["images"][0]["classifiers"][0]["classes"][0]["class"].string
                        
                        for i in 0...20 {
                            
                            let textClasses =  json["images"][0]["classifiers"][0]["classes"][i]["class"].stringValue
                            let textScore = json["images"][0]["classifiers"][0]["classes"][i]["score"].stringValue
                            if textClasses != "" {
                            self.textView.text  = self.textView.text + "[\(textClasses),\(textScore )],"
                            // self.textView.text  = "[\(textClasses),\(textScore )],"
                            
                            
                            print( "classes[class]:\(classes["class"]!)")
                            
                            dataStr = classes["class"] as! String?
                            print( " dataStr:\( dataStr)")
                            }
                            
                        }
                        
                    }
                )
            } else {
                // APIレスポンス：エラー
                print(error.debugDescription)   // debug
            }
        }
        
        task.resume()
    }
    
    
    //JSONの解析及びトリミング
    //    func jsontorim (){
    //        let jsons = JSON(json)
    //       if jsons["images"][0]["classifiers"][0]["classes"][0]["class"].string != nil{
    //        print (jsons)
    //        }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
