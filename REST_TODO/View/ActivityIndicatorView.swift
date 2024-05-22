//
//  ActivityIndicatorView.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/23/24.
//

import UIKit

struct ActivityIndicator {
    let viewForActivityIndicator = UIView()
    let backgroundView = UIView()
    let view: UIView
    let navigationController: UINavigationController?
    let tabBarController: UITabBarController?
    let activityIndicatorView = UIActivityIndicatorView()
    let loadingTextLabel = UILabel()

    var navigationBarHeight: CGFloat { return navigationController?.navigationBar.frame.size.height ?? 0.0 }
    var tabBarHeight: CGFloat { return tabBarController?.tabBar.frame.height ?? 0.0 }
}

extension ActivityIndicator {
    func showActivityIndicator(text: String) {
        viewForActivityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 100, height: 100)
        viewForActivityIndicator.center = CGPoint(x: view.frame.size.width / 2.0, y: (view.frame.size.height) / 2.0)
        viewForActivityIndicator.layer.cornerRadius = 10
        viewForActivityIndicator.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.598483033)
        backgroundView.addSubview(viewForActivityIndicator)

        activityIndicatorView.center = CGPoint(x: viewForActivityIndicator.frame.size.width / 2.0, y: (viewForActivityIndicator.frame.size.height) / 2.0 - 10)

        loadingTextLabel.textColor = UIColor.black
        loadingTextLabel.text = text
        loadingTextLabel.font = UIFont(name: "Avenir Light", size: 14)
        loadingTextLabel.sizeToFit()
        loadingTextLabel.center = CGPoint(x: activityIndicatorView.center.x, y: activityIndicatorView.center.y + 40)
        viewForActivityIndicator.addSubview(loadingTextLabel)

        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.style = UIActivityIndicatorView.Style.large
        activityIndicatorView.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        viewForActivityIndicator.addSubview(activityIndicatorView)

        backgroundView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        backgroundView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)

        view.addSubview(backgroundView)

        activityIndicatorView.startAnimating()
    }

    func stopActivityIndicator() {
        viewForActivityIndicator.removeFromSuperview()
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
        backgroundView.removeFromSuperview()
    }
}
