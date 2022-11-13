import CloudKit

final class Pet: CloudKitable, Hashable, Identifiable {
    init(name: String, ownedBy: CKRecord.Reference) {
        record = CKRecord(
            recordType: "Pets",
            recordID: CKRecord.ID(zoneID: CloudKit.zone.zoneID)
        )
        record["name"] = name
        record["ownedBy"] = ownedBy
    }

    init(record: CKRecord) {
        self.record = record
    }

    var id: String { record.recordID.recordName }

    var record: CKRecord

    var name: String {
        get { record["name"] as? String ?? "" }
        set { record["name"] = newValue }
    }

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
