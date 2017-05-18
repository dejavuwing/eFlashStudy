//
//  TextStyle.swift
//  eFlashStudy
//
//  Created by nGle on 2017. 3. 7..
//  Copyright © 2017년 Tongchun. All rights reserved.
//

import Foundation
import BonMot

class TextStyle {

    /// 텍스트 스타일 정의
    static func stringStyle(category: FlashCategory) -> StringStyle {
        var titleStyle = StringStyle()
        var explainStyle = StringStyle()
        var meanStyle = StringStyle()
        var accentStyle = StringStyle()

        var setLineHeight: CGFloat = 0.0

        // pad일 때와 phone일때 폰트를 다르게 한다.
        if UI_USER_INTERFACE_IDIOM() == .pad {

            titleStyle = StringStyle(.font(UIFont(name: "AvenirNext-DemiBoldItalic", size: 32.0)!))
            explainStyle = StringStyle(.font(UIFont(name: "AvenirNext-Italic", size: 24.0)!))
            meanStyle = StringStyle(.font(UIFont(name: "Helvetica-LightOblique", size: 24.0)!))
            accentStyle = StringStyle(.font(UIFont(name: "Helvetica-LightOblique", size: 28.0)!))

            if category == .ebs {
                setLineHeight = 1.4
            } else {
                setLineHeight = 1.0
            }

        } else {

            // flashword와 일반 category의 스타일을 구분한다.
            if category == .flashword {
                titleStyle = StringStyle(.font(UIFont(name: "Helvetica-Bold", size: 24.0)!))
                explainStyle = StringStyle(.font(UIFont(name: "Helvetica-Light", size: 16.0)!))
                meanStyle = StringStyle(.font(UIFont(name: "Helvetica-Light", size: 16.0)!))
                accentStyle = StringStyle(.font(UIFont(name: "Helvetica-Bold", size: 17.0)!))
                setLineHeight = 1.2

            } else {
                titleStyle = StringStyle(.font(UIFont(name: "Helvetica-Bold", size: 18.0)!))
                explainStyle = StringStyle(.font(UIFont(name: "Helvetica-Light", size: 16.0)!))
                meanStyle = StringStyle(.font(UIFont(name: "Helvetica-Light", size: 16.0)!))
                accentStyle = StringStyle(.font(UIFont(name: "Helvetica-Bold", size: 17.0)!))
                setLineHeight = 1.2
            }
        }

        let textViewStyle = StringStyle(
            .font(UIFont.systemFont(ofSize: 16)),
            .lineHeightMultiple(setLineHeight),
            .color(.black),
            .xmlRules([
                .style("title", titleStyle),
                .style("explain", explainStyle),
                .style("mean", meanStyle),
                .style("accent", accentStyle)
                ])
        )

        return textViewStyle
    }

    static func stringStyleForSearchResult() -> StringStyle {
        let titleStyle = StringStyle(.font(UIFont(name: "Helvetica-Bold", size: 18.0)!))
        let explainStyle = StringStyle(.font(UIFont(name: "Helvetica-Light", size: 14.0)!))
        let meanStyle = StringStyle(.font(UIFont(name: "Helvetica-Light", size: 14.0)!))
        let accentStyle = StringStyle(.font(UIFont(name: "Helvetica-Bold", size: 16.0)!))

        let setLineHeight: CGFloat = 0.0

        let textViewStyle = StringStyle(
            .font(UIFont.systemFont(ofSize: 15)),
            .lineHeightMultiple(setLineHeight),
            .color(.black),
            .xmlRules([
                .style("title", titleStyle),
                .style("explain", explainStyle),
                .style("mean", meanStyle),
                .style("accent", accentStyle)
                ])
        )

        return textViewStyle
    }
}
