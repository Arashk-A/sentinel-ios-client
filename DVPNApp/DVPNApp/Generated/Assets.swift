// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let accentColor = ColorAsset(name: "AccentColor")
  internal enum Colors {
    internal static let accentColor = ColorAsset(name: "colors/accentColor")
    internal static let borderGray = ColorAsset(name: "colors/borderGray")
    internal static let cardPurple = ColorAsset(name: "colors/cardPurple")
    internal static let deepBlue = ColorAsset(name: "colors/deepBlue")
    internal static let gridBorder = ColorAsset(name: "colors/gridBorder")
    internal static let lightBlue = ColorAsset(name: "colors/lightBlue")
    internal static let lightGray = ColorAsset(name: "colors/lightGray")
    internal static let navyBlue = ColorAsset(name: "colors/navyBlue")
    internal static let prussianBlue = ColorAsset(name: "colors/prussianBlue")
    internal static let purple = ColorAsset(name: "colors/purple")
    internal static let textGray = ColorAsset(name: "colors/textGray")
    internal static let veryLightGray = ColorAsset(name: "colors/veryLightGray")
  }
  internal enum Connection {
    internal static let background = ImageAsset(name: "connection/background")
    internal static let power = ImageAsset(name: "connection/power")
    internal enum Toggle {
      internal enum Arrow {
        internal static let down = ImageAsset(name: "connection/toggle/arrow/down")
        internal static let up = ImageAsset(name: "connection/toggle/arrow/up")
      }
      internal static let power = ImageAsset(name: "connection/toggle/power")
    }
    internal enum Wifi {
      internal static let scales1 = ImageAsset(name: "connection/wifi/scales-1")
      internal static let scales2 = ImageAsset(name: "connection/wifi/scales-2")
      internal static let scales3 = ImageAsset(name: "connection/wifi/scales-3")
      internal static let scales4 = ImageAsset(name: "connection/wifi/scales-4")
    }
  }
  internal enum Continents {
    internal static let africa = ImageAsset(name: "continents/africa")
    internal static let antarctica = ImageAsset(name: "continents/antarctica")
    internal static let asia = ImageAsset(name: "continents/asia")
    internal static let europe = ImageAsset(name: "continents/europe")
    internal static let northAmerica = ImageAsset(name: "continents/north-america")
    internal static let oceania = ImageAsset(name: "continents/oceania")
    internal static let southAmerica = ImageAsset(name: "continents/south-america")
  }
  internal enum Counter {
    internal static let minus = ImageAsset(name: "counter/minus")
    internal static let plus = ImageAsset(name: "counter/plus")
  }
  internal enum Dns {
    internal static let cloudflare = ImageAsset(name: "dns/cloudflare")
    internal static let freenom = ImageAsset(name: "dns/freenom")
    internal static let google = ImageAsset(name: "dns/google")
    internal static let handshake = ImageAsset(name: "dns/handshake")
  }
  internal enum Extra {
    internal static let dns = ImageAsset(name: "extra/dns")
    internal static let info = ImageAsset(name: "extra/info")
  }
  internal enum Icons {
    internal static let bandwidth = ImageAsset(name: "icons/bandwidth")
    internal static let copy = ImageAsset(name: "icons/copy")
    internal static let downArrow = ImageAsset(name: "icons/downArrow")
    internal static let duration = ImageAsset(name: "icons/duration")
    internal static let next = ImageAsset(name: "icons/next")
    internal static let upArrow = ImageAsset(name: "icons/upArrow")
  }
  internal enum Launch {
    internal static let exidiolBig = ImageAsset(name: "launch/exidiolBig")
  }
  internal enum Logo {
    internal static let exidio = ImageAsset(name: "logo/exidio")
    internal static let solarLabs = ImageAsset(name: "logo/solarLabs")
  }
  internal enum Navigation {
    internal static let back = ImageAsset(name: "navigation/back")
    internal static let sentinel = ImageAsset(name: "navigation/sentinel")
  }
  internal enum Node {
    internal static let city = ImageAsset(name: "node/city")
    internal static let country = ImageAsset(name: "node/country")
    internal static let download = ImageAsset(name: "node/download")
    internal enum Features {
      internal static let handshake = ImageAsset(name: "node/features/handshake")
      internal static let wireGuard = ImageAsset(name: "node/features/wireGuard")
    }
    internal static let peers = ImageAsset(name: "node/peers")
    internal static let provider = ImageAsset(name: "node/provider")
    internal static let type = ImageAsset(name: "node/type")
    internal static let upload = ImageAsset(name: "node/upload")
    internal static let version = ImageAsset(name: "node/version")
    internal static let wiFi = ImageAsset(name: "node/wi-fi")
  }
  internal enum Onboarding {
    internal static let first = ImageAsset(name: "onboarding/first")
    internal static let second = ImageAsset(name: "onboarding/second")
    internal static let third = ImageAsset(name: "onboarding/third")
  }
  internal enum Payment {
    internal static let failure = ImageAsset(name: "payment/failure")
    internal static let success = ImageAsset(name: "payment/success")
    internal static let ticket = ImageAsset(name: "payment/ticket")
  }
  internal enum Tabbar {
    internal static let account = ImageAsset(name: "tabbar/account")
    internal static let continents = ImageAsset(name: "tabbar/continents")
    internal static let extra = ImageAsset(name: "tabbar/extra")
    internal static let provider = ImageAsset(name: "tabbar/provider")
    internal static let subscribed = ImageAsset(name: "tabbar/subscribed")
  }
  internal enum Tokens {
    internal static let dvpnBlue = ImageAsset(name: "tokens/dvpn-blue")
    internal static let dvpn = ImageAsset(name: "tokens/dvpn")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
}

internal extension ImageAsset.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
