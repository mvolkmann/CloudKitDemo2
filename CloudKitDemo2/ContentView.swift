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
        print("performing CRUD operations")

        Task {
            do {
                let containerID =
                    "iCloud.r.mark.volkmann.gmail.com.CloudKitDemo2"
                let ck = CloudKit(containerID: containerID)
                // try await ck.deleteAll(recordType: "Pets")
                // try await ck.deleteAll(recordType: "People")
                try await ck.deleteZone(zoneID: CloudKit.zone.zoneID)
                try await ck.createZone(zoneID: CloudKit.zone.zoneID)

                // There can be a long delay (maybe a minute) until
                // the new records appear in a CloudKit Console query!
                let person = Person(firstName: "Tamara", lastName: "Volkmann")
                try await ck.create(item: person)

                let p2 = Person(firstName: "Amanda", lastName: "Nelson")
                try await ck.create(item: p2)

                let p3 = Person(firstName: "Jeremy", lastName: "Volkmann")
                try await ck.create(item: p3)
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
