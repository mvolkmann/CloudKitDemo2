import CloudKit

final class Pet: CloudKitable, Hashable, Identifiable {
    init(name: String, ownedBy: CKRecord.Reference) {
        record = CloudKit.createRecord(recordType: "Pets")
        record["name"] = name
        record["ownedBy"] = ownedBy
    }

    init(record: CKRecord) {
        self.record = record
    }

    var id: String { record.recordID.recordName }

    var name: String {
        get { record["name"] as? String ?? "" }
        set { record["name"] = newValue }
    }

    var record: CKRecord

    static func == (lhs: Pet, rhs: Pet) -> Bool {
        lhs.record == rhs.record
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(record)
    }
}
