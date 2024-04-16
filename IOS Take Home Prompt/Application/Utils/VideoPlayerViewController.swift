//
//  VideoPlayerViewController.swift
//  IOS Take Home Prompt
//
//  Created by Danilo Oliveira on 16/04/24.
//

import UIKit
import AVFoundation

class VideoPlayerViewController: UIViewController {
    var video: VideoModel?
    var pageIndex: Int?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?

    private let heartLeftImageView = UIImageView(image: UIImage(systemName: "heart.fill"))

    private var heartRightImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "heart"))
        imageView.tintColor = .white
        imageView.alpha = 0.0
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let counterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()

    private var counter: Int = 0 {
        didSet {
            counterLabel.text = "\(counter)"
        }
    }

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeartImageView(heartLeftImageView, at: .left)
        setupRightHeartImageView()
        setupCounterLabel()
        setupPlayer()
        setupProfileUI()
        setupGestureRecognizers()
    }

    private func setupRightHeartImageView() {
        heartRightImageView.tintColor = .white
        heartRightImageView.alpha = 1
        heartRightImageView.contentMode = .scaleAspectFit
        heartRightImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(heartRightImageView)

        NSLayoutConstraint.activate([
            heartRightImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            heartRightImageView.widthAnchor.constraint(equalToConstant: 50),
            heartRightImageView.heightAnchor.constraint(equalToConstant: 50),
            heartRightImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleRightHeartTap(_:)))
        heartRightImageView.isUserInteractionEnabled = true
        heartRightImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    private func setupCounterLabel() {
        counterLabel.textColor = .white
        counterLabel.textAlignment = .center
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(counterLabel)

        NSLayoutConstraint.activate([
            counterLabel.topAnchor.constraint(equalTo: heartRightImageView.bottomAnchor, constant: 10),
            counterLabel.centerXAnchor.constraint(equalTo: heartRightImageView.centerXAnchor),
            counterLabel.widthAnchor.constraint(equalToConstant: 50),
            counterLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    @objc private func handleRightHeartTap(_ gesture: UITapGestureRecognizer) {
        guard let heartImageView = gesture.view as? UIImageView else { return }
        heartImageView.image = UIImage(systemName: "heart.fill")
        heartImageView.tintColor = .red

        UIView.animate(withDuration: 0.5, animations: {
            heartImageView.alpha = 0.0
        }) { _ in
            heartImageView.alpha = 1.0
        }
        counter += 1
    }

    private func setupHeartImageView(_ imageView: UIImageView, at position: HeartPosition) {
        imageView.tintColor = position == .left ? .red : .white
        imageView.alpha = 0
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50)
        ])

        if position == .left {
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        } else {
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        }

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleHeartTap(_:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func handleHeartTap(_ gesture: UITapGestureRecognizer) {
        guard let heartImageView = gesture.view as? UIImageView else { return }
        heartImageView.tintColor = .red
    }

    private func setupGestureRecognizers() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        let progress = abs(translation.x) / view.bounds.width

        switch gesture.state {
        case .changed:
            if translation.x > 0, abs(translation.x) > abs(translation.y), velocity.x > 0 {
                let translationX = min(translation.x, 100)
                playerLayer?.setAffineTransform(CGAffineTransform(translationX: translationX, y: 0))
                if progress > 0.05 {
                    heartRightImageView.image = UIImage(systemName: "heart.fill")
                    heartRightImageView.tintColor = .red
                }
                showHeartAnimation()
            }
        case .ended, .cancelled:
            if translation.x < 0, abs(translation.x) > abs(translation.y), velocity.x < 0 {
                return
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.playerLayer?.setAffineTransform(.identity)
            })
            if let parentVC = self.parent as? UIPageViewController, abs(translation.x) < abs(translation.y) {
                parentVC.dataSource = parentVC as? UIPageViewControllerDataSource
            }
            if gesture.state == .ended {
                counter += 1
            }

        default: break
        }
    }

    private func setupProfileUI() {
        view.addSubview(profileImageView)
        view.addSubview(bodyLabel)

        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false

        // Constraints
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),

            bodyLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            bodyLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            bodyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10)
        ])
    }

    private func setupPlayer() {
        guard let videoURLString = video?.compressedForIosUrl, let url = URL(string: videoURLString) else {
            print("Invalid video URL")
            return
        }

        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = view.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer!)
        view.bringSubviewToFront(profileImageView)
        view.bringSubviewToFront(bodyLabel)
        view.bringSubviewToFront(heartRightImageView)
        view.bringSubviewToFront(counterLabel)

        player?.play()
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        updateUI()
    }


    @objc func playerItemDidReachEnd(notification: Notification) {
        player?.seek(to: .zero)
        player?.play()
    }

    private func updateUI() {
        if let video = video {
            bodyLabel.text = video.body
            if let imageUrl = URL(string: video.profilePictureUrl) {
                loadImage(from: imageUrl)
            }
        }
    }

    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.profileImageView.image = image
            }
        }.resume()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func showHeartAnimation() {
        let heartImageView = UIImageView(image: UIImage(systemName: "heart.fill"))
        heartImageView.tintColor = .red
        heartImageView.alpha = 0
        heartImageView.contentMode = .scaleAspectFit
        heartImageView.frame = CGRect(x: -10, y: view.center.y - 25, width: 50, height: 50)

        view.addSubview(heartImageView)
        UIView.animate(withDuration: 0.5, animations: {
            heartImageView.alpha = 1.0
            heartImageView.frame.origin.x = 25
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
                heartImageView.alpha = 0
            }, completion: { _ in
                heartImageView.removeFromSuperview()
            })
        })
    }
}

extension VideoPlayerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        let translation = panGestureRecognizer.translation(in: view)
        return abs(translation.x) > abs(translation.y)
    }
}

enum HeartPosition {
    case left, right
}
