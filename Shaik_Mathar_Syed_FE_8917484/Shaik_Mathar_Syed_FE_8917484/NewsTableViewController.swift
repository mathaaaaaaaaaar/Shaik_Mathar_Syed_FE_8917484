//
//  NewsTableViewController.swift
//  Shaik_Mathar_Syed_FE_8917484
//
//  Created by Shaik Mathar Syed on 11/12/23.
//

import UIKit

class NewsTableViewController: UITableViewController {

    let apiKey = "abe00b4b0c9c485dbd4d5e5d14e32248"

    // Data model to represent news information
        struct News {
            var title: String
            var description: String
            var author: String
            var source: String
        }
    // Define the NewsAPIResponse struct to match the NewsAPI JSON structure

        // MARK: - Welcome
    struct NewsAPIResponse: Codable {
        let articles: [Article]
    }

    // MARK: - Article
    struct Article: Codable {
        let source: Source
        let author: String?
        let title, description: String
    }

    // MARK: - Source
    struct Source: Codable {
        let name: String
    }
    var cityName: String?

    var selectedCity: String?

    // Array to store news data
    var newsData: [News] = []

        override func viewDidLoad() {
            super.viewDidLoad()
        }

    func setCityName(_ cityName: String) {
        print("Received cityName:", cityName)
        self.cityName = cityName
        self.fetchNews(cityName)
    }
    func fetchNews(_ cityName: String) {
        let newsURL = "https://newsapi.org/v2/everything?q=\(cityName)&apiKey=\(apiKey)"
        print(newsURL)

        guard let url = URL(string: newsURL) else {
            print("Invalid URL")
            return
        }

        // Create a data task to fetch news data
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching news: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                // Decode JSON data into a struct representing the NewsAPI response
                let decoder = JSONDecoder()
                let newsAPIResponse = try decoder.decode(NewsAPIResponse.self, from: data)

                // Extract relevant information and populate the newsData array
                self.newsData = newsAPIResponse.articles.map {
                    News(title: $0.title, description: $0.description, author: $0.author ?? "", source: $0.source.name)
                }

                // Update UI on the main thread
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }

        // Start the data task
        task.resume()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("NewsData")
        print(newsData.count)
        return newsData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsTableViewCell

        // Get the news for the current row
        let news = newsData[indexPath.row]

        // Populate the labels with news data
        cell.newsTitle.text = news.title
        cell.authorLabel.text = "Author : "+news.author
        cell.sourceLabel.text = "Source : "+news.source
        cell.descriptionLabel.text = news.description

        return cell
    }


    @IBAction func locationButton(_ sender: Any) {
        showChangeLocationAlert()
    }
    
    func showChangeLocationAlert(){
        let alertController = UIAlertController(
                title: "Where would you want news from?",
                message: "Enter your new news location here",
                preferredStyle: .alert
            )

            alertController.addTextField { textField in
                textField.placeholder = "Enter city name"
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let changeAction = UIAlertAction(title: "Change", style: .default) { _ in
                if let cityName = alertController.textFields?.first?.text {
                    self.selectedCity = cityName
                    self.fetchNews(cityName)
                }
            }

            alertController.addAction(cancelAction)
            alertController.addAction(changeAction)

        present(alertController, animated: true, completion: nil)
    }


    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Adjust the cell height based on your design
        return 220.0
    }
}
