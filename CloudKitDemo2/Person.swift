import CloudKit

final class Person: CloudKitable, Hashable, Identifiable {
    init(record: CKRecord) {
        self.record = record
        // recordType = "People"
    }

    var id: String { record.recordID.recordName }

    var record: CKRecord

    var firstName: String { record["firstName"] as? String ?? "" }
    var lastName: String { record["lastName"] as? String ?? "" }

    // The Hashable protocol conforms to the Equatable protocol.
    // This is required by the Equatable protocol.
    static func == (lhs: Person, rhs: Person) -> Bool {
        lhs.record == rhs.record
    }

    // When present, this is used by the Hashable protocol.
    func hash(into hasher: inout Hasher) {
        hasher.combine(record)
    }
}
