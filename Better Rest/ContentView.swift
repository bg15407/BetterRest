//
//  ContentView.swift
//  Better Rest
//
//  Created by Gayan Kalinga on 5/15/21.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var hoursToSleep = 7.0
    @State private var cupsOfCoffee = 3
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showBedTime = false
    
    static var defaultWakeTime: Date{
        var component = DateComponents()
        component.hour = 8
        component.minute = 0
        
        return Calendar.current.date(from: component) ?? Date()
    }
    
    var body: some View {
        NavigationView{
            Form{
                Section{
                    DatePicker("When do you wake up ?",
                               selection: $wakeUp,
                               displayedComponents: .hourAndMinute
                    )
                    //.labelsHidden()
                }
                
                VStack(alignment: .leading){
                    Text("How many hours of Sleep")
                        .font(.headline)
                    
                    Stepper(value: $hoursToSleep,
                            in: 4...12,
                            step: 0.25){
                        Text("\(hoursToSleep, specifier: "%g") \(hoursToSleep == 1 ? "hour" : "hours")")
                    }
                }
                
                Section(header: Text("How many cups of coffee")){
                    Stepper(value: $cupsOfCoffee, in: 1...20){
                        Text("\(cupsOfCoffee) \(cupsOfCoffee == 1 ? "cup" : "cups")")
                    }
                }
                
                VStack(alignment: .leading){
                    Text("Bedtime \(actualBedTime)")
                }
            
            }
            .alert(isPresented: $showBedTime){
                Alert(title: Text(alertTitle),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("Ok")))
            }
            .navigationBarTitle("Better Rest")
//            .navigationBarItems(trailing:
//                Button(action: calculateBedTime){
//                    Text("Calculate")
//                }
//            )
        }
    }
    
    var actualBedTime: String{
        //let model = SleepTime_1() -> Deprecated
        
        let component = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hours = (component.hour ?? 0) * 60 * 60
        let minutes = (component.minute ?? 0) * 60
        
        let wakeTime = Double(hours + minutes)
        
        do{
            
            let model: SleepTime_1 = try SleepTime_1(
                    configuration: MLModelConfiguration())
            
            let prediction = try model.prediction(wake: wakeTime, estimatedSleep: hoursToSleep, coffee: Double(cupsOfCoffee))
            
            let timeToSleep = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            return formatter.string(from: timeToSleep)
            
        }catch{
            alertTitle = "Calculation Error"
            alertMessage = "Something went wrong"
        }
        
        return "error"
        //showBedTime = true
    }
    
//    func calculateBedTime(){
//        //let model = SleepTime_1() -> Deprecated
//
//        let component = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
//        let hours = (component.hour ?? 0) * 60 * 60
//        let minutes = (component.minute ?? 0) * 60
//
//        let wakeTime = Double(hours + minutes)
//
//        do{
//
//            let model: SleepTime_1 = try SleepTime_1(
//                    configuration: MLModelConfiguration())
//
//            let prediction = try model.prediction(wake: wakeTime, estimatedSleep: hoursToSleep, coffee: Double(cupsOfCoffee))
//
//            let timeToSleep = wakeUp - prediction.actualSleep
//
//            let formatter = DateFormatter()
//            formatter.timeStyle = .short
//
//            alertTitle = "Ideal Bed Time is"
//            alertMessage = formatter.string(from: timeToSleep)
//
//        }catch{
//            alertTitle = "Calculation Error"
//            alertMessage = "Something went wrong"
//        }
//
//        showBedTime = true
//    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
