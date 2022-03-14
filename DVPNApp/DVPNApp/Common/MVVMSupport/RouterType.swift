//
//  RouterType.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 27.07.2021.
//

import Foundation
import SwiftMessages
import UIKit

protocol RouterType {
    associatedtype Event

    /// Handle a coordinator event.
    func play(event: Event)
}

extension RouterType {
    func show(
        message: String,
        theme: Theme = .error,
        presentationContext: SwiftMessages.PresentationContext = .automatic
    ) {
        let view = MessageView.viewFromNib(layout: .messageView)
        view.configureTheme(theme)
        view.button?.backgroundColor = .clear
        view.configureContent(
            title: nil,
            body: message,
            iconImage: nil,
            iconText: nil,
            buttonImage: nil,
            buttonTitle: nil,
            buttonTapHandler: nil
        )

        var config = SwiftMessages.defaultConfig
        config.duration = .seconds(seconds: 4)
        config.presentationContext = presentationContext

        SwiftMessages.show(config: config, view: view)
    }

    func showAlert(
        title: String,
        message: String? = nil,
        on navigation: UIViewController?,
        completion: @escaping (Bool) -> Void
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: L10n.Common.yes, style: .default) { _ in
            UIImpactFeedbackGenerator.lightFeedback()
            completion(true)
        }

        let cancelAction = UIAlertAction(title: L10n.Common.cancel, style: .destructive) { _ in
            UIImpactFeedbackGenerator.lightFeedback()
            completion(false)
        }

        alert.addAction(okAction)
        alert.addAction(cancelAction)

        navigation?.present(alert, animated: true, completion: nil)
    }
}

final class AnyRouter<Event>: RouterType {
    private let _playEvent: (Event) -> Void

    init<C>(_ coordinator: C) where C: RouterType,
        C.Event == Event {
        self._playEvent = coordinator.play(event:)
    }

    init(play: @escaping (Event) -> Void) {
        self._playEvent = play
    }

    func play(event: Event) {
        _playEvent(event)
    }
}

extension RouterType {
    /// Type-erase any RouterType-compliant instance.
    func asRouter() -> AnyRouter<Event> {
        return .init(self)
    }
}
