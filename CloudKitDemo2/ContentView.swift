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
                try await ck.deleteZone(zoneID: CloudKit.zoneID)
                try await ck.createZone(zoneID: CloudKit.zoneID)

                try await ck.create(
                    recordType: "People",
                    recordClass: Person.self,
                    keys: [
                        "firstName": "Tamara",
                        "lastName": "Volkmann"
                    ]
                )
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
