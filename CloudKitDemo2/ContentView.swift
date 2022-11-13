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

    private func crud() {
        Task {
            do {
                let containerID =
                    "iCloud.r.mark.volkmann.gmail.com.CloudKitDemo2"
                let ck = CloudKit(containerID: containerID)

                // try await ck.deleteAll(recordType: "Pets")
                // try await ck.deleteAll(recordType: "People")
                /*
                 try await ck.deleteZone(zoneID: CloudKit.zone.zoneID)
                 try await ck.createZone(zoneID: CloudKit.zone.zoneID)

                 // NOTE: There can be a long delay (maybe a minute) until
                 // NOTE: the new records appear in a CloudKit Console query!
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

                 print("query records in private database in zone my-zone")
                 */

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
            } catch {
                print("error:", error)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
