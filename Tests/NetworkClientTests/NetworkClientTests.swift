import XCTest
import Combine
@testable import NetworkClient

final class NetworkClientTests: XCTestCase {
    func test_syntax() {
        let client = CombineNetworkingClient()
        
        _ = client.performRequest(url: URL(string: "google.com")!, requestType: .get())
        _ = client.performRequest(url: URL(string: "google.com")!, requestType: .get(parameters: ["test": "test"]))
        _ = client.performRequest(url: URL(string: "google.com")!, requestType: .post())
        _ = client.performRequest(url: URL(string: "google.com")!, requestType: .post(parameters: ["test": 1]))
        _ = client.performRequest(url: URL(string: "google.com")!, requestType: .delete())
        _ = client.performRequest(url: URL(string: "google.com")!, requestType: .delete(parameters: ["test": 3]))
        _ = client.performRequest(url: URL(string: "google.com")!, requestType: .put())
        _ = client.performRequest(url: URL(string: "google.com")!, requestType: .put(parameters: ["test": 1.0]))
        _ = client.performRequest(url: URL(string: "google.com")!, requestType: .postBody(data: PostBodyData(fileData: Data(), fileName: "name", fieldName: "field", mimeType: "data")))
    }

    static var allTests = [
        ("test_syntax", test_syntax),
    ]
}
