//
//  OrderHistoryVC.swift
//  Hamla
//
//  Created by Bassant on 19/03/2024.
//

import UIKit

enum orderState{
    case current
    case completed
    case canceled
}

class OrderHistoryVC: UIViewController {

    @IBOutlet weak var orderHistoryTable: UITableView!
    
    var selectedState: orderState = .current
    var orders:[Order] = []
    var viewModel: OrderHistoryViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        setupNavigationBar()
        self.title = "My-orders".localized
        
        orderHistoryTable.delegate = self
        orderHistoryTable.dataSource = self
        
        orderHistoryTable.register(UINib(nibName: "OrderHistoryCell", bundle: nil), forCellReuseIdentifier: "OrderHistoryCell")
        
        self.viewModel = OrderHistoryViewModel(api: OrderHistoryApi())
        viewModel?.myOrders(type: "current")
        bindData()
    }
    
    func bindData(){
        
        viewModel?.myOrdersResult.bind { result in
            guard let message = result?.message else { return }
            if result?.status == 0 {
                self.showAlert(message: message)
            }
            else {
                self.orders = (result?.data)!.reversed()
                DispatchQueue.main.async {
                    self.orderHistoryTable.reloadData()
                }
            }
            print(message)
        }

        
        viewModel?.errorMessage.bind{ error in
            if let error = error {
                self.showAlert(message: error)
                print(error)
            }
        }
        
    }

    
    @IBAction func segmentValueChanged(_ sender: CustomSegmentedControl) {
        resetTableView()
        switch sender.selectedSegmentIndex{
        case 0:
            selectedState = .current
            viewModel?.myOrders(type: "current")
        case 1:
            selectedState = .completed
            viewModel?.myOrders(type: "done")
        case 2:
            selectedState = .canceled
            viewModel?.myOrders(type: "cancel")
        default:
            selectedState = .current
        }
    }
    
    private func resetTableView(){
        self.orders = []
        self.orderHistoryTable.reloadData()
    }
    
}

extension OrderHistoryVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = orderHistoryTable.dequeueReusableCell(withIdentifier: "OrderHistoryCell", for: indexPath) as! OrderHistoryCell
        switch selectedState{
        case .current:
            cell.orderStateBtn.setTitle("On_way".localized, for: .normal)
            cell.orderStateBtn.setTitleColor(UIColor(named: "sunrise"), for: .normal)
            cell.orderStateBtn.backgroundColor = UIColor(named: "sunrise")?.withAlphaComponent(0.1)
        case .completed:
            cell.orderStateBtn.setTitle("Completed".localized, for: .normal)
            cell.orderStateBtn.setTitleColor(UIColor(named: "forest"), for: .normal)
            cell.orderStateBtn.backgroundColor = UIColor(named: "forest")?.withAlphaComponent(0.1)
        case .canceled:
            cell.orderStateBtn.setTitle("Canceled".localized, for: .normal)
            cell.orderStateBtn.setTitleColor(UIColor(named: "sunset"), for: .normal)
            cell.orderStateBtn.backgroundColor = UIColor(named: "sunset")?.withAlphaComponent(0.1)
        }
        cell.orderID.text = "#\(orders[indexPath.row].id ?? 0)"
        cell.cost.text = "\(orders[indexPath.row].cost ?? "") EGP"
        cell.pickupLocation.text = orders[indexPath.row].pickupLocationName
        cell.dropoffLocation.text = orders[indexPath.row].dropoffLocationName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = OrderDetailsVC(nibName: "OrderDetailsVC", bundle: nil)
        vc.orderDetails = self.orders[indexPath.row]
        if selectedState == .canceled {
            vc.orderStatus = .orderCanceled
        } else {
            vc.orderStatus = .orderConfirmed
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
