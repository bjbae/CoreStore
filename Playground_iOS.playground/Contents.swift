import UIKit
import CoreStore

/// Model Declaration =====
class Animal: CoreStoreObject {
    let species = Value.Required<String>("species", initial: "Swift")
    let master = Relationship.ToOne<Person>("master")
    let color = Transformable.Optional<UIColor>("color", initial: .orange)
}

class Person: CoreStoreObject {
    let name = Value.Optional<String>("name")
    let pets = Relationship.ToManyUnordered<Animal>("pets", inverse: { $0.master })
}
/// =======================

/// Stack setup ===========
let dataStack = DataStack(
    CoreStoreSchema(
        modelVersion: "V1",
        entities: [
            Entity<Animal>("Animal"),
            Entity<Person>("Person")
        ]
    )
)
try dataStack.addStorageAndWait(SQLiteStore(fileName: "data.sqlite"))
/// =======================

/// Transactions ==========
dataStack.perform(synchronous: { transaction in

    let animal = transaction.create(Into<Animal>())
    animal.species .= "Sparrow"
    animal.color .= .yellow

    let person = transaction.create(Into<Person>())
    person.name .= "John"
    person.pets.value.insert(animal)
})
/// =======================

/// Accessing Objects =====
let bird = dataStack.fetchOne(From<Animal>().where(\.species == "Sparrow"))!
print(bird.species.value)
print(bird.color.value as Any)
print(bird)

let owner = bird.master.value!
print(owner.name.value)
print(owner.pets.count as Any)
print(owner)
/// =======================
