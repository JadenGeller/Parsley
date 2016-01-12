
import PackageDescription

let package = Package(
    name: "Parsley",
    dependencies: [
        .Package(url: "https://github.com/JadenGeller/Spork.git", majorVersion: 1)
    ]
)
