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
    let serverId = Expression<Int>("ServerId")

    public override init() {
    }

    //=================================================
    /** Fetch data from database based on category and returns an array
     *@param searchType contains the selected category
     *@return nearByArray contains the array of city information based on selected category
     */
    //=================================================
    func getDatafromDB(searchType: [String], isAllCategories: Bool) -> [NearByInfo] {

        var nearbyArray = [NearByInfo]()
        let writableDBPath = self.getDatabasePath()
        var database: Connection
        do {
            database = try Connection(writableDBPath)
            if isAllCategories == false {
                for searchStr in searchType {
                    let query = table.filter(locationType == searchStr)
                    let items = try database.prepare(query)

                    for item in items {
                        let info = NearByInfo()
                        info.nearFacilityName = item[facilityName]
                        info.nearLocationType = item[locationType]
                        info.nearLat = item[lat]
                        info.nearLong = item[long]
                        info.nearAddress = item[address]
                        nearbyArray.append(info)

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
                    nearbyArray.append(info)

                }

            }

            return nearbyArray

        }
        catch let error as NSError {
            print(error)
        }
        return nearbyArray
    }

    //=================================================
    /** Adding neighbourhood info data into database
     * @param addSqlite contains the dictionary of adding city information
     * @param type checks if whole sqlite needs to be changes or some part
     * @return 1 if successfully inserted else 0
     */
    //=================================================
    public func addDataInSqlite(addSqlite: NSDictionary, type: String) -> Int {
        let nearbyArray = NSMutableArray()
        let writableDBPath = self.getDatabasePath()
        var database: Connection
        do {
            database = try Connection(writableDBPath)
            let nameArray: NSArray = addSqlite.object(forKey: "Name") as! NSArray
            let categoryArray: NSArray = addSqlite.object(forKey: "Category") as! NSArray
            let addressArray: NSArray = addSqlite.object(forKey: "Address") as! NSArray
            let latArray: NSArray = addSqlite.object(forKey: "Latitude") as! NSArray
            let longArray: NSArray = addSqlite.object(forKey: "Longitude") as! NSArray
            let serverIDArray: NSArray = addSqlite.object(forKey: "ServerID") as! NSArray
            if nameArray.count > 0 {
                if type == "All" {
                    try database.run(table.delete())
                    var i: Int = 0
                    for name in nameArray {
                        let insert = table.insert(facilityName <- name as! String, address <- addressArray.object(at: i) as! String, locationType <- categoryArray.object(at: i) as! String, lat <- latArray.object(at: i) as! String, long <- longArray.object(at: i) as! String, serverId <- serverIDArray.object(at: i) as! Int)
                        let rowId = try database.run(insert)
                        i = i + 1
                    }


                }
                    else if type == "Change" {
                    var i: Int = 0
                    for name in nameArray {
                        let insert = table.insert(facilityName <- name as! String, address <- addressArray.object(at: i) as! String, locationType <- categoryArray.object(at: i) as! String, lat <- latArray.object(at: i) as! String, long <- longArray.object(at: i) as! String, serverId <- serverIDArray.object(at: i) as! Int)
                        try database.run(insert)
                        i = i + 1
                    }

                }
            }

        }
        catch let error as NSError {
            print(error)
            return 0
        }
        return 1
    }

    //=================================================
    /** Updating neighbourhood info data into database
     * @param updateSqlite contains the dictionary of updating city information
     * @return 1 if successfully updated else 0
     */
    //=================================================
    
    public func updateDataInSqlite (updateSqlite: NSDictionary) -> Int {
        let writableDBPath = self.getDatabasePath()
        var database: Connection
        do {
            database = try Connection(writableDBPath)
            let nameArray: NSArray = updateSqlite.object(forKey: "Name") as! NSArray
            let categoryArray: NSArray = updateSqlite.object(forKey: "Category") as! NSArray
            let addressArray: NSArray = updateSqlite.object(forKey: "Address") as! NSArray
            let latArray: NSArray = updateSqlite.object(forKey: "Latitude") as! NSArray
            let longArray: NSArray = updateSqlite.object(forKey: "Longitude") as! NSArray
            let serverIDArray: NSArray = updateSqlite.object(forKey: "ServerID") as! NSArray
            var i: Int = 0
            if serverIDArray.count > 0 {
                for serverid in serverIDArray {
                    let ServerIDVal = serverid as! Int
                    let query = table.filter(serverId == ServerIDVal).update(facilityName <- nameArray.object(at: i) as! String as! String, address <- addressArray.object(at: i) as! String, locationType <- categoryArray.object(at: i) as! String, lat <- latArray.object(at: i) as! String, long <- longArray.object(at: i) as! String)
                    let rowId = try database.run(query)
                    i = i + 1
                }
                
            }
        }
        catch let error as NSError {
            print(error)
            return 0
        }
        return 1
    }

    //=================================================
    /** Deleting neighbourhood info data into database
     * @param deleteSqlite contains the array of deleting city information
     * @return 1 if successfully deleted else 0
     */
    //=================================================
    public func deleteDataInSqlite(deleteSqlite: NSArray) {
        let writableDBPath = self.getDatabasePath()
        var database: Connection
        do {
            database = try Connection(writableDBPath)
            for serverid in deleteSqlite {
                let ServerIDVal = serverid as! Int
                let query = table.filter(serverId == ServerIDVal)
                try database.run(query.delete())

            }
        }
        catch let error as NSError {
            print(error)
        }
    }

    func filterTypesFromDatabase() -> [FilterObject] {
        var filterArray = [FilterObject]()
        let writableDBPath = self.getDatabasePath()
        var database: Connection
        do {
            database = try Connection(writableDBPath)
            let items = try database.prepare(table.select(distinct: locationType))
            for item in items {
                let fObj = FilterObject()
                fObj.filterID = item[locationType]
                fObj.filterValue = item[locationType]
                filterArray.append(fObj)
            }
        }
        catch let error as NSError {
            print(error)
        }
        return filterArray
    }

    func getDatabasePath() -> String {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let writableDBPath = documentsDirectory.appending("/NearBy.sqlite")
        self.checkAndCopyDbIfRequired(databasePath: writableDBPath)
        return writableDBPath
    }

    func checkAndCopyDbIfRequired(databasePath: String) {
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
