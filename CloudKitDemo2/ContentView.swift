import CloudKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
        .onAppear(perform: crud)
    }

    private func createRecords(_ ck: CloudKit) async throws {
        let tami = Person(firstName: "Tamara", lastName: "Volkmann")
        try await ck.create(item: tami)

        let amanda = Person(firstName: "Amanda", lastName: "Nelson")
        try await ck.create(item: amanda)

        let jeremy = Person(firstName: "Jeremy", lastName: "Volkmann")
        try await ck.create(item: jeremy)

        let ref = CKRecord.Reference(
            recordID: tami.record.recordID,
            action: .deleteSelf
        )
        let comet = Pet(name: "Comet", ownedBy: ref)
        try await ck.create(item: comet)
    }

    private func crud() {
        Task {
            do {
                let containerID =
                    "iCloud.r.mark.volkmann.gmail.com.CloudKitDemo2"
                let ck = CloudKit(containerID: containerID)

                // try await ck.deleteAll(recordType: "Pets")
                // try await ck.deleteAll(recordType: "People")

                try await ck.recreateZone()
                try await createRecords(ck)

                // NOTE: There can be a long delay (maybe a minute) until
                // NOTE: the new records appear in a CloudKit Console query!

                print(
                    "In CloudKit Console, query records in private database and zone my-zone"
                )

                // When new records are created or records are updated, it
                // can take up to a minute for CloudKit to index the changes.
                // The new/modified records are not returned by
                // subsequent queries until indexing is completed.
                // try await retrieveRecords(ck)
            } catch {
                print("error:", error)
            }
        }
    }

    private func retrieveRecords(_ ck: CloudKit) async throws {
        // TODO: Why can't we immediately retrieve records
        // TODO: we just created?  It seems we have to wait
        // TODO: for up to one minute to get them.
        let people = try await ck.retrieve(
            recordType: "People"
        ) as [Person]
        for person in people {
            print("person =", person.firstName, person.lastName)
        }

        let pets = try await ck.retrieve(
            recordType: "Pets"
        ) as [Pet]
        for pet in pets {
            print("pet =", pet.name)
        }

        // To delete a record ...
        // try await ck.delete(item: people[0])

        // To update a record ...
        // let item = pets[0]
        // item.name = "Fireball"
        // try await ck.update(item: item)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
