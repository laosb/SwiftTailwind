# SwiftTailwind

Use Tailwind CSS in your Swift projects, seemlessly integrated as a Build Tool Plugin.

## Usage

Add this package to your Swift project as a dependency using the Swift Package Manager.

```swift
dependencies: [
  .package(url: "https://github.com/laosb/SwiftTailwind.git", from: "1.0.0+tw.4.1.12"),
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

It is built using [`Scripts/buildArtifactBundle.sh`](Scripts/buildArtifactBundle.sh), which pulls the specified version of Tailwind CSS CLI from their GitHub Releases and packages it into a Swift Package compatible format. It is then manually uploaded to this repository's GitHub Releases.

Any contributions to automate the artifact generation are welcome!

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
