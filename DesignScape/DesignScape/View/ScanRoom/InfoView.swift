//
//  InfoView.swift
//  DesignScape
//
//  Created by Minh Huynh on 2/24/24.
//
import UIKit


class InfoView: UIView {
    private(set) var labelView: LabelView?

    private var labelSize: CGSize
    private var labelBackgroundColor: UIColor
    private var labelTextColor: UIColor

    init(pickerData: [String], labelSize: CGSize, backgroundColor: UIColor, labelBackgroundColor: UIColor, labelTextColor: UIColor) {
        self.labelSize = labelSize
        self.labelBackgroundColor = labelBackgroundColor
        self.labelTextColor = labelTextColor
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func setupView() {
        clipsToBounds = true
        setupLabelView()
    }

    private func setupLabelView() {
        let frame = CGRectMake(0.0, 0.0, labelSize.width, labelSize.height)
        let labelView = LabelView(frame: frame, backgroundColor: .white, textColor: UIColor.accent)
        labelView.title = ""
        addSubview(labelView)
        self.labelView = labelView
    }
}


