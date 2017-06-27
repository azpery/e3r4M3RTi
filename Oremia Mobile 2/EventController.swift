//
//  EventController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 05/10/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import Foundation
import EventKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

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
    var version = "1"
    
    override init(){
        super.init()
        self.api.delegate = self
        api.sendRequest("select * from calendar_events_modeles")
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            // This happens on first-run
            self.requestAccessToCalendar()
        case EKAuthorizationStatus.authorized:
            // Things are in line with being able to show the calendars in the table view
            self.loadCalendars()
            self.loadDefaultCalendar()
            
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            // We need to help them give us permission
            self.requestAccessToCalendar()
            break
            
        }
    }
    func checkCalendarAuthorizationStatus() -> Bool {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        var vretour = false
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            // This happens on first-run
            requestAccessToCalendar()
        case EKAuthorizationStatus.authorized:
            // Things are in line with being able to show the calendars in the table view
            if agenda != nil {
                loadCalendars()
            }
            vretour = true
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            // We need to help them give us permission
            vretour = false
        }
        return vretour
    }
    func requestAccessToCalendar() ->Bool {
        var vretour = false
        DispatchQueue.main.async(execute: {
        self.eventStore.requestAccess(to: EKEntityType.event) { (accessGranted, error) -> Void in
            if accessGranted == true {
                
                    self.loadCalendars()
                    vretour = true
                
            } else {
                DispatchQueue.main.async(execute: {
                    vretour = false
                })
            }
        }
        })
        return vretour
    }
    func loadDefaultCalendar() {
        let calendarArray = api.getPref("calendrierpardefaut\(preference.idUser)")
        if(calendarArray.count==0){
            let kalendar = allCalendars![(allCalendars?.count)!-1]
            api.addPref("calendrierpardefaut\(preference.idUser)", prefs: [kalendar.title])
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
    
        self.calendars = eventStore.calendars(for: EKEntityType.event)
        self.allCalendars = eventStore.calendars(for: EKEntityType.event)
        //        eventStore.reset()
        do {
            try eventStore.commit()
        } catch {
            print("An error occured \(error)")
        }
        eventStore.refreshSourcesIfNecessary()
        
        var bidule = [EKCalendar]()
        let calendarArray = api.getPref("calendrier\(preference.idUser)")
        if agenda != nil{
            api.getCalDavRessources(Date(), calendars: calendarArray)
        }
        var v = 0;
        for k in calendars! {
            v = 0
            for x in calendarArray{
                if(k.title == x){
                    k.refresh()
                    bidule.append(k)
                }
                v += 1
            }
        }
        var titles = [String]()
        if(calendarArray.count==0){
            for k in calendars! {
                titles.append(k.title)
            }
            api.addPref("calendrier\(preference.idUser)", prefs: titles)
            api.readPreference()
        } else {
            self.calendars = bidule
            
        }
        
    }
    
    
    func getEventsOfSelectedCalendar(_ tableView : UITableView) -> [EKEvent] {
        var uniqueEventsArray: [EKEvent] = []
        if EventManager.eventsFromToday?.count == nil{
            let auj = Date()
            let dateFormat = DateFormatter()
            dateFormat.dateStyle = .short
            if calendars?.count > 0 {
                for k in calendars! {
                    
                    var calendarsArray: [EKCalendar]
                    calendarsArray = [k]
                    let yearSeconds: Double = 7 * (60 * 60 * 24)
                    let predicate: NSPredicate = self.eventStore.predicateForEvents(withStart: Date(timeIntervalSinceNow: -yearSeconds), end: Date(timeIntervalSinceNow:  yearSeconds), calendars: calendarsArray)
                    var eventsArray: [AnyObject] = self.eventStore.events(matching: predicate)
                    
                    for i in 0 ..< eventsArray.count {
                        let currentEvent: EKEvent =  eventsArray[i] as! EKEvent
                        var eventExists: Bool = false
//                        if currentEvent.recurrenceRules != nil && currentEvent.recurrenceRules!.count > 0 {
//                            for var j = 0; j < uniqueEventsArray.count; j++ {
//                                if uniqueEventsArray[j].eventIdentifier == currentEvent.eventIdentifier {
//                                    eventExists = true
//                                }
//                            }
//                        }
                        if  auj.compare(currentEvent.startDate) == ComparisonResult.orderedAscending {
                            uniqueEventsArray.append(currentEvent)
                        }
                    }
                }
            }
            uniqueEventsArray = uniqueEventsArray.sorted{ $0.compareStartDate(with: $1) == .orderedAscending }
            EventManager.eventsFromToday = uniqueEventsArray
        } else {
            uniqueEventsArray = EventManager.eventsFromToday!
        }
        
        
        return uniqueEventsArray
    }
    
    func getEventsOfSelectedCalendar() -> [EKEvent] {
        var uniqueEventsArray: [EKEvent] = []
        let auj = Date()
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .short
        if calendars?.count > 0 {
            for k in calendars! {
                var calendarsArray: [EKCalendar]
                calendarsArray = [k]
                let yearSeconds: Double = 8 * (60 * 60 * 24)
                let predicate: NSPredicate = self.eventStore.predicateForEvents(withStart: Date(timeIntervalSinceNow: -yearSeconds), end: Date(timeIntervalSinceNow:  yearSeconds), calendars: calendarsArray)
                var eventsArray: [AnyObject] = self.eventStore.events(matching: predicate)
                for i in 0 ..< eventsArray.count {
                    let currentEvent: EKEvent =  eventsArray[i] as! EKEvent
                    var eventExists: Bool = false
//                    if currentEvent.recurrenceRules != nil && currentEvent.recurrenceRules!.count > 0 {
//                        for var j = 0; j < uniqueEventsArray.count; j++ {
//                            if uniqueEventsArray[j].eventIdentifier == currentEvent.eventIdentifier {
//                                eventExists = true
//                            }
//                        }
//                    }
//                    if !eventExists  {
                        uniqueEventsArray.append(currentEvent)
//                    }
                }
            }
        }
        
        
        
        var component = DateComponents()
        var aujDefault:EKEvent
        var laDate:Date
        for i in (-7...7) {
            aujDefault = EKEvent(eventStore: eventStore)
            aujDefault.title = "Ceci est une erreur"
            component.day = i
            laDate = (Calendar.current as NSCalendar).date(byAdding: component, to: auj, options: NSCalendar.Options.matchStrictly)!
            aujDefault.startDate = laDate
            aujDefault.endDate = laDate
            uniqueEventsArray.append(aujDefault)
        }
        uniqueEventsArray = uniqueEventsArray.sorted{ $0.compareStartDate(with: $1) == .orderedAscending }
        EventManager.allEvents = uniqueEventsArray
        return uniqueEventsArray
    }
    func getEventsOfSelectedCalendarForCertainDate(_ date:Date) -> [EKEvent] {
        var uniqueEventsArray: [EKEvent] = []
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .short
        if calendars?.count > 0 {
            for k in calendars! {
                var calendarsArray: [EKCalendar]
                calendarsArray = [k]
                let yearSeconds: Double = 8 * (60 * 60 * 24)
                let predicate: NSPredicate = self.eventStore.predicateForEvents(withStart: date.addingTimeInterval( -yearSeconds), end: date.addingTimeInterval(yearSeconds), calendars: calendarsArray)
                var eventsArray: [AnyObject] = self.eventStore.events(matching: predicate)
                for i in 0 ..< eventsArray.count {
                    let currentEvent: EKEvent =  eventsArray[i] as! EKEvent
                    var eventExists: Bool = false
//                    if currentEvent.recurrenceRules != nil && currentEvent.recurrenceRules!.count > 0 {
//                        for var j = 0; j < uniqueEventsArray.count; j++ {
//                            if uniqueEventsArray[j].eventIdentifier == currentEvent.eventIdentifier {
//                                eventExists = true
//                            }
//                        }
//                    }
//                    if !eventExists  {
                        uniqueEventsArray.append(currentEvent)
//                    }
                }
            }
        }
        
        
        
        var component = DateComponents()
        var aujDefault:EKEvent
        var laDate:Date
        for i in (-7...7) {
            aujDefault = EKEvent(eventStore: eventStore)
            aujDefault.title = "Ceci est une erreur"
            component.day = i
            laDate = (Calendar.current as NSCalendar).date(byAdding: component, to: date, options: NSCalendar.Options.matchStrictly)!
            aujDefault.startDate = laDate
            aujDefault.endDate = laDate
            uniqueEventsArray.append(aujDefault)
        }
        uniqueEventsArray = uniqueEventsArray.sorted{ $0.compareStartDate(with: $1) == .orderedAscending }
        EventManager.allEvents = uniqueEventsArray
        return uniqueEventsArray
    }
    func sortEventsByDay(_ uniqueEventsArray: [EKEvent]) -> NSArray {
        var section:NSDictionary
        var vretour:[NSDictionary] = []
        var lesDates:[EKEvent] = []
        var currentDate : Date = Date()
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .short
        for k in uniqueEventsArray{
            if dateFormat.string(from: currentDate) == dateFormat.string(from: k.startDate){
                lesDates.append(k)
            }else {
                section = ["date" : currentDate, "lesDates" : lesDates]
                vretour.append(section)
                currentDate = k.startDate
                lesDates = []
                lesDates.append(k)
            }
            
        }
        return vretour as NSArray
    }

    func insertEvent(_ title:String, startDate:Date, endDate:Date, notes:String, reminder:Bool ) -> Bool {
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
                    try eventStore.save(event, span: EKSpan.thisEvent, commit: true)
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
    func editEvent(_ title:String, startDate:Date, endDate:Date, notes:String, reminder:Bool, initialDate:Date?) -> Bool {
        var vretour = false
        if editEvent != nil {
            let mabite = editEvent!.eventIdentifier.characters.split{$0 == ":"}.map(String.init)
            for calendar in calendars! {
                // 2
                if calendar.title == selectedCalendarIdentifier {
//                    let store = EKEventStore()
                    self.editEvent = eventStore.event(withIdentifier: editEvent!.eventIdentifier)
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
                        if ressources != nil || self.version == "2"{
                            try eventStore.save(editEvent!, span: EKSpan.thisEvent, commit: true)
                            internalEvent.updateCalDavEvent(mabite[1], initialDate: initialDate)
                        } else {
                            try eventStore.save(editEvent!, span: EKSpan.thisEvent, commit: true)
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
            self.editEvent = eventStore.event(withIdentifier: editEvent!.eventIdentifier)
            do{
                vretour = true
                if(editEvent != nil) {try eventStore.remove(editEvent!, span: EKSpan.thisEvent, commit: true)}
                
            } catch {
                vretour = false
                print("An error occured \(error)")
            }
            
        }
        internalEvent.deleteEvent()
        return vretour
    }
    func createReminder(_ reminderTitle: String, dateReminder: Date) -> Bool{
        var vretour = true
        let calendarDatabase = EKEventStore()
        let timeInterval = dateReminder.addingTimeInterval(-60*60)
        calendarDatabase.requestAccess(to: EKEntityType.reminder, completion: {_,_ in })
        
        let reminder = EKReminder(eventStore: calendarDatabase)
        
        reminder.title = reminderTitle
        
        let alarm = EKAlarm(absoluteDate: timeInterval)
        
        reminder.addAlarm(alarm)
        
        reminder.calendar = calendarDatabase.defaultCalendarForNewReminders()
        
        do{
            try calendarDatabase.save(reminder, commit: true)
        } catch {
            vretour = false
            print("An error occured ")
        }
        return vretour
    }
    func addNewEventToArray(_ date:Date) -> NSArray{
        var component = DateComponents()
//        self.eventStore = EKEventStore()
        let nouvelEvt = EKEvent(eventStore: eventStore)
        var endDate:Date
        nouvelEvt.title = "Nouveau rendez-vous"
        component.minute = 15
        endDate = (Calendar.current as NSCalendar).date(byAdding: component, to: date, options: NSCalendar.Options.matchStrictly)!
        nouvelEvt.startDate = date
        nouvelEvt.endDate = endDate
        nouvelEvt.calendar = defaultCalendar!
        do{
            _ = try eventStore.save(nouvelEvt, span: EKSpan.thisEvent, commit: true)
            self.internalEvent.event = nouvelEvt
            self.internalEvent.insertEvent()
            EventManager.allEvents?.append(nouvelEvt)
            EventManager.allEvents! = EventManager.allEvents!.sorted{ $0.compareStartDate(with: $1) == .orderedAscending }
        } catch {
            
            print("An error occured \(error)")
        }
        
        return self.sortEventsByDay(EventManager.allEvents!)
    }
    func setDefautCalendar(_ dCal:EKCalendar){
        api.addPref("calendrierpardefaut\(preference.idUser)", prefs: [dCal.title])
        self.defaultCalendar = dCal
        api.readPreference()
    }
    func didReceiveAPIResults(_ results: NSDictionary) {
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
    func handleError(_ results: Int) {
//        api.getCalDavRessources()
        
    }
}
