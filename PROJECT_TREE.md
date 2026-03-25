safespender/
├─ pubspec.yaml
├─ pubspec.lock
├─ .gitignore
├─ .metadata
├─ analysis_options.yaml
├─ .vscode/
│  └─ settings.json
├─ README.md
├─ test/
│  └─ widget_test.dart
├─ lib/
│  ├─ main.dart
│  ├─ app/
│  │  ├─ app.dart
│  │  ├─ router.dart
│  │  └─ theme/
│  │     ├─ app_colors.dart
│  │     ├─ app_text_styles.dart
│  │     └─ app_theme.dart
│  ├─ core/
│  │  └─ network/
│  │     └─ dio_provider.dart
│  └─ features/
│     ├─ home/
│     │  ├─ presentation/
│     │  │  └─ home_screen.dart
│     │  ├─ data/
│     │  └─ domain/
│     ├─ grocery/
│     │  ├─ presentation/
│     │  │  └─ grocery_overview_screen.dart
│     │  ├─ data/
│     │  └─ domain/
│     ├─ expenses/
│     │  ├─ presentation/
│     │  │  └─ add_expense_screen.dart
│     │  ├─ data/
│     │  └─ domain/
│     ├─ purchase_check/
│     │  ├─ presentation/
│     │  │  └─ purchase_check_screen.dart
│     │  ├─ data/
│     │  └─ domain/
│     ├─ settings/
│     │  └─ presentation/
│     │     └─ settings_screen.dart
│     └─ setup/
│        └─ presentation/
│           └─ setup_screen.dart
├─ web/
│  ├─ index.html
│  ├─ manifest.json
│  ├─ favicon.png
│  └─ icons/
│     ├─ Icon-192.png
│     ├─ Icon-512.png
│     ├─ Icon-maskable-192.png
│     └─ Icon-maskable-512.png
├─ android/
│  ├─ build.gradle.kts
│  ├─ gradle/
│  │  └─ wrapper/gradle-wrapper.properties
│  ├─ settings.gradle.kts
│  ├─ gradle.properties
│  └─ app/
│     ├─ build.gradle.kts
│     └─ src/
│        └─ main/
│           ├─ AndroidManifest.xml
│           ├─ kotlin/com/example/safespender/MainActivity.kt
│           └─ res/
│              ├─ drawable/launch_background.xml
│              ├─ mipmap-*/ic_launcher.png
│              └─ values/styles.xml
├─ ios/
│  ├─ Runner.xcodeproj/
│  ├─ Runner.xcworkspace/
│  ├─ Flutter/
│  │  ├─ Debug.xcconfig
│  │  ├─ Release.xcconfig
│  │  └─ AppFrameworkInfo.plist
│  └─ Runner/
│     ├─ AppDelegate.swift
│     ├─ Info.plist
│     └─ Assets.xcassets/
├─ macos/
│  ├─ Flutter/
│  │  └─ GeneratedPluginRegistrant.swift
│  └─ Runner/
│     ├─ MainFlutterWindow.swift
│     └─ AppDelegate.swift
├─ linux/
│  ├─ CMakeLists.txt
│  └─ runner/
│     ├─ main.cc
│     └─ my_application.cc/.h
├─ windows/
│  ├─ CMakeLists.txt
│  └─ runner/
│     ├─ main.cpp
│     ├─ flutter_window.cpp/.h
│     └─ win32_window.cpp/.h
└─ other IDE / generated files
   ├─ macOS/iOS workspace files
   └─ platform-generated plugin registrant files
