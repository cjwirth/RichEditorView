//swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "RichEditorView",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "RichEditorView",
            targets: ["RichEditorView"]
        )
    ],
    targets: [
        .target(
            name: "RichEditorView_Objc",
            path: "RichEditorView",
            exclude: [
                "Classes/RichEditorOptionItem.swift",
                "Classes/RichEditorToolbar.swift",
                "Classes/RichEditorView.swift",
                "Classes/String+Extensions.swift",
                "Classes/UIColor+Extensions.swift",
                "Classes/UIView+Responder.swift",
                "Assets",
                "Info.plist"
            ],
            sources: ["Classes"],
            publicHeadersPath: "Classes"
        ),
        .target(
            name: "RichEditorView",
            dependencies: ["RichEditorView_Objc"],
            path: "RichEditorView",
            exclude: [
                "Classes/CJWWebView+HackishAccessoryHiding.h",
                "Classes/CJWWebView+HackishAccessoryHiding.m",
                "Info.plist"
            ],
            sources: ["Classes"],
            resources: [
                .process("Assets/icons/"),
                .process("Assets/editor/")
            ]
        )
    ]
)
