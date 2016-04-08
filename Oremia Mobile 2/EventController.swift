//
//  EventController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 05/10/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import Foundation
import EventKit
@objc class EventManager:NSObject, APIControllerProtocol {
    var eventStore = EKEventStore()
    var calendars: [EKCalendar]? = []
    var TypesRDV: [TypeRDV] = []
    var defaultCalendar: EKCalendar?
    var CalDavRessource : NSDictionary?
    var allCalendars: [EKCalendar]? = []
    lazy var api = APIController()
    var internalEvent = Evennement()
    var selectedCalendarIdentifier: String?
    static var eventsFromToday:[EKEvent]?
    static var allEvents:[EKEvent]?
    var editEvent:EKEvent?
    var agenda:MSCalendarViewController?
    
    override init(){
        super.init()
        self.api.delegate = self
        api.sendRequest("select * from calendar_events_modeles")
        let status = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        switch (status) {
        case EKAuthorizationStatus.NotDetermined:
            // This happens on first-run
            self.requestAccessToCalendar()
        case EKAuthorizationStatus.Authorized:
            // Things are in line with being able to show the calendars in the table view
            self.loadCalendars()
            self.loadDefaultCalendar()
            
        case EKAuthorizationStatus.Restricted, EKAuthorizationStatus.Denied:
            // We need to help them give us permission
            break
            
        }
    }
    func checkCalendarAuthorizationStatus() -> Bool {
        let status = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        var vretour = false
        switch (status) {
        case EKAuthorizationStatus.NotDetermined:
            // This happens on first-run
            requestAccessToCalendar()
        case EKAuthorizationStatus.Authorized:
            // Things are in line with being able to show the calendars in the table view
            if agenda != nil {
                loadCalendars()
            }
            vretour = true
        case EKAuthorizationStatus.Restricted, EKAuthorizationStatus.Denied:
            // We need to help them give us permission
            vretour = false
        }
        return vretour
    }
    func requestAccessToCalendar() ->Bool {
        var vretour = false
        eventStore.requestAccessToEntityType(EKEntityType.Event) { (accessGranted, error) -> Void in
            if accessGranted == true {
                dispatch_async(dispatch_get_main_queue(), {
                    self.loadCalendars()
                    vretour = true
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    vretour = false
                })
            }
        }
        return vretour
    }
    func loadDefaultCalendar() {
        let calendarArray = api.getPref("calendrierpardefaut")
        if(calendarArray.count==0){
            let kalendar = allCalendars![(allCalendars?.count)!-1]
            api.addPref("calendrierpardefaut", prefs: [kalendar.title])
            self.defaultCalendar = kalendar
            api.readPreference()
        } else {
            for k in allCalendars! {
                for x in calendarArray{
                    if(k.title == x){
                        self.defaultCalendar = k
                    }
                    
                }
            }
        }
        
    }
    func loadCalendars() {
        self.calendars = eventStore.calendarsForEntityType(EKEntityType.Event)
        self.allCalendars = eventStore.calendarsForEntityType(EKEntityType.Event)
//        eventStore.reset()
        do {
            try eventStore.commit()
        } catch {
            print("An error occured \(error)")
        }
        eventStore.refreshSourcesIfNecessary()
        if agenda != nil{
            api.getCalDavRessources()
        }
        var bidule = [EKCalendar]()
        let calendarArray = api.getPref("calendrier")
        var v = 0;
        for k in calendars! {
            v = 0
            for x in calendarArray{
                if(k.title == x){
                    k.refresh()
                    bidule.append(k)
                }
                v++
            }
        }
        var titles = [String]()
        if(calendarArray.count==0){
            for k in calendars! {
                titles.append(k.title)
            }
            api.addPref("calendrier", prefs: titles)
            api.readPreference()
        } else {
            self.calendars = bidule
        }
        
    }
    
    
    func getEventsOfSelectedCalendar(tableView : UITableView) -> [EKEvent] {
        var uniqueEventsArray: [EKEvent] = []
        if EventManager.eventsFromToday?.count == nil{
            let auj = NSDate()
            let dateFormat = NSDateFormatter()
            dateFormat.dateStyle = .ShortStyle
            if calendars?.count > 0 {
                for k in calendars! {
                    
                    var calendarsArray: [EKCalendar]
                    calendarsArray = [k]
                    let yearSeconds: Double = 365 * (60 * 60 * 24)
                    let predicate: NSPredicate = self.eventStore.predicateForEventsWithStartDate(NSDate(timeIntervalSinceNow: -yearSeconds), endDate: NSDate(timeIntervalSinceNow:  yearSeconds), calendars: calendarsArray)
                    var eventsArray: [AnyObject] = self.eventStore.eventsMatchingPredicate(predicate)
                    
                    for var i = 0; i < eventsArray.count; i++ {
                        let currentEvent: EKEvent =  eventsArray[i] as! EKEvent
                        var eventExists: Bool = false
                        if currentEvent.recurrenceRules != nil && currentEvent.recurrenceRules!.count > 0 {
                            for var j = 0; j < uniqueEventsArray.count; j++ {
                                if uniqueEventsArray[j].eventIdentifier == currentEvent.eventIdentifier {
                                    eventExists = true
                                }
                            }
                        }
                        if !eventExists && auj.compare(currentEvent.startDate) == NSComparisonResult.OrderedAscending {
                            uniqueEventsArray.append(currentEvent)
                        }
                    }
                }
            }
            uniqueEventsArray = uniqueEventsArray.sort{ $0.compareStartDateWithEvent($1) == .OrderedAscending }
            EventManager.eventsFromToday = uniqueEventsArray
        } else {
            uniqueEventsArray = EventManager.eventsFromToday!
        }
        
        
        return uniqueEventsArray
    }
    
    func getEventsOfSelectedCalendar() -> [EKEvent] {
        var uniqueEventsArray: [EKEvent] = []
        let auj = NSDate()
        let dateFormat = NSDateFormatter()
        dateFormat.dateStyle = .ShortStyle
        if calendars?.count > 0 {
            for k in calendars! {
                var calendarsArray: [EKCalendar]
                calendarsArray = [k]
                let yearSeconds: Double = 365 * (60 * 60 * 24)
                let predicate: NSPredicate = self.eventStore.predicateForEventsWithStartDate(NSDate(timeIntervalSinceNow: -yearSeconds), endDate: NSDate(timeIntervalSinceNow:  yearSeconds), calendars: calendarsArray)
                var eventsArray: [AnyObject] = self.eventStore.eventsMatchingPredicate(predicate)
                for var i = 0; i < eventsArray.count; i++ {
                    let currentEvent: EKEvent =  eventsArray[i] as! EKEvent
                    var eventExists: Bool = false
                    if currentEvent.recurrenceRules != nil && currentEvent.recurrenceRules!.count > 0 {
                        for var j = 0; j < uniqueEventsArray.count; j++ {
                            if uniqueEventsArray[j].eventIdentifier == currentEvent.eventIdentifier {
                                eventExists = true
                            }
                        }
                    }
                    if !eventExists  {
                        uniqueEventsArray.append(currentEvent)
                    }
                }
            }
        }
        
        
        
        let component = NSDateComponents()
        var aujDefault:EKEvent
        var laDate:NSDate
        for var i:Int = -180; i<180; i++ {
            aujDefault = EKEvent(eventStore: eventStore)
            aujDefault.title = "Ceci est une erreur"
            component.day = i
            laDate = NSCalendar.currentCalendar().dateByAddingComponents(component, toDate: auj, options: NSCalendarOptions.MatchStrictly)!
            aujDefault.startDate = laDate
            aujDefault.endDate = laDate
            uniqueEventsArray.append(aujDefault)
        }
        uniqueEventsArray = uniqueEventsArray.sort{ $0.compareStartDateWithEvent($1) == .OrderedAscending }
        EventManager.allEvents = uniqueEventsArray
        return uniqueEventsArray
    }
    func getEventsOfSelectedCalendarForCertainDate(date:NSDate) -> [EKEvent] {
        var uniqueEventsArray: [EKEvent] = []
        let dateFormat = NSDateFormatter()
        dateFormat.dateStyle = .ShortStyle
        if calendars?.count > 0 {
            for k in calendars! {
                var calendarsArray: [EKCalendar]
                calendarsArray = [k]
                let yearSeconds: Double = 365 * (60 * 60 * 24)
                let predicate: NSPredicate = self.eventStore.predicateForEventsWithStartDate(NSDate(timeIntervalSinceNow: -yearSeconds), endDate: NSDate(timeIntervalSinceNow:  yearSeconds), calendars: calendarsArray)
                var eventsArray: [AnyObject] = self.eventStore.eventsMatchingPredicate(predicate)
                for var i = 0; i < eventsArray.count; i++ {
                    let currentEvent: EKEvent =  eventsArray[i] as! EKEvent
                    var eventExists: Bool = false
                    if currentEvent.recurrenceRules != nil && currentEvent.recurrenceRules!.count > 0 {
                        for var j = 0; j < uniqueEventsArray.count; j++ {
                            if uniqueEventsArray[j].eventIdentifier == currentEvent.eventIdentifier {
                                eventExists = true
                            }
                        }
                    }
                    if !eventExists  {
                        uniqueEventsArray.append(currentEvent)
                    }
                }
            }
        }
        
        
        
        let component = NSDateComponents()
        var aujDefault:EKEvent
        var laDate:NSDate
        for var i:Int = -180; i<180; i++ {
            aujDefault = EKEvent(eventStore: eventStore)
            aujDefault.title = "Ceci est une erreur"
            component.day = i
            laDate = NSCalendar.currentCalendar().dateByAddingComponents(component, toDate: date, options: NSCalendarOptions.MatchStrictly)!
            aujDefault.startDate = laDate
            aujDefault.endDate = laDate
            uniqueEventsArray.append(aujDefault)
        }
        uniqueEventsArray = uniqueEventsArray.sort{ $0.compareStartDateWithEvent($1) == .OrderedAscending }
        return uniqueEventsArray
    }
    func sortEventsByDay(uniqueEventsArray: [EKEvent]) -> NSArray {
        var section:NSDictionary
        var vretour:[NSDictionary] = []
        var lesDates:[EKEvent] = []
        var currentDate : NSDate = NSDate()
        let dateFormat = NSDateFormatter()
        dateFormat.dateStyle = .ShortStyle
        for k in uniqueEventsArray{
            if dateFormat.stringFromDate(currentDate) == dateFormat.stringFromDate(k.startDate){
                lesDates.append(k)
            }else {
                section = ["date" : currentDate, "lesDates" : lesDates]
                vretour.append(section)
                currentDate = k.startDate
                lesDates = []
                lesDates.append(k)
            }
            
        }
        return vretour
    }

    func insertEvent(title:String, startDate:NSDate, endDate:NSDate, notes:String, reminder:Bool ) -> Bool {
        var vretour = true
//        self.eventStore = EKEventStore()
        let event = EKEvent(eventStore: eventStore)
        
        for calendar in calendars! {
            // 2
            if calendar.title == selectedCalendarIdentifier {
                // Create Event
                event.calendar = calendar
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                event.notes = notes
                if reminder{
                    vretour = createReminder("Rendez-vous avec : "+title, dateReminder: startDate)
                }
                // Save Event in Calendar
                do{
                    try eventStore.saveEvent(event, span: EKSpan.ThisEvent, commit: true)
                } catch {
                    vretour = false
                    print("An error occured \(error)")
                }
                
                
            }
        }
        self.internalEvent.event = event
        self.internalEvent.insertEvent()
        return vretour
    }
    func editEvent(title:String, startDate:NSDate, endDate:NSDate, notes:String, reminder:Bool ) -> Bool {
        var vretour = false
        if editEvent != nil {
            let mabite = editEvent!.eventIdentifier.characters.split{$0 == ":"}.map(String.init)
            for calendar in calendars! {
                // 2
                if calendar.title == selectedCalendarIdentifier {
//                    let store = EKEventStore()
                    self.editEvent = eventStore.eventWithIdentifier(editEvent!.eventIdentifier)
                    //editEvent!.calendar = calendar
                    editEvent!.title = title
                    editEvent!.startDate = startDate
                    editEvent!.endDate = endDate
                    editEvent!.notes = notes
                    if reminder{
                        vretour = createReminder("Rendez-vous avec : "+title, dateReminder: startDate)
                    }
                    
                    // 5
                    // Save Event in Calendar
                    do{
                        self.internalEvent.event = editEvent
                        vretour = true
                        let ressources = CalDavRessource?[mabite[1]] as? String
                        if ressources != nil || editEvent?.calendar.source.title != "iCloud"{
                            try eventStore.saveEvent(editEvent!, span: EKSpan.ThisEvent, commit: true)
                            internalEvent.updateCalDavEvent(mabite[1])
                            self.loadCalendars()
                        } else {
                            try eventStore.saveEvent(editEvent!, span: EKSpan.ThisEvent, commit: true)
                            internalEvent.updateEvent()
                        }
                        
                        
                    } catch {
                        vretour = false
                        print("An error occured \(error)")
                    }
                    
                    
                }
            }
            
        }
        return vretour
    }
    func deleteEvent() -> Bool {
        var vretour = false
        if editEvent != nil {
            self.editEvent = eventStore.eventWithIdentifier(editEvent!.eventIdentifier)
            do{
                vretour = true
                if(editEvent != nil) {try eventStore.removeEvent(editEvent!, span: EKSpan.ThisEvent, commit: true)}
                
            } catch {
                vretour = false
                print("An error occured \(error)")
            }
            
        }
        internalEvent.deleteEvent()
        return vretour
    }
    func createReminder(reminderTitle: String, dateReminder: NSDate) -> Bool{
        var vretour = true
        let calendarDatabase = EKEventStore()
        let timeInterval = dateReminder.dateByAddingTimeInterval(-60*60)
        calendarDatabase.requestAccessToEntityType(EKEntityType.Reminder, completion: {_,_ in })
        
        let reminder = EKReminder(eventStore: calendarDatabase)
        
        reminder.title = reminderTitle
        
        let alarm = EKAlarm(absoluteDate: timeInterval)
        
        reminder.addAlarm(alarm)
        
        reminder.calendar = calendarDatabase.defaultCalendarForNewReminders()
        
        do{
            try calendarDatabase.saveReminder(reminder, commit: true)
        } catch {
            vretour = false
            print("An error occured ")
        }
        return vretour
    }
    func addNewEventToArray(date:NSDate) -> NSArray{
        let component = NSDateComponents()
//        self.eventStore = EKEventStore()
        let nouvelEvt = EKEvent(eventStore: eventStore)
        var endDate:NSDate
        nouvelEvt.title = "Nouveau rendez-vous"
        component.hour = 1
        endDate = NSCalendar.currentCalendar().dateByAddingComponents(component, toDate: date, options: NSCalendarOptions.MatchStrictly)!
        nouvelEvt.startDate = date
        nouvelEvt.endDate = endDate
        nouvelEvt.calendar = defaultCalendar!
        do{
            _ = try eventStore.saveEvent(nouvelEvt, span: EKSpan.ThisEvent, commit: true)
            self.internalEvent.event = nouvelEvt
            self.internalEvent.insertEvent()
            EventManager.allEvents?.append(nouvelEvt)
            EventManager.allEvents! = EventManager.allEvents!.sort{ $0.compareStartDateWithEvent($1) == .OrderedAscending }
        } catch {
            
            print("An error occured \(error)")
        }
        
        return self.sortEventsByDay(EventManager.allEvents!)
    }
    func setDefautCalendar(dCal:EKCalendar){
        api.addPref("calendrierpardefaut", prefs: [dCal.title])
        self.defaultCalendar = dCal
        api.readPreference()
    }
    func didReceiveAPIResults(results: NSDictionary) {
        self.CalDavRessource = results["results"] as? NSDictionary
        
        if let dict = results["results"] as? NSDictionary {
            for (key,value) in dict{
                self.CalDavRessource!.setValue(value, forKey: key as! String)
            }
            self.agenda?.reloadItMotherFucker()

        }else {
            if let type = results["results"] as? NSArray {
                self.TypesRDV = TypeRDV.typesWithJSON(type)
            }
        }
        NSLog("")
    }
    func handleError(results: Int) {
        api.getCalDavRessources()
        
    }
}