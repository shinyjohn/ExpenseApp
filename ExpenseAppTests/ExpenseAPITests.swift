import XCTest
@testable import ExpenseApp

final class ExpenseAPITests: XCTestCase {
    override func tearDown() {
        StubURLProtocol.statusCode = 200
        StubURLProtocol.responseData = Data()
        StubURLProtocol.responseError = nil
        super.tearDown()
    }

    @MainActor
    func testFetchExpensesDecodesSuccessfulResponse() async throws {
        StubURLProtocol.statusCode = 200
        StubURLProtocol.responseData = Data("""
        [{"userId":1,"id":5,"title":"coffee","body":"morning"}]
        """.utf8)
        let api = makeAPI()

        let expenses = try await api.fetchExpenses()

        XCTAssertEqual(expenses.count, 1)
        XCTAssertEqual(expenses.first?.id, 5)
        XCTAssertEqual(expenses.first?.title, "coffee")
        XCTAssertEqual(expenses.first?.body, "morning")
    }

    func testFetchExpensesThrowsForNonSuccessStatus() async {
        StubURLProtocol.statusCode = 503
        StubURLProtocol.responseData = Data("{}".utf8)
        let api = makeAPI()

        do {
            _ = try await api.fetchExpenses()
            XCTFail("Expected invalid response error")
        } catch {
            XCTAssertEqual(error as? APIError, .invalidResponse)
        }
    }

    func testFetchExpensesThrowsForInvalidJSON() async {
        StubURLProtocol.statusCode = 200
        StubURLProtocol.responseData = Data("not-json".utf8)
        let api = makeAPI()

        do {
            _ = try await api.fetchExpenses()
            XCTFail("Expected decoding error")
        } catch is DecodingError {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchExpensesPropagatesTransportError() async {
        StubURLProtocol.responseError = URLError(.notConnectedToInternet)

        let api = makeAPI()

        do {
            _ = try await api.fetchExpenses()
            XCTFail("Expected transport error")
        } catch {
            let nsError = error as NSError

            XCTAssertEqual(nsError.domain, NSURLErrorDomain)
            XCTAssertEqual(
                nsError.code,
                URLError.Code.notConnectedToInternet.rawValue
            )
        }
    }
    
    func testAPIErrorHasHelpfulDescription() {
        XCTAssertEqual(
            APIError.invalidResponse.errorDescription,
            "The server returned an unexpected response. Please try again."
        )
    }

    private func makeAPI() -> ExpenseAPI {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        let session = URLSession(configuration: configuration)
        return ExpenseAPI(baseURL: URL(string: "https://example.test")!, session: session)
    }
}

private final class StubURLProtocol: URLProtocol {
    static var statusCode = 200
    static var responseData = Data()
    static var responseError: Error?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        if let responseError = Self.responseError {
            client?.urlProtocol(self, didFailWithError: responseError)
            return
        }

        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: Self.statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!

        client?.urlProtocol(
            self,
            didReceive: response,
            cacheStoragePolicy: .notAllowed
        )

        client?.urlProtocol(self, didLoad: Self.responseData)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
