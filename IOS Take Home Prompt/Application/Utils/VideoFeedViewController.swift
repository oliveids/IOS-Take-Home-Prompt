//
//  VideoFeedViewController.swift
//  IOS Take Home Prompt
//
//  Created by Danilo Oliveira on 16/04/24.
//

import UIKit
import AVFoundation

class VideoFeedViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var videos: [VideoModel] = []
    var currentIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self

        videos = DataManager.loadVideos()
        if let firstViewController = videoViewController(for: 0) {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }

    private func videoViewController(for index: Int) -> VideoPlayerViewController? {
        if index >= 0 && index < videos.count {
            let videoVC = VideoPlayerViewController()
            videoVC.video = videos[index]
            videoVC.pageIndex = index
            return videoVC
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? VideoPlayerViewController, let index = vc.pageIndex, index > 0 else {
            return nil
        }
        return videoViewController(for: index - 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? VideoPlayerViewController, let index = vc.pageIndex, index < videos.count - 1 else {
            return nil
        }
        return videoViewController(for: index + 1)
    }
}

