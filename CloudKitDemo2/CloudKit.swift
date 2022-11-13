import CloudKit
import CoreData
import UIKit

protocol CloudKitable {
    // This must be an optional initializer
    // due to this line in the retrieve method:
    // guard let item = T(record: record) else { return }
    init?(record: CKRecord)

    var record: CKRecord { get }
}

struct CloudKit {
    typealias Cursor = CKQueryOperation.Cursor

    // Using a custom zone enables performing batch operations
    // such as deleting all the records of every record type.
    // See the deleteZone method below.
    static var zone = CKRecordZone(zoneName: "my-zone")

    // MARK: - Initializer

    init(containerID: String, usePublic: Bool = false) {
        // TODO: This doesn't result in pointing to the correct container.  Why?
        // container = CKContainer.default()

        // I discovered the container identifier by looking in CloudKitDemo.entitlements.
        // "CloudKit Console" button in "Signing & Capabilities"
        // under "Ubiquity Container Identifiers".
        // TODO: Why did it use this identifier instead of the one
        // TODO: specified in Signing & Capabilities ... Containers?

        container = CKContainer(identifier: containerID)

        database = usePublic ?
            container.publicCloudDatabase :
            container.privateCloudDatabase
    }

    // MARK: - Properties

    var container: CKContainer!
    var database: CKDatabase!

    // MARK: - Non-CRUD Methods

    private func createOperation(
        recordType: CKRecord.RecordType,
        predicate: NSPredicate,
        sortDescriptors: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil
    ) -> CKQueryOperation {
        let query = CKQuery(recordType: recordType, predicate: predicate)
        query.sortDescriptors = sortDescriptors
        let operation = CKQueryOperation(query: query)
        if let limit = resultsLimit { operation.resultsLimit = limit }
        return operation
    }

    func statusText() async throws -> String {
        switch try await container.accountStatus() {
        case .available:
            return "available"
        case .couldNotDetermine:
            return "could not determine"
        case .noAccount:
            return "no account"
        case .restricted:
            return "restricted"
        case .temporarilyUnavailable:
            return "temporarily unavailable"
        default:
            return "unknown"
        }
    }

    // See https://nemecek.be/blog/31/how-to-setup-cloudkit-subscription-to-get-notified-for-changes.
    // This requires adding the "Background Modes" capability
    // and checking "Remote notifications".
    // Supposedly subscriptions do not work in the Simulator.
    func subscribe(recordType: CKRecord.RecordType) async throws {
        let subscription = CKQuerySubscription(
            recordType: recordType,
            predicate: NSPredicate(value: true), // all records
            options: [
                .firesOnRecordCreation,
                .firesOnRecordDeletion,
                .firesOnRecordUpdate
            ]
        )

        let info = CKSubscription.NotificationInfo()
        info.shouldSendContentAvailable = true
        info.alertBody = "" // if this isn't set, pushes aren't always sent
        subscription.notificationInfo = info
        try await database.save(subscription)
    }

    // MARK: - CRUD Methods

    // "C" in CRUD.

    func create<T: CloudKitable>(item: T) async throws {
        try await database.save(item.record)
    }

    static func createRecord(recordType: String) -> CKRecord {
        CKRecord(
            recordType: recordType,
            recordID: CKRecord.ID(zoneID: Self.zone.zoneID)
        )
    }

    func createZone() async throws {
        let zone = CKRecordZone(zoneID: Self.zone.zoneID)
        try await database.save(zone)
    }

    func recreateZone() async throws {
        try await deleteZone()
        try await createZone()
    }

    // "D" in CRUD.

    func delete<T: CloudKitable>(item: T) async throws {
        try await database.deleteRecord(withID: item.record.recordID)
    }

    func deleteAll(recordType: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            database.delete(withRecordZoneID: Self.zone.zoneID) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    func deleteZone() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            // In iOS 16, this method still requires a completion handler.
            database.delete(withRecordZoneID: Self.zone.zoneID) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    // "R" in CRUD.

    func retrieve<T: CloudKitable>(
        recordType: CKRecord.RecordType,
        predicate: NSPredicate = NSPredicate(value: true), // gets all
        sortDescriptors: [NSSortDescriptor]? = nil,
        resultsLimit: Int = CKQueryOperation.maximumResults
    ) async throws -> [T] {
        let query = CKQuery(recordType: recordType, predicate: predicate)
        query.sortDescriptors = sortDescriptors
        let (results, cursor) = try await database.records(
            matching: query,
            inZoneWith: Self.zone.zoneID,
            resultsLimit: resultsLimit
        )

        var objects: [T] = []

        for (_, result) in results {
            let record = try result.get()
            objects.append(T(record: record)!)
        }

        try await retrieveMore(cursor, &objects)

        return objects
    }

    // This uses a cursor to recursively retrieve all the requested records.
    private func retrieveMore<T: CloudKitable>(
        _ cursor: Cursor?, _ objects: inout [T]
    ) async throws {
        guard let cursor = cursor else { return }

        let (results, newCursor) =
            try await database.records(continuingMatchFrom: cursor)

        for (_, result) in results {
            let record = try result.get()
            objects.append(T(record: record)!)
        }

        // Recursive call.
        try await retrieveMore(newCursor, &objects)
    }

    // "U" in CRUD.

    func update<T: CloudKitable>(item: T) async throws {
        try await database.save(item.record)
    }
}
