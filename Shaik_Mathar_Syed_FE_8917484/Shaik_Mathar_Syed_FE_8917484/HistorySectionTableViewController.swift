//
//  HistorySectionTableViewController.swift
//  Shaik_Mathar_Syed_FE_8917484
//
//  Created by Shaik Mathar Syed on 11/12/23.
//

import UIKit

class HistorySectionTableViewController: UITableViewController {

    var historyData: [NewsTableViewController.News] = [] // Assuming News struct is accessible globally

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load news history from UserDefaults
        historyData = fetchNewsFromUserDefaults()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistorySectionTableViewCell

        let news = historyData[indexPath.row]

        cell.titleLabel.text = news.title
        cell.authorLabel.text = "Author: " + news.author
        cell.sourceLabel.text = "Source: " + news.source
        cell.descriptionLabel.text = news.description
        cell.cityNameLabel.text = news.cityName // Display cityName
        cell.fromLabel.text = "News"
        return cell
    }

    // Function to fetch news history from UserDefaults
    func fetchNewsFromUserDefaults() -> [NewsTableViewController.News] {
        if let encodedData = UserDefaults.standard.array(forKey: "savedNewsData") as? [[String: Any]] {
            return encodedData.compactMap { NewsTableViewController.News(fromDict: $0) }
        }
        return []
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove the item from the data source
            historyData.remove(at: indexPath.row)
            // Delete the row from the table view
            tableView.deleteRows(at: [indexPath], with: .fade)
            // Save the updated data to UserDefaults
            storeNewsToUserDefaults()
        }
    }

    // Function to store news data to UserDefaults
    func storeNewsToUserDefaults() {
        let encodedData = historyData.map { $0.toDict }
        UserDefaults.standard.set(encodedData, forKey: "savedNewsData")
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250.0
    }
}
