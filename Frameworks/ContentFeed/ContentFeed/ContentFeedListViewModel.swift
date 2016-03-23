//
//  ContentFeedListViewModel.swift
//  ContentFeed
//
//  Copyright © 2016 athenahealth. All rights reserved.
//

class ContentFeedCellViewModel: NSObject {
    var title: String
    var subtitle: String
    var source: String
    var imageURL: NSURL?
    var contentURL: NSURL?
    var hasImage: Bool {
        return imageURL != nil
    }
    var read: Bool = false
    private var dateReceived: NSDate
    var receivedLapseTime: String {
        return calcReceivedLapseTime(dateReceived)
    }
    
    init(title: String, subtitle: String, source: String, dateReceived: NSDate) {
        self.title = title
        self.subtitle = subtitle
        self.source = source
        self.dateReceived = dateReceived
    }
    
    /**
        Calculates the lapse time since receiving the feed. If the lapse time is less
        than 1hr, returns minutes; else if less than a day, returns hours; else return days.
        - parameter data: receiving timestamp, NSDate
        - returns: lapse time in string
     */
    private func calcReceivedLapseTime(date: NSDate) -> String {
        var retVal = ""
        let now = NSDate()
        let lapseTimeInHours = now.timeIntervalSinceDate(date) / 3600.0
        if lapseTimeInHours / 24.0 >= 1 /* longer than 1d */ {
            retVal = "\(Int(lapseTimeInHours/24))d ago"
        } else if lapseTimeInHours < 1 {
            retVal = "\(Int(lapseTimeInHours * 60))m ago"
        } else {
            retVal = "\(Int(lapseTimeInHours))h ago"
        }
        
        return retVal
    }
}

class ContentFeedListViewModel: NSObject {
    lazy var vmArray = [ContentFeedCellViewModel]()
    
    override init() {
        super.init()
        self.populateList()
    }
    
    //    init(contentFeedItems: [ContentFeedItem]) {
    //
    //    }
    
    /**
        Gives tableView data source the number of items.
        - returns: item count Int
     */
    func itemCount() -> Int {
        return vmArray.count
    }
    
    /**
        Gives tableView data source the view model at the index path.
        - parameter forIndexPath: NSIndexPath
        - returns: ContentFeedCellViewModel
     */
    func viewModel(forIndexPath indexPath: NSIndexPath) -> ContentFeedCellViewModel {
        return vmArray[indexPath.row]
    }
    
    /**
        Mock data for testing
     */
    private func populateList() {
        var vm = ContentFeedCellViewModel(title: "Keveyis, New Treatment for Periodic Paralysis, Now Available",
            subtitle: "The first FED-approved drug for Periodic Paralysis nwo available",
            source: "NIH",
            dateReceived: NSDate(timeIntervalSinceNow: -10000))
        vm.contentURL = NSURL(string: "http://google.com")
        vmArray.append(vm)
        
        vm = ContentFeedCellViewModel(title: "CDC adds countries to interim travel guidance related to Zika virus",
            subtitle: "CDC is working with other countries to interim travel guidance related to Zika virus",
            source: "CDC",
            dateReceived: NSDate(timeIntervalSinceNow: -100))
        //vm.hasImage = true
        vm.imageURL = NSURL(string: "https://upload.wikimedia.org/wikipedia/commons/f/f4/Loch_Ness_Muppet.jpg")
        vm.contentURL = NSURL(string: "http://sfgate.com")
        vmArray.append(vm)
        
        vm = ContentFeedCellViewModel(title: "What Works to Prevent Low Back Pain?",
            subtitle: "Exercise and education together might be effective.",
            source: "NEJM Journal Watch",
            dateReceived: NSDate(timeIntervalSinceNow: -3600 * 24))
        vmArray.append(vm)
        
        for i in 0..<100 {
            let vm = ContentFeedCellViewModel(title: "What Works to Prevent Low Back Pain?" + String(count: i+1, repeatedValue: Character("a")),
                subtitle: "Exercise and education together might be effective." + String(count: i+1, repeatedValue: Character("a")),
                source: "NEJM Journal Watch",
                dateReceived: NSDate(timeIntervalSinceNow: -3600 * (100-Double(i))))
            if (i % 2 == 0) {
                //vm.imageURL = NSURL(string: "https://upload.wikimedia.org/wikipedia/commons/6/63/Ogo-Pogo%2C_The_Funny_Fox-Trot.jpg")
                vm.imageURL = NSURL(string: "https://upload.wikimedia.org/wikipedia/commons/0/0a/Knossos_fresco_in_throne_palace.JPG")
                //vm.imageURL = NSURL(string: "https://upload.wikimedia.org/wikipedia/commons/f/f4/Loch_Ness_Muppet.jpg")
            } else {
                //vm.imageURL = NSURL(string: "https://upload.wikimedia.org/wikipedia/commons/0/0a/Knossos_fresco_in_throne_palace.JPG")
                vm.imageURL = NSURL(string: "https://upload.wikimedia.org/wikipedia/commons/f/f4/Loch_Ness_Muppet.jpg")
            }
            
            /*
            //let urlString = "http://dummyimage.com/88/"+"\(arc4random() % 0xFFFFF)"+"/"+"\(arc4random() % 0xFFFFF)"+"&text=\(i%2+1)"
            let urlString = "http://dummyimage.com/88/638E18/592C81"+"&text=\(i%2+1)"
            vm.imageURL = NSURL(string: urlString)
            */
            vm.read = (i % 2 == 0)
            vm.contentURL = NSURL(string: "http://www.cdc.gov/")
            vmArray.append(vm)
        }
        
    }
}