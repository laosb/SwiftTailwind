# SwiftTailwind

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Flaosb%2FSwiftTailwind%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/laosb/SwiftTailwind)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Flaosb%2FSwiftTailwind%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/laosb/SwiftTailwind)

Use Tailwind CSS in your Swift projects, seemlessly integrated as a Build Tool Plugin.

## Usage

Add this package to your Swift project as a dependency using the Swift Package Manager.

```swift
dependencies: [
  .package(url: "https://github.com/laosb/SwiftTailwind.git", from: "1.1.1+tw.4.1.18"),
],
```

Then, in your `Package.swift` file, add the plugin to your target:

```swift
targets: [
  .target(
    name: "YourTargetName",
    plugins: [
      .plugin(name: "TailwindCSS", package: "SwiftTailwind")
    ]
  )
]
```

Place your Tailwind CSS entrypoint file at `Tailwind.css` in your target. To integrate seamlessly with Swift Package Manager build process, SwiftTailwind requires defining your source files explicitly, and does not support `@source not` to exclude files. Instead, you can use `@source` to include specific files or directories.

```css
@import "tailwindcss" source(none);
/* Note that as of writing, Tailwind doesn't scan .swift files by default, so you need to specify a glob pattern including the extension. */
@source "./Views/**/*.swift";
@source "./Template.swift";
@source "./Static";
```

The plugin will automatically process your Tailwind CSS files during the build process, generating the necessary CSS output. The output will be named as `tw.css` and will be placed in the `TailwindCSS.bundle` directory within your target. You won't see it in your source tree, but it will be available to your build product as `Bundle.module.url(forResource: "TailwindCSS", withExtension: "bundle")`.

```swift
import Foundation

let cssFileURL = Bundle.module
  .url(forResource: "TailwindCSS", withExtension: "bundle")!
  .appending(component: "tw.css")
```

## About the binary blob

A binary artifact bundle will be downloaded from this repo's GitHub Releases. It contains the standalone version of Tailwind CSS CLI, which is used to process your Tailwind CSS files. This allows you to use Tailwind CSS without needing to install Node.js or npm in your Swift project.

It is built using a custom Swift CLI at [`Sources/TailwindCSSCLIArtifactBundler`](Sources/TailwindCSSCLIArtifactBundler), which pulls the specified version of Tailwind CSS CLI from their GitHub Releases and packages it into a Swift Package compatible format. When a new Tailwind CSS version is release upstream, a GitHub Actions [workflow](.github/workflows/release-tailwindcss-cli.yml) is usually triggered manually with the new version number to create a new Tailwind CSS CLI release in this repo. After that, the [`Package.swift`](Package.swift) file should be updated to point to the new CLI version, and a new SwiftTailwind release should be created.

Any contributions to automate the artifact generation are welcome!

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
