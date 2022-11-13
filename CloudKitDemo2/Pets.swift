import CloudKit

final class Pet: CloudKitable, Hashable, Identifiable {
    init(record: CKRecord) {
        self.record = record
    }

    var id: String { record.recordID.recordName }

    var record: CKRecord

    var name: String { record["name"] as? String ?? "" }

    // The Hashable protocol conforms to the Equatable protocol.
    // This is required by the Equatable protocol.
    static func == (lhs: Pet, rhs: Pet) -> Bool {
        lhs.record == rhs.record
    }

    // When present, this is used by the Hashable protocol.
    func hash(into hasher: inout Hasher) {
        hasher.combine(record)
    }
}
