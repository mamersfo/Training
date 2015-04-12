import Foundation

class Repository {
    
    class func read( key: String ) -> [String] {
        let settings = NSUserDefaults.standardUserDefaults()
        
        if let result = settings.stringArrayForKey(key) as? [String] {
            return result
        }
        
        return [String]()
    }
    
    class func create( key: String ) {
        let settings = NSUserDefaults.standardUserDefaults()
        settings.setValue([String](), forKey: key)
    }
    
    class func update( key: String, value: [String] ) {
        let settings = NSUserDefaults.standardUserDefaults()
        settings.setValue(value, forKey: key)
    }
    
    class func delete( key: String ) {
        let settings = NSUserDefaults.standardUserDefaults()
        settings.removeObjectForKey(key)
    }
}