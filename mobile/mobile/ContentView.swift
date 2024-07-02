import SwiftUI
import CoreMotion
import Network

struct ContentView: View {
    // State variables for gyro, acceleration, barometer, magnetometer, and device motion data
    @State private var gyroX: Double = 0.0
    @State private var gyroY: Double = 0.0
    @State private var gyroZ: Double = 0.0
    
    @State private var accelX: Double = 0.0
    @State private var accelY: Double = 0.0
    @State private var accelZ: Double = 0.0
    
    @State private var altitude: Double = 0.0
    @State private var pressure: Double = 0.0
    
    @State private var magneticX: Double = 0.0
    @State private var magneticY: Double = 0.0
    @State private var magneticZ: Double = 0.0

    @State private var attitudeRoll: Double = 0.0
    @State private var attitudePitch: Double = 0.0
    @State private var attitudeYaw: Double = 0.0
    
    @State private var gravityX: Double = 0.0
    @State private var gravityY: Double = 0.0
    @State private var gravityZ: Double = 0.0
    
    @State var connection: NWConnection?
    
    var host: NWEndpoint.Host = "192.168.50.97"
    var port: NWEndpoint.Port = 1234
    

    @State private var sensorDataJSON: String = ""
    
    // Motion manager to get sensor data
    let motionManager = CMMotionManager()
    let altimeter = CMAltimeter()
    
    var body: some View {
        VStack {
//            Spacer()
//            Button(action: {
//                NSLog("Connect pressed")
//                connect()
//            }) {
//                Text("Connect")
//            }
            Spacer()
            Button(action: {
                NSLog("Send pressed")
                send("hello".data(using: .utf8)!)
            }) {
                Text("Send")
            }
            Spacer()
        }.padding()
        .onAppear {
            startGyroUpdates()
            startAccelUpdates()
            startBarometerUpdates()
            startMagnetometerUpdates()
            startDeviceMotionUpdates()
            connect()
        }
    }

    
    func startGyroUpdates() {
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 0.1
            motionManager.startGyroUpdates(to: .main) { data, error in
                guard let data = data else { return }
                gyroX = data.rotationRate.x
                gyroY = data.rotationRate.y
                gyroZ = data.rotationRate.z
            }
        }
    }
    
    func startAccelUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: .main) { data, error in
                guard let data = data else { return }
                accelX = data.acceleration.x
                accelY = data.acceleration.y
                accelZ = data.acceleration.z
            }
        }
    }
    
    func startBarometerUpdates() {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: .main) { data, error in
                guard let data = data else { return }
                altitude = data.relativeAltitude.doubleValue
                pressure = data.pressure.doubleValue
            }
        }
    }
    
    func startMagnetometerUpdates() {
        if motionManager.isMagnetometerAvailable {
            motionManager.magnetometerUpdateInterval = 0.1
            motionManager.startMagnetometerUpdates(to: .main) { data, error in
                guard let data = data else { return }
                magneticX = data.magneticField.x
                magneticY = data.magneticField.y
                magneticZ = data.magneticField.z
            }
        }
    }
    
    func startDeviceMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.05
            motionManager.startDeviceMotionUpdates(to: .main) { data, error in
                guard let data = data else { return }
                attitudeRoll = data.attitude.roll
                attitudePitch = data.attitude.pitch
                attitudeYaw = data.attitude.yaw
                gravityX = data.gravity.x
                gravityY = data.gravity.y
                gravityZ = data.gravity.z
                updateSensorDataJSON()
            }
        }
    }
    
    func send(_ payload: Data) {
        connection!.send(content: payload, completion: .contentProcessed({ sendError in
            if let error = sendError {
                NSLog("Unable to process and send the data: \(error)")
            } else {
                connection!.receiveMessage { (data, context, isComplete, error) in
                    guard let myData = data else { return }
                    NSLog("Received message: " + String(decoding: myData, as: UTF8.self))
                }
            }
        }))
    }
    
    func connect() {
        connection = NWConnection(host: host, port: port, using: .udp)
        
        connection!.stateUpdateHandler = { (newState) in
            switch (newState) {
            case .preparing:
                NSLog("Entered state: preparing")
            case .ready:
                NSLog("Entered state: ready")
            case .setup:
                NSLog("Entered state: setup")
            case .cancelled:
                NSLog("Entered state: cancelled")
            case .waiting:
                NSLog("Entered state: waiting")
            case .failed:
                NSLog("Entered state: failed")
            default:
                NSLog("Entered an unknown state")
            }
        }
        
        connection!.viabilityUpdateHandler = { (isViable) in
            if (isViable) {
                NSLog("Connection is viable")
            } else {
                NSLog("Connection is not viable")
            }
        }
        
        connection!.betterPathUpdateHandler = { (betterPathAvailable) in
            if (betterPathAvailable) {
                NSLog("A better path is availble")
            } else {
                NSLog("No better path is available")
            }
        }
        
        connection!.start(queue: .global())
    }
    
    func updateSensorDataJSON() {
        let sensorData: [String: Any] = [
            "gyro": ["0": gyroX, "1": gyroY, "2": gyroZ],
            "accelerometer": ["0": accelX, "1": accelY, "2": accelZ],
            "altitude": altitude,
            "pressure": pressure,
            "magnetometer": ["0": magneticX, "1": magneticY, "2": magneticZ],
            "attitude": ["0": attitudeRoll, "1": attitudePitch, "2": attitudeYaw], //ROLL, PITCH, YAW
            "gravity": ["0": gravityX, "1": gravityY, "2": gravityZ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: sensorData, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            sensorDataJSON = jsonString
            // Here you can handle the JSON string, e.g., send it to a server or log it
            send(jsonData)  // Send jsonData directly
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
