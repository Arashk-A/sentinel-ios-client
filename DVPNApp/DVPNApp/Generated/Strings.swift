// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {

  internal enum AccountCreation {
    /// Wallet Address
    internal static let walletAddress = L10n.tr("Localizable", "AccountCreation.WalletAddress")
    /// Please keep record of these phrases exactly, this will never be recovered in any condition.
    internal static let warning = L10n.tr("Localizable", "AccountCreation.Warning")
    internal enum Button {
      internal enum ImportNow {
        /// Import Now
        internal static let action = L10n.tr("Localizable", "AccountCreation.Button.ImportNow.Action")
        /// Already have an account?
        internal static let text = L10n.tr("Localizable", "AccountCreation.Button.ImportNow.Text")
      }
    }
    internal enum Copied {
      /// Address is copied
      internal static let address = L10n.tr("Localizable", "AccountCreation.Copied.Address")
      /// Mnemonic is copied
      internal static let mnemonic = L10n.tr("Localizable", "AccountCreation.Copied.Mnemonic")
    }
    internal enum Create {
      /// Create an Account
      internal static let button = L10n.tr("Localizable", "AccountCreation.Create.Button")
      /// Create a new Account
      internal static let title = L10n.tr("Localizable", "AccountCreation.Create.Title")
      internal enum Button {
        /// Copy mnemonic
        internal static let copy = L10n.tr("Localizable", "AccountCreation.Create.Button.Copy")
      }
    }
    internal enum Error {
      /// Misconfigured wallet. Please, re-check your mnemonic and try again
      internal static let creationFailed = L10n.tr("Localizable", "AccountCreation.Error.CreationFailed")
      /// Please read and accept terms and conditions
      internal static let termsUnchecked = L10n.tr("Localizable", "AccountCreation.Error.TermsUnchecked")
    }
    internal enum Import {
      /// Import Account
      internal static let button = L10n.tr("Localizable", "AccountCreation.Import.Button")
      /// Import security Phrases
      internal static let title = L10n.tr("Localizable", "AccountCreation.Import.Title")
      internal enum Button {
        /// Paste
        internal static let paste = L10n.tr("Localizable", "AccountCreation.Import.Button.Paste")
      }
    }
    internal enum Terms {
      /// terms and conditions
      internal static let button = L10n.tr("Localizable", "AccountCreation.Terms.Button")
      /// I understand and agree to
      internal static let text = L10n.tr("Localizable", "AccountCreation.Terms.Text")
    }
  }

  internal enum AccountInfo {
    /// Copy
    internal static let copy = L10n.tr("Localizable", "AccountInfo.Copy")
    /// Current price
    internal static let currentPrice = L10n.tr("Localizable", "AccountInfo.CurrentPrice")
    /// Share
    internal static let share = L10n.tr("Localizable", "AccountInfo.Share")
    /// Copied
    internal static let textCopied = L10n.tr("Localizable", "AccountInfo.TextCopied")
    /// TOP-UP
    internal static let topUp = L10n.tr("Localizable", "AccountInfo.TopUp")
    internal enum Wallet {
      /// Account Balance
      internal static let title = L10n.tr("Localizable", "AccountInfo.Wallet.Title")
    }
  }

  internal enum AvailableNodes {
    /// Nodes in %@
    internal static func title(_ p1: Any) -> String {
      return L10n.tr("Localizable", "AvailableNodes.Title", String(describing: p1))
    }
  }

  internal enum Common {
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "Common.Cancel")
    /// Crypto
    internal static let crypto = L10n.tr("Localizable", "Common.Crypto")
    /// GB
    internal static let gb = L10n.tr("Localizable", "Common.GB")
    /// Yes
    internal static let yes = L10n.tr("Localizable", "Common.Yes")
    internal enum Points {
      /// points
      internal static let title = L10n.tr("Localizable", "Common.Points.Title")
    }
  }

  internal enum Connection {
    /// Connection State
    internal static let title = L10n.tr("Localizable", "Connection.Title")
    internal enum Button {
      /// CONNECT
      internal static let connect = L10n.tr("Localizable", "Connection.Button.Connect")
      /// DISCONNECT
      internal static let disconnect = L10n.tr("Localizable", "Connection.Button.Disconnect")
    }
    internal enum Error {
      /// Misconfigured nodes. Please, try again or select another node
      internal static let invalidURL = L10n.tr("Localizable", "Connection.Error.InvalidURL")
      /// Not enough points to broadcast - you'll need at least 0.01 points on your account. Please, check your balance and try again later
      internal static let notEnoughTokens = L10n.tr("Localizable", "Connection.Error.NotEnoughTokens")
      /// Misconfigured wallet. Please, try again or re-import your mnemonic
      internal static let signatureGenerationFailed = L10n.tr("Localizable", "Connection.Error.SignatureGenerationFailed")
    }
    internal enum InfoType {
      /// Bandwidth
      internal static let bandwidth = L10n.tr("Localizable", "Connection.InfoType.Bandwidth")
      /// Consumed
      internal static let consumed = L10n.tr("Localizable", "Connection.InfoType.Consumed")
      /// Download
      internal static let download = L10n.tr("Localizable", "Connection.InfoType.Download")
      /// Duration
      internal static let duration = L10n.tr("Localizable", "Connection.InfoType.Duration")
      /// Upload
      internal static let upload = L10n.tr("Localizable", "Connection.InfoType.Upload")
    }
    internal enum LocationSelector {
      /// CHANGE
      internal static let change = L10n.tr("Localizable", "Connection.LocationSelector.Change")
      /// Fetching the node info
      internal static let fetching = L10n.tr("Localizable", "Connection.LocationSelector.Fetching")
    }
    internal enum Resubscribe {
      /// Data update is pending, but it seems you used all data. Do you want to resubscribe?
      internal static let subtitle = L10n.tr("Localizable", "Connection.Resubscribe.Subtitle")
      /// All data used
      internal static let title = L10n.tr("Localizable", "Connection.Resubscribe.Title")
    }
    internal enum Status {
      internal enum Connection {
        /// Checking balance
        internal static let balanceCheck = L10n.tr("Localizable", "Connection.Status.Connection.BalanceCheck")
        /// Connected
        internal static let connected = L10n.tr("Localizable", "Connection.Status.Connection.Connected")
        /// Disconnected
        internal static let disconnected = L10n.tr("Localizable", "Connection.Status.Connection.Disconnected")
        /// Exchanging keys
        internal static let keysExchange = L10n.tr("Localizable", "Connection.Status.Connection.KeysExchange")
        /// Poor or no internet connection
        internal static let lost = L10n.tr("Localizable", "Connection.Status.Connection.Lost")
        /// Checking node status
        internal static let nodeStatus = L10n.tr("Localizable", "Connection.Status.Connection.NodeStatus")
        /// Waiting for confirmation
        internal static let sessionBroadcast = L10n.tr("Localizable", "Connection.Status.Connection.SessionBroadcast")
        /// Checking status
        internal static let sessionStatus = L10n.tr("Localizable", "Connection.Status.Connection.SessionStatus")
        /// Fetching the subscription
        internal static let subscriptionStatus = L10n.tr("Localizable", "Connection.Status.Connection.SubscriptionStatus")
        /// Preparing iOS VPN tunnel
        internal static let tunnelUpdating = L10n.tr("Localizable", "Connection.Status.Connection.TunnelUpdating")
      }
    }
  }

  internal enum Continents {
    /// %d available nodes
    internal static func availableNodes(_ p1: Int) -> String {
      return L10n.tr("Localizable", "Continents.AvailableNodes", p1)
    }
    /// Nodes
    internal static let title = L10n.tr("Localizable", "Continents.Title")
    internal enum Button {
      /// QUICK CONNECT
      internal static let connect = L10n.tr("Localizable", "Continents.Button.Connect")
      /// DISCONNECT
      internal static let disconnect = L10n.tr("Localizable", "Continents.Button.Disconnect")
    }
  }

  internal enum Dns {
    /// Cloudflare
    internal static let cloudflare = L10n.tr("Localizable", "DNS.Cloudflare")
    /// Freenom
    internal static let freenom = L10n.tr("Localizable", "DNS.Freenom")
    /// Google
    internal static let google = L10n.tr("Localizable", "DNS.Google")
    /// Handshake
    internal static let handshake = L10n.tr("Localizable", "DNS.Handshake")
    /// Default DNS Server
    internal static let title = L10n.tr("Localizable", "DNS.Title")
  }

  internal enum Error {
    /// Failed to start a session. Please, try again or select another node
    internal static let connectionParsingFailed = L10n.tr("Localizable", "Error.ConnectionParsingFailed")
    /// Please allow the tunnel creation to connect to your session
    internal static let tunnelCreationDenied = L10n.tr("Localizable", "Error.TunnelCreationDenied")
    /// Selected node is temporary unavailable. Please, try later or select another node
    internal static let unavailableNode = L10n.tr("Localizable", "Error.UnavailableNode")
    internal enum GRPCError {
      /// Request was cancelled.
      internal static let rpcCancelled = L10n.tr("Localizable", "Error.GRPCError.RPCCancelled")
      /// Request timed-out. No internet connection.
      internal static let rpcTimedOut = L10n.tr("Localizable", "Error.GRPCError.RPCTimedOut")
    }
  }

  internal enum Extras {
    /// Extras
    internal static let title = L10n.tr("Localizable", "Extras.Title")
  }

  internal enum Home {
    internal enum Extra {
      /// Built by
      internal static let build = L10n.tr("Localizable", "Home.Extra.Build")
      /// Default DNS
      internal static let dns = L10n.tr("Localizable", "Home.Extra.DNS")
      internal enum Button {
        /// Learn more
        internal static let more = L10n.tr("Localizable", "Home.Extra.Button.More")
      }
      internal enum More {
        /// Sentinel P2P bandwidth market place
        internal static let subtitle = L10n.tr("Localizable", "Home.Extra.More.Subtitle")
        /// Learn More
        internal static let title = L10n.tr("Localizable", "Home.Extra.More.Title")
      }
    }
    internal enum Node {
      internal enum All {
        /// No available nodes found
        internal static let notFound = L10n.tr("Localizable", "Home.Node.All.NotFound")
        /// All nodes
        internal static let title = L10n.tr("Localizable", "Home.Node.All.Title")
      }
      internal enum Details {
        /// Latency
        internal static let latency = L10n.tr("Localizable", "Home.Node.Details.Latency")
        /// Peers
        internal static let peers = L10n.tr("Localizable", "Home.Node.Details.Peers")
        /// Price
        internal static let price = L10n.tr("Localizable", "Home.Node.Details.Price")
      }
      internal enum Subscribed {
        /// Subscribed
        internal static let title = L10n.tr("Localizable", "Home.Node.Subscribed.Title")
      }
    }
  }

  internal enum NodeDetails {
    /// CONNECT NOW
    internal static let connect = L10n.tr("Localizable", "NodeDetails.Connect")
    /// Details
    internal static let title = L10n.tr("Localizable", "NodeDetails.Title")
    internal enum InfoType {
      /// Node Address
      internal static let address = L10n.tr("Localizable", "NodeDetails.InfoType.Address")
      /// City
      internal static let city = L10n.tr("Localizable", "NodeDetails.InfoType.City")
      /// Country
      internal static let country = L10n.tr("Localizable", "NodeDetails.InfoType.Country")
      /// Download speed
      internal static let downloadSpeed = L10n.tr("Localizable", "NodeDetails.InfoType.DownloadSpeed")
      /// Features
      internal static let features = L10n.tr("Localizable", "NodeDetails.InfoType.Features")
      /// Connected peers count
      internal static let peers = L10n.tr("Localizable", "NodeDetails.InfoType.Peers")
      /// Node provider
      internal static let provider = L10n.tr("Localizable", "NodeDetails.InfoType.Provider")
      /// Type of Node
      internal static let typeOfNode = L10n.tr("Localizable", "NodeDetails.InfoType.TypeOfNode")
      /// Upload speed
      internal static let uploadSpeed = L10n.tr("Localizable", "NodeDetails.InfoType.UploadSpeed")
      /// Version
      internal static let version = L10n.tr("Localizable", "NodeDetails.InfoType.Version")
    }
  }

  internal enum Onboarding {
    /// Decentralized VPN based on Sentinel Blockchain
    internal static let description = L10n.tr("Localizable", "Onboarding.Description")
    /// Exidio dVPN
    internal static let title = L10n.tr("Localizable", "Onboarding.Title")
    internal enum Button {
      /// Create an account
      internal static let start = L10n.tr("Localizable", "Onboarding.Button.Start")
      internal enum ImportNow {
        /// Import Now
        internal static let action = L10n.tr("Localizable", "Onboarding.Button.ImportNow.Action")
        /// Already have an account?
        internal static let text = L10n.tr("Localizable", "Onboarding.Button.ImportNow.Text")
      }
    }
  }

  internal enum Plans {
    /// SUBSCRIBE
    internal static let subscribe = L10n.tr("Localizable", "Plans.Subscribe")
    /// How much points do you want to spend?
    internal static let title = L10n.tr("Localizable", "Plans.Title")
    internal enum AddTokens {
      /// Top-up your wallet?
      internal static let subtitle = L10n.tr("Localizable", "Plans.AddTokens.Subtitle")
      /// Not enough points to subscribe
      internal static let title = L10n.tr("Localizable", "Plans.AddTokens.Title")
    }
    internal enum Error {
      internal enum Payment {
        /// Your transaction was unsuccessful. Please try again.
        internal static let failed = L10n.tr("Localizable", "Plans.Error.Payment.Failed")
      }
    }
    internal enum Subscribe {
      /// Subscribe to %@?
      internal static func title(_ p1: Any) -> String {
        return L10n.tr("Localizable", "Plans.Subscribe.Title", String(describing: p1))
      }
    }
  }

  internal enum Purchases {
    /// The payment of %@ will be charged to your iTunes account at confirmation of purchase. Points will be credited to your account within few minutes after purchase.
    internal static func description(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Purchases.Description", String(describing: p1))
    }
    /// Buy more points
    internal static let title = L10n.tr("Localizable", "Purchases.Title")
    internal enum Button {
      /// Buy now
      internal static let buy = L10n.tr("Localizable", "Purchases.Button.Buy")
    }
    internal enum Info {
      /// Purchase is succefully made.
      internal static let completed = L10n.tr("Localizable", "Purchases.Info.Completed")
    }
    internal enum Terms {
      /// terms of service.
      internal static let button = L10n.tr("Localizable", "Purchases.Terms.Button")
      /// By continuing you agree to
      internal static let title = L10n.tr("Localizable", "Purchases.Terms.Title")
    }
    internal enum Warning {
      /// Purchase was canceled.
      internal static let cancelled = L10n.tr("Localizable", "Purchases.Warning.Cancelled")
    }
  }

  internal enum SecurityService {
    internal enum Error {
      /// Empty mnemonic. Please, enter valid ones and try again
      internal static let emptyInput = L10n.tr("Localizable", "SecurityService.Error.EmptyInput")
      /// Invalid mnemonic. Please, enter valid one and try again
      internal static let invalidInput = L10n.tr("Localizable", "SecurityService.Error.InvalidInput")
    }
  }

  internal enum SentinelService {
    internal enum Error {
      /// Couldn't process the broadcast. Please, check your balance and try again later
      internal static let broadcastFailed = L10n.tr("Localizable", "SentinelService.Error.BroadcastFailed")
    }
  }

  internal enum SubscribedNodes {
    /// Failed to load nodes
    internal static let noConnection = L10n.tr("Localizable", "SubscribedNodes.NoConnection")
    /// You are not subscribed to any nodes
    internal static let notFound = L10n.tr("Localizable", "SubscribedNodes.NotFound")
    /// Successfully unsubscribed from %@
    internal static func subscriptionCanceled(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SubscribedNodes.SubscriptionCanceled", String(describing: p1))
    }
    /// Subscribed nodes
    internal static let title = L10n.tr("Localizable", "SubscribedNodes.Title")
    internal enum CancelSubscription {
      /// Unsubscribe from %@?
      internal static func title(_ p1: Any) -> String {
        return L10n.tr("Localizable", "SubscribedNodes.CancelSubscription.Title", String(describing: p1))
      }
    }
    internal enum Error {
      /// Subscription cancellation failed
      internal static let subscriptionCancellationFailed = L10n.tr("Localizable", "SubscribedNodes.Error.SubscriptionCancellationFailed")
    }
  }

  internal enum TabBar {
    internal enum Item {
      /// My Account
      internal static let account = L10n.tr("Localizable", "TabBar.Item.Account")
      /// All nodes
      internal static let continents = L10n.tr("Localizable", "TabBar.Item.Continents")
      /// Extras
      internal static let extra = L10n.tr("Localizable", "TabBar.Item.Extra")
      /// Subscribed
      internal static let subscribedNodes = L10n.tr("Localizable", "TabBar.Item.SubscribedNodes")
    }
  }

  internal enum WalletService {
    internal enum Error {
      /// Self-sending is not supported
      internal static let accountMatchesDestination = L10n.tr("Localizable", "WalletService.Error.AccountMatchesDestination")
      /// Misconfigured wallet: failed to fetch authorization. Please, try again or re-import your mnemonic
      internal static let missingAuthorization = L10n.tr("Localizable", "WalletService.Error.MissingAuthorization")
      /// Misconfigured wallet: missing mnemonic. Please, try again or re-import your mnemonic
      internal static let missingMnemonics = L10n.tr("Localizable", "WalletService.Error.MissingMnemonics")
      /// Misconfigured wallet: mnemonic mismatch. Please, try again or re-import your mnemonic
      internal static let mnemonicsDoNotMatch = L10n.tr("Localizable", "WalletService.Error.MnemonicsDoNotMatch")
      /// Not enough points to broadcast. Please, check your balance and try again later
      internal static let notEnoughTokens = L10n.tr("Localizable", "WalletService.Error.NotEnoughTokens")
      /// Couldn't save wallet. Please, try again.
      internal static let savingError = L10n.tr("Localizable", "WalletService.Error.SavingError")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
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
