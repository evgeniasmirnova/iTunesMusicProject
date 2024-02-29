//
//  MusicPlayerScreen.swift
//  zhenmusic
//
//  Created by Евгения Смирнова on 20.12.2023.
//

import Foundation


class Screen<View: ViewProtocol, Presenter> {
        let view: View
        let presenter: Presenter
        
        init(view: View, presenter: Presenter) {
            self.view = view
            self.presenter = presenter
            
            view.retain = presenter
        }
    }
}
