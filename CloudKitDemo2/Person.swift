import CloudKit

final class Person: CloudKitable, Hashable, Identifiable {
    init(firstName: String, lastName: String) {
        record = CloudKit.createRecord(recordType: "People")
        record["firstName"] = firstName
        record["lastName"] = lastName
    }

    init(record: CKRecord) {
        // TODO: Maybe this can be assumed to be set already.
        // record.recordType = "People"
        self.record = record
    }

    var id: String { record.recordID.recordName }

    var record: CKRecord

    var firstName: String {
        get { record["firstName"] as? String ?? "" }
        set { record["firstName"] = newValue }
    }

    var lastName: String {
        get { record["lastName"] as? String ?? "" }
        set { record["lastName"] = newValue }
    }

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
