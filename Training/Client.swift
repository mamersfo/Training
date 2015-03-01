import Foundation

class Client {

    class func deleteRequest( url: String,
        handler: (status: Int, body: AnyObject?) -> ()) -> ()
    {
        var err: NSError?
        let req = NSMutableURLRequest(URL: NSURL(string: url)!)
        req.HTTPMethod = "DELETE"
        
        let session = NSURLSession.sharedSession()
        
        var task = session.dataTaskWithRequest(req, completionHandler: { data, response, error -> Void in
            if let resp = response as? NSHTTPURLResponse {
                if let result: AnyObject =
                    NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) {
                    handler(status: resp.statusCode, body: result)
                }
                else {
                    handler(status: resp.statusCode, body: nil)
                }
            }
        })
        
        task.resume()
    }

    class func getRequest( url: String,
        handler: (status: Int, body: AnyObject?) -> ()) -> ()
    {
        var err: NSError?
        let req = NSURLRequest(URL: NSURL(string: url)!)
        
        let session = NSURLSession.sharedSession()
        
        var task = session.dataTaskWithRequest(req, completionHandler: { data, response, error -> Void in
            if let resp = response as? NSHTTPURLResponse {
                if let result: AnyObject =
                    NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) {
                        handler(status: resp.statusCode, body: result)
                }
                else {
                    handler(status: resp.statusCode, body: nil)
                }
            }
        })
        
        task.resume()
    }
    
    class func postRequest( url: String, body: Dictionary<String,AnyObject> ,
        handler: (status: Int, body: AnyObject?) -> ()) -> ()
    {
        var err: NSError?
        let req = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        req.HTTPMethod = "POST"
        
        req.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: nil, error: &err)
        
        if ( err != nil ) {
            println(err!.localizedDescription)
        }
        else {
            let session = NSURLSession.sharedSession()
            
            var task = session.dataTaskWithRequest(req, completionHandler: { data, response, error -> Void in
                if let resp = response as? NSHTTPURLResponse {
                    if let result: AnyObject =
                        NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) {
                            handler(status: resp.statusCode, body: result)
                    }
                    else {
                        handler(status: resp.statusCode, body: nil)
                    }
                }
            })
            
            task.resume()
        }
    }
    
    class func putRequest( url: String, body: Dictionary<String,AnyObject>,
        handler: (status :Int, body: NSDictionary?) -> ()) -> ()
    {
        var err: NSError?
        let req = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        req.HTTPMethod = "PUT"
        
        req.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: nil, error: &err)
        
        if ( err != nil ) {
            println(err!.localizedDescription)
        }
        else {
            let session = NSURLSession.sharedSession()
            
            var task = session.dataTaskWithRequest(req, completionHandler: { data, response, error -> Void in

                if let resp = response as? NSHTTPURLResponse {
                    if let result: AnyObject =
                        NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) {
                            handler(status: resp.statusCode, body: result as? NSDictionary)
                    }
                    else {
                        handler(status: resp.statusCode, body: nil)
                    }
                }
            })
            
            task.resume()
        }
    }
}