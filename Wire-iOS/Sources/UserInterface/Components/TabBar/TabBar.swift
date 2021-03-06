// 
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 


import Cartography

protocol TabBarDelegate : class {
    func tabBar(_ tabBar: TabBar, didSelectItemAt index: Int)
}

@objc
class TabBar: UIView {
    fileprivate let stackView = UIStackView()

    // MARK: - Properties

    weak var delegate : TabBarDelegate?
    var animatesTransition: Bool = false

    fileprivate(set) var items : [UITabBarItem] = []
    private(set) var tabs: [Tab] = []

    var style: ColorSchemeVariant {
        didSet {
            tabs.forEach(updateTabStyle)
        }
    }

    fileprivate(set) var selectedIndex : Int {
        didSet {
            updateButtonSelection()
        }
    }

    fileprivate var selectedTab : Tab {
        return self.tabs[selectedIndex]
    }

    // MARK: - Initialization

    init(items: [UITabBarItem], style: ColorSchemeVariant, selectedIndex: Int = 0) {
        precondition(items.count > 0, "TabBar must be initialized with at least one item")
        
        self.items = items
        self.selectedIndex = selectedIndex
        self.style = style
        
        super.init(frame: CGRect.zero)

        if #available(iOS 10, *) {
            self.accessibilityTraits = UIAccessibilityTraitTabBar
        }

        setupViews()
        createConstraints()
        updateButtonSelection()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        tabs = items.map(makeButtonForItem)
        tabs.forEach(stackView.addArrangedSubview)

        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.alignment = .fill
        addSubview(stackView)
    }
    
    fileprivate func createConstraints() {
        constrain(self, stackView) { selfView, stackView in
            stackView.left == selfView.left + 16
            stackView.right == selfView.right - 16
            stackView.top == selfView.top
            stackView.height == 48

            selfView.bottom == stackView.bottom
        }
    }

    fileprivate func makeButtonForItem(_ item: UITabBarItem) -> Tab {
        let tab = Tab(variant: style)
        tab.textTransform = .upper
        tab.setTitle(item.title, for: .normal)
        tab.addTarget(self, action: #selector(TabBar.itemSelected(_:)), for: .touchUpInside)
        tab.cas_styleClass = styleClass()
        return tab
    }

    // MARK: - Styling

    fileprivate func updateTabStyle(_ tab: Tab) {
        tab.colorSchemeVariant = style
        tab.cas_styleClass = styleClass()
    }
    
    fileprivate func styleClass() -> String {
        switch (style) {
        case .light:
            return "tab-light"
        case .dark:
            return "tab-dark"
        }
    }

    // MARK: - Actions
    
    func itemSelected(_ sender: AnyObject) {
        guard
            let tab = sender as? Tab,
            let selectedIndex =  self.tabs.index(of: tab)
        else {
            return
        }
        
        self.delegate?.tabBar(self, didSelectItemAt: selectedIndex)
        setSelectedIndex(selectedIndex, animated: animatesTransition)
    }

    func setSelectedIndex( _ index: Int, animated: Bool) {
        if (animated) {
            UIView.transition(with: self, duration: 0.35, options: [.transitionCrossDissolve, .allowUserInteraction], animations: {
                self.selectedIndex = index
                self.layoutIfNeeded()
            })
        } else {
            self.selectedIndex = index
            self.layoutIfNeeded()
        }
    }

    fileprivate func updateButtonSelection() {
        tabs.forEach { $0.isSelected = false }
        tabs[selectedIndex].isSelected = true
    }
}
