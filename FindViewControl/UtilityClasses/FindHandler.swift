//
//  FindHandler.swift
//  Pods
//
//  Created by Krutika Mac Mini on 3/17/17.
//
//

import SQLite

public class FindHandler: NSObject {
    
    let table = Table("CityInfoDB")
    let locationType = Expression<String>("LocationType")
    let facilityName = Expression<String>("FacilityName")
    let address = Expression<String>("Address")
    let lat = Expression<String>("Lat")
    let long = Expression<String>("Long")
    let phone = Expression<String>("Phone")
    let website = Expression<String>("Website")
    let entranceDetails = Expression<String>("EntranceDetails")
    let specialNotes = Expression<String>("SpecialNotes")
    let operatingHours = Expression<String>("OperatingHours")
    let email = Expression<String>("Email")
    
    public override init() {
    }
    
    
    public func getDatafromDB(searchType:NSArray, isAllCategories: Bool) -> NSMutableArray{
        
        let nearbyArray = NSMutableArray()
        let writableDBPath = self.getDatabasePath()
        var database: Connection
        do {
            database = try Connection(writableDBPath)
            if isAllCategories == false {
                for search in searchType {
                    let searchStr = search as? String
                    let query =  table.filter(locationType == searchStr!)
                    let items = try database.prepare(query)
                    
                    for item in items {
                        let info = NearByInfo()
                        info.nearFacilityName = item[facilityName]
                        info.nearLocationType = item[locationType]
                        info.nearLat = item[lat]
                        info.nearLong = item[long]
                        info.nearAddress = item[address]
                        nearbyArray.add(info)
                        
                    }
                    
                }
                
            }
            else {
                let items = try database.prepare(table)
                for item in items {
                    let info = NearByInfo()
                    info.nearFacilityName = item[facilityName]
                    info.nearLocationType = item[locationType]
                    info.nearLat = item[lat]
                    info.nearLong = item[long]
                    info.nearAddress = item[address]
                    nearbyArray.add(info)
                    
                }
                
            }
            
            return nearbyArray
            
        }
        catch {
            // Catch fires here, with an NSError being thrown
            print("error occurred")
        }
        return nearbyArray
    }
    
    
    
    
    
    func getDatabasePath() -> String {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let writableDBPath = documentsDirectory.appending("/NearBy.sqlite")
        self.checkAndCopyDbIfRequired(databasePath: writableDBPath)
        return writableDBPath
    }
    
    func checkAndCopyDbIfRequired(databasePath : String) {
        var success: Bool
        let fileManager = FileManager.default
        success = fileManager.fileExists(atPath: databasePath)
        if success == false {
            let defaultDBPath = Bundle.main.resourcePath?.appending("/NearBy.sqlite")
            do {
                try fileManager.copyItem(atPath: defaultDBPath!, toPath: databasePath)
            }
            catch {
                // Catch fires here, with an NSError being thrown
                print("error occurred")
            }
            
        }
    }

}
