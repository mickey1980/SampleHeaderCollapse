//
//  ContainingViewController.swift
//  TestCollapsingHeader
//
//  Created by Samuel Shiffman on 9/25/20.
//

import UIKit

// MARK:- Containing ViewController
class CollapsableHeaderViewController: UIViewController {
        
    private let headerView: UIView = {
        let control = UIView()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.backgroundColor = .red
        return control
    }()
    private let containerView: UIView = {
        let control = UIView()
        control.backgroundColor = .clear
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private var headerViewHeight: NSLayoutConstraint!
    private var headerViewTop: NSLayoutConstraint!
    private var containerViewTop: NSLayoutConstraint!
    private var tableView: UITableView! = nil
    
    var maxScrollAmount: CGFloat {
        let expandedHeight = headerViewHeight.constant
        let collapsedHeight = containerViewTop.constant
        return expandedHeight - collapsedHeight
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    private func setup() {

        self.view.addSubview(self.containerView)
        self.containerViewTop = self.containerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100)
        self.containerViewTop.isActive = true
        self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.containerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        self.view.addSubview(headerView)
        self.headerViewTop = self.headerView.topAnchor.constraint(equalTo: self.view.topAnchor)
        self.headerViewTop.isActive = true
        self.headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.headerViewHeight = self.headerView.heightAnchor.constraint(equalToConstant: 456)
        self.headerViewHeight.isActive = true
    
        
        self.tableView = UITableView(frame: .zero, style: .plain)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(TVC.self, forCellReuseIdentifier: "cellId")
        
        self.containerView.addSubview(self.tableView)
        
        if let scrollView = containerView.subviews.first as? UIScrollView {
            // adjust the scroll view's top inset to account for scrolling the header offscreen
            scrollView.contentInset = UIEdgeInsets(top: maxScrollAmount, left: 0, bottom: 0, right: 0)
            scrollView.contentOffset.y = -maxScrollAmount
        }
                 
    }
}

extension CollapsableHeaderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 100
     }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! TVC
        cell.titleLabel.text = "\(indexPath.row)"
     return cell
 }
}

extension CollapsableHeaderViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // need to adjust the content offset to account for the content inset
        // negative because we are moving the header offscreen
        let newTopConstraintConstant = -(scrollView.contentOffset.y + scrollView.contentInset.top)
        headerViewTop.constant = min(0, max(-maxScrollAmount, newTopConstraintConstant))
        let isAtTop = headerViewTop.constant == -maxScrollAmount

        // handle changes for collapsed state
        scrollViewScrolled(scrollView, didScrollToTop: isAtTop)

    }

    func scrollViewScrolled(_ scrollView: UIScrollView, didScrollToTop isAtTop:Bool) {
        self.headerView.backgroundColor = isAtTop ? UIColor.green : UIColor.systemIndigo
    }
}

// MARK:- TableView Cell
class TVC: UITableViewCell {
    
    let titleLabel: UILabel = {
        let control = UILabel()
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(self.titleLabel)
        
        self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.titleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
