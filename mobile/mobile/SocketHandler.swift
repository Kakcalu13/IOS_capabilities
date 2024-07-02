//import Foundation
//import SocketIO
//
//class SocketHandler: NSObject {
//    static let sharedInstance = SocketHandler()
//    let socket = SocketManager(socketURL: URL(string: "http://192.168.50.97:9055")!, config: [.log(true), .compress])
//    var mSocket: SocketIOClient!
//
//    override init() {
//        super.init()
//        mSocket = socket.defaultSocket
//    }
//
//    func getSocket() -> SocketIOClient {
//        return mSocket
//    }
//
//    func establishConnection() {
//        mSocket.connect()
//    }
//
//    func closeConnection() {
//        mSocket.disconnect()
//    }
//}
