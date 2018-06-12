//
//  DynamoDBManager.swift
//  Auflyer
//
//  Created by Yingyong on 2018/5/31.
//

import UIKit
import AWSDynamoDB
import AWSCognito
import AWSCore
import AWSAuthUI
import AWSGoogleSignIn
import SkyFloatingLabelTextField

class DynamoDBManager: NSObject {
    
    static let _sharedManager = DynamoDBManager()
    
    override init() {
        super.init()
        
    }
    
    func getData(model : AnyClass, indexName : String, completion: @escaping (_ task : AWSTask<AWSDynamoDBPaginatedOutput>?) -> Void){
        
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = indexName
        queryExpression.keyConditionExpression = "#userId = :userId"
        queryExpression.expressionAttributeNames = ["#userId": "userId",]
        queryExpression.expressionAttributeValues = [":userId" : AWSIdentityManager.default().identityId!]
        AWSDynamoDBObjectMapper.default().query(model.self, expression: queryExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
            if let error = task.error as NSError? {
                print("The request failed. Error: \(error)")
            } else if task.result != nil {
                completion(task)
            }
            return nil
        })
    }
    
    func saveData(model : AWSDynamoDBObjectModel, completion: @escaping () -> Void){ 
        
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        
        //Save a new item
        dynamoDbObjectMapper.save(model as! AWSDynamoDBObjectModel & AWSDynamoDBModeling).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as NSError? {
                print("The request failed. Error: \(error)")
            } else {
                completion()
            }
            return nil
        })
    }
    
    func deleteData(model : AWSDynamoDBObjectModel, completion: @escaping () -> Void){
        
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        
        dynamoDbObjectMapper.remove(model as! AWSDynamoDBObjectModel & AWSDynamoDBModeling).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as NSError? {
                print("The request failed. Error: \(error)")
            } else {
                completion()
            }
            return nil
        })
    }
}

