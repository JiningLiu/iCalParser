import XCTest
@testable import iCalParser

final class iCalParserTests: XCTestCase {
    func testExample() async throws {
        
        guard let parsed = await iCalCalendar(icsFileURL: URL(string: "https://gist.githubusercontent.com/DeMarko/6142417/raw/1cd301a5917141524b712f92c2e955e86a1add19/sample.ics")!) else {
            fatalError()
        }
        
        
        print("\n================================\n\nData as String:\n" + String(describing: parsed) + "\n\n================================\n")
        
    }
}
