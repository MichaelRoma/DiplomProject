//
//  ProfileTV.swift
//  Course2FinalTask
//
//  Created by Mykhailo Romanovskyi on 08.03.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class ProfileTableView: UIViewController {
    
    private var tableData: [User]
    private var navigationTitle: String
    
    private let tableViewCellIdentifier = "ProfileTVCell"
    private let tableView = UITableView()
    
    init(data: [User], navTitle: String) {
        tableData = data
        navigationTitle = navTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        navigationItem.title = navigationTitle
    }
}

private extension ProfileTableView {
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, bottom: view.bottomAnchor, left: view.leadingAnchor, right: view.trailingAnchor)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: tableViewCellIdentifier)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 74.0, bottom: 0, right: 0.0)
        tableView.separatorInsetReference = .fromCellEdges
    }
}

extension ProfileTableView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier, for: indexPath) as! ProfileTableViewCell
        let bufferData = tableData[indexPath.row]
        cell.setCellProperty(image: bufferData.avatar, text: bufferData.fullName)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let forUser = tableData[indexPath.row]
        let profile = ProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        profile.configurator(user: forUser)
        navigationController?.pushViewController(profile, animated: true)
    }
}
