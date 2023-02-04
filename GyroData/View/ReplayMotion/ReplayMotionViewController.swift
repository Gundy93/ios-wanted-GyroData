//
//  ReplayMotionViewController.swift
//  GyroData
//
//  Created by Aaron, Gundy on 2023/01/31.
//

import UIKit

class ReplayMotionViewController: UIViewController {

    private var replayMotionViewModel: ReplayMotionViewModel?
    var timer: Timer!
    var watchStatus: WatchStatus = .start
    var replayTime: Double!
    var playingTime = 0.0

    init(replayMotionViewModel: ReplayMotionViewModel?) {
        self.replayMotionViewModel = replayMotionViewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let dateLabel: UILabel = {
        let label = UILabel()

        label.text = "test date"
        return label
    }()

    let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.text = "test type"
        return label
    }()

    private let xValueLabel: UILabel = {
        let label = UILabel()
        label.text = "x: 0"
        label.textColor = .red
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textAlignment = .left

        return label
    }()

    private let yValueLabel: UILabel = {
        let label = UILabel()
        label.text = "y: 0"
        label.textColor = .green
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textAlignment = .center

        return label
    }()

    private let zValueLabel: UILabel = {
        let label = UILabel()
        label.text = "z: 0"
        label.textColor = .blue
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textAlignment = .right

        return label
    }()

    private lazy var valueLabelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [xValueLabel,
                                                       yValueLabel,
                                                       zValueLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing

        return stackView
    }()

    var graphView: GraphView = {
        let view = GraphView()

        return view
    }()

    let playButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(didTappedStartButton), for: .touchUpInside)

        let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large)
        let largeBoldDoc = UIImage(systemName: "play.fill", withConfiguration: largeConfig)

        btn.setImage(largeBoldDoc, for: .normal)
        btn.tintColor = .black

        return btn
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00.0"
        label.font = .preferredFont(forTextStyle: .title1)
        return label
    }()

    lazy var containerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dateLabel, typeLabel, graphView])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        configureUI()
    }

    // MARK: - setUp UI
    func configureUI() {
        configureHierarchy()
        configureLayout()
        configureNavigation()
        configureGraphView()
        configureViewModel()
        setUpUIData()
    }

    func configureHierarchy() {
        view.addSubview(containerStackView)
        view.addSubview(valueLabelStackView)
        view.addSubview(playButton)
        view.addSubview(timeLabel)
    }

    func configureLayout() {
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.heightAnchor.constraint(equalToConstant: 16),

            typeLabel.heightAnchor.constraint(equalToConstant: 36),
            typeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),

            valueLabelStackView.topAnchor.constraint(equalTo: graphView.topAnchor, constant: 4),
            valueLabelStackView.leadingAnchor.constraint(equalTo: containerStackView.leadingAnchor, constant: 16),
            valueLabelStackView.trailingAnchor.constraint(equalTo: containerStackView.trailingAnchor, constant: -16),
            valueLabelStackView.heightAnchor.constraint(equalToConstant: 12),

            graphView.widthAnchor.constraint(equalTo: containerStackView.widthAnchor),
            graphView.heightAnchor.constraint(equalTo: graphView.widthAnchor, multiplier: 0.9),

            playButton.topAnchor.constraint(equalTo: containerStackView.bottomAnchor, constant: 36),
            playButton.leadingAnchor.constraint(equalTo: containerStackView.centerXAnchor, constant: -20),
            playButton.widthAnchor.constraint(equalToConstant: 40),

            timeLabel.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            timeLabel.topAnchor.constraint(equalTo: containerStackView.bottomAnchor, constant: 40),
            timeLabel.trailingAnchor.constraint(equalTo: containerStackView.trailingAnchor, constant: -16),

            containerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            containerStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            containerStackView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.5)
        ])
    }

    func configureNavigation() {
        navigationItem.title = "다시보기"

        let backBTN = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                      style: .plain,
                                      target: navigationController,
                                      action: #selector(UINavigationController.popViewController(animated:)))
        navigationItem.leftBarButtonItem = backBTN
        navigationItem.leftBarButtonItem?.tintColor = .black
    }

    func configureGraphView() {
        graphView.dataSource = replayMotionViewModel
    }

    private func configureViewModel() {
        replayMotionViewModel?.bindMotionData { [weak self] in
            self?.graphView.setNeedsDisplay()
            guard let currentValue = self?.replayMotionViewModel?.fetchCurrentValue() else {
                return
            }
            self?.xValueLabel.text = "x: " + currentValue.x
            self?.yValueLabel.text = "y: " + currentValue.y
            self?.zValueLabel.text = "z: " + currentValue.z
        }
    }

    // MARK: - binding Data
    func setUpUIData() {
        let cellData = replayMotionViewModel?.bindCellData()
        
        dateLabel.text = cellData?.0.date.description

        replayTime = cellData?.0.time
        typeLabel.text = cellData?.1.rawValue

        playButton.isHidden = cellData?.1 == .view
        timeLabel.isHidden = cellData?.1 == .view

    }
}
// MARK: - setUP Timer
extension ReplayMotionViewController {

    @objc
    func didTappedStartButton(_ sender: UIButton) {

        timeLabel.text = String(format: "%.1f", playingTime)

        switch self.watchStatus {
        case .start:
            self.watchStatus = .stop
            graphView.linePaths.forEach { $0.removeAllPoints() }
            graphView.linePaths = []
            replayMotionViewModel?.cleanGraph()

            self.timer = Timer.scheduledTimer(timeInterval: 0.1,
                                              target: self,
                                              selector: #selector(timeUp),
                                              userInfo: nil,
                                              repeats: true)

            let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .medium)
            let largeBoldDoc = UIImage(systemName: "stop.fill", withConfiguration: largeConfig)

            playButton.setImage(largeBoldDoc, for: .normal)

        case .stop:
            playingTime = 0
            self.watchStatus = .start
            timer?.invalidate()
            timer = nil

            let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .medium)
            let largeBoldDoc = UIImage(systemName: "play.fill", withConfiguration: largeConfig)

            playButton.setImage(largeBoldDoc, for: .normal)
        }

    }
    @objc
    private func timeUp() {
        playingTime += 0.1
        timeLabel.text = String(format: "%.1f", playingTime)

        if playingTime > replayTime {
            timer?.invalidate()
            timer = nil
        }

        replayMotionViewModel?.setUpMotionDataForDrawing(index: Int(playingTime*10))
    }
}

enum WatchStatus {
    case start
    case stop
}
