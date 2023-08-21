import UIKit
import RealmSwift

final class MainViewController: UIViewController {
    
    var searchController = UISearchController(searchResultsController: nil)
    var places: [Place] = []
    var mainViewModel = MainViewModel()
    var alertBuilder = AlertBuilderImpl()
    var ascendingSorting = true
    var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        places = mainViewModel.fetchData(metod: .currentPlaces)
        setTableView()
        setSearchController()
    }

    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place = places[indexPath.row] 
            guard let newPlaceVC = segue.destination as? NewPlaceViewController else { return }
            newPlaceVC.currentPlace = place
        }
    }
    
    private func setSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func reversedSorting(_ sender: UIBarButtonItem) {
        ascendingSorting.toggle()
        sorted()
        if !ascendingSorting {
            places.reverse()
            tableView.reloadData()
        }
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        ascendingSorting = true
        sorted()
    }
    
    private func sorted() {
        if segmentedControl.selectedSegmentIndex == 0 {
            places = mainViewModel.fetchData(metod: .filtredPlaces, filter: .date)
        } else {
            places = mainViewModel.fetchData(metod: .filtredPlaces, filter: .name)
        }
        tableView.reloadData()
    }
    
    // Действие, вызываемое при возврате из другого представления через unwind segue. Сохраняет новое место (если оно было добавлено) и обновляет таблицу.
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        newPlaceVC.savePlace()
        sorted()
        tableView.reloadData()
    }
}
