import UIKit

class NewsTableViewController: UITableViewController {

    let newsAPIKey = "9e57c79bdea8420eb6a36096b2944c54"

    // Data model to represent news information
    struct News {
        var title: String
        var description: String
        var author: String
        var source: String
        var cityName: String // Include cityName in News
    }

    // Define the NewsAPIResponse struct to match the NewsAPI JSON structure
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
        let newsURL = "https://newsapi.org/v2/everything?q=\(cityName)&apiKey=\(newsAPIKey)"
        print(newsURL)

        guard let url = URL(string: newsURL) else {
            print("Invalid URL")
            return
        }

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
                let decoder = JSONDecoder()
                let newsAPIResponse = try decoder.decode(NewsAPIResponse.self, from: data)

                self.newsData = newsAPIResponse.articles.map {
                    News(
                        title: $0.title,
                        description: $0.description,
                        author: $0.author ?? "",
                        source: $0.source.name,
                        cityName: cityName // Include cityName in News
                    )
                }

                // Save data to UserDefaults
                self.saveNewsToUserDefaults()

                // Update UI on the main thread
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }

        task.resume()
    }

    func saveNewsToUserDefaults() {
        // Include cityName in the dictionary to be saved
        let encodedData = newsData.map {
            [
                "title": $0.title,
                "description": $0.description,
                "author": $0.author,
                "source": $0.source,
                "cityName": $0.cityName // Include cityName in the saved data
            ]
        }
        UserDefaults.standard.set(encodedData, forKey: "savedNewsData")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! NewsTableViewCell

        let news = newsData[indexPath.row]

        cell.titleLabel.text = news.title
        cell.authorLabel.text = "Author : " + news.author
        cell.sourceLabel.text = "Source : " + news.source
        cell.descriptionLabel.text = news.description

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220.0
    }

    @IBAction func locationButton(_ sender: Any) {
        showChangeLocationAlert()
    }

    func showChangeLocationAlert() {
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
}

extension NewsTableViewController.News {
    init?(fromDictionary data: [String: Any]) {
        guard
            let title = data["title"] as? String,
            let description = data["description"] as? String,
            let author = data["author"] as? String,
            let source = data["source"] as? String,
            let cityName = data["cityName"] as? String // Include cityName in the initialization
        else {
            return nil
        }

        self.title = title
        self.description = description
        self.author = author
        self.source = source
        self.cityName = cityName // Set cityName
    }

    var toDictionary: [String: Any] {
        return [
            "title": title,
            "description": description,
            "author": author,
            "source": source,
            "cityName": cityName // Include cityName in the dictionary
        ]
    }
}
