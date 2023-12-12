import UIKit

class HistoryTableViewController: UITableViewController {

    var historyData: [NewsTableViewController.News] = [] // Assuming News struct is accessible globally

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load news history from UserDefaults
        historyData = loadNewsFromUserDefaults()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsHistoryCell", for: indexPath) as! HistoryTableViewCell

        let news = historyData[indexPath.row]

        cell.newsTitleLabel.text = news.title
        cell.newsAuthorLabel.text = "Author: " + news.author
        cell.newsSourceLabel.text = "Source: " + news.source
        cell.newsDescriptionLabel.text = news.description
        cell.cityNameLabel.text = news.cityName // Display cityName
        cell.fromScreenLabel.text = "News"
        return cell
    }

    // Function to load news history from UserDefaults
    func loadNewsFromUserDefaults() -> [NewsTableViewController.News] {
        if let encodedData = UserDefaults.standard.array(forKey: "savedNewsData") as? [[String: Any]] {
            return encodedData.compactMap { NewsTableViewController.News(fromDictionary: $0) }
        }
        return []
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove the item from the data source
            historyData.remove(at: indexPath.row)
            // Save the updated data to UserDefaults
            saveNewsToUserDefaults()
            // Delete the row from the table view
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // Function to save news data to UserDefaults
    func saveNewsToUserDefaults() {
        let encodedData = historyData.map { $0.toDictionary }
        UserDefaults.standard.set(encodedData, forKey: "savedNewsData")
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250.0
    }
}
