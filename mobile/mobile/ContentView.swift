import SwiftUI
import CoreMotion

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

    @State private var sensorDataJSON: String = ""
    
    // Motion manager to get sensor data
    let motionManager = CMMotionManager()
    let altimeter = CMAltimeter()
    let webSocketManager = WebSocketManager()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Reading your phone's capabilities")
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.black)
        }
        .onAppear {
            startGyroUpdates()
            startAccelUpdates()
            startBarometerUpdates()
            startMagnetometerUpdates()
            startDeviceMotionUpdates()
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
                updateSensorDataJSON()
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
                updateSensorDataJSON()
            }
        }
    }
    
    func startBarometerUpdates() {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: .main) { data, error in
                guard let data = data else { return }
                altitude = data.relativeAltitude.doubleValue
                pressure = data.pressure.doubleValue
                updateSensorDataJSON()
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
                updateSensorDataJSON()
            }
        }
    }
    
    func startDeviceMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
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
    
    func updateSensorDataJSON() {
        let sensorData: [String: Any] = [
            "gyro": ["x": gyroX, "y": gyroY, "z": gyroZ],
            "accelerometer": ["x": accelX, "y": accelY, "z": accelZ],
            "altitude": altitude,
            "pressure": pressure,
            "magnetometer": ["x": magneticX, "y": magneticY, "z": magneticZ],
            "attitude": ["roll": attitudeRoll, "pitch": attitudePitch, "yaw": attitudeYaw],
            "gravity": ["x": gravityX, "y": gravityY, "z": gravityZ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: sensorData, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            sensorDataJSON = jsonString
            webSocketManager.send(data: jsonString)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
