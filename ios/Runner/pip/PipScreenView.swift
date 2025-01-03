import UIKit
import SnapKit

class PipScreenView: UIView {
    private let bgView = UIView()
    private var lyricLine1 = UITextView()
    private var lyricLine2 = UITextView()
    private var noLyricLine = UITextView()
    private let gradientLayer = GradientLayer()
    private var icon = UIImageView(image: UIImage(named: "AppIcon"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        layer.cornerRadius = 8
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bgView)
        bgView.backgroundColor = .clear
        bgView.translatesAutoresizingMaskIntoConstraints = false
        
        bgView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        gradientLayer.createGradientView()
        layer.insertSublayer(gradientLayer, at: 0)
        
        lyricLine1.backgroundColor = .clear
        lyricLine1.textColor = .white
        lyricLine1.font = UIFont(name: "Hiragino Sans", size: 18)
        bgView.addSubview(lyricLine1)
        
        lyricLine2.backgroundColor = .clear
        lyricLine2.textColor = .white
        lyricLine2.font = UIFont(name: "Hiragino Sans", size: 18)
        bgView.addSubview(lyricLine2)
        
        noLyricLine.backgroundColor = .clear
        noLyricLine.textColor = .white
        noLyricLine.font = UIFont(name: "Hiragino Sans", size: 18)
        noLyricLine.textAlignment = .center
        noLyricLine.isHidden = true
        bgView.addSubview(noLyricLine)
        
        icon.contentMode = .scaleAspectFit
        bgView.addSubview(icon)
        
        lyricLine1.snp.makeConstraints { make in
            make.top.equalTo(bgView).offset(2)
            make.left.equalTo(bgView).offset(10)
            make.right.equalTo(bgView).offset(-10)
            make.height.equalTo(55)
        }
        
        lyricLine2.snp.makeConstraints { make in
            make.top.equalTo(lyricLine1.snp.bottom).offset(2)
            make.left.equalTo(bgView).offset(10)
            make.right.equalTo(bgView).offset(-10)
            make.height.equalTo(55)
        }
        
        noLyricLine.snp.makeConstraints { make in
            make.center.equalTo(bgView)
            make.left.equalTo(bgView)
            make.right.equalTo(bgView)
            make.height.equalTo(38)
        }
        
        icon.snp.makeConstraints { make in
            make.bottom.equalTo(bgView).offset(-10)
            make.trailing.equalTo(bgView).offset(-10)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
    }
    
    @objc func updateContent(lyricLine1: String?, lyricLine2: String?, currentLine: Int) {
        if lyricLine1 != nil {
            self.lyricLine1.text = lyricLine1
        }
        if lyricLine2 != nil {
            self.lyricLine2.text = lyricLine2
        }
        self.lyricLine1.textColor = currentLine == 2 ? UIColor.lightGray : UIColor.white
        self.lyricLine2.textColor = currentLine == 1 ? UIColor.lightGray : UIColor.white
        
        if currentLine == -1 {
            // 暂无歌词
            self.noLyricLine.text = lyricLine1
            self.lyricLine1.isHidden = true
            self.lyricLine2.isHidden = true
            self.noLyricLine.isHidden = false
        } else {
            self.lyricLine1.isHidden = false
            self.lyricLine2.isHidden = false
            self.noLyricLine.isHidden = true
        }
    }
    
    func updateGrandientColor(colors: [CGColor]) {
        gradientLayer.removeAnimation()
        gradientLayer.gradientSet.removeAll()
        gradientLayer.gradientSet.append(colors)
        gradientLayer.currentGradient = 0
        gradientLayer.colors = gradientLayer.gradientSet[gradientLayer.currentGradient]
        gradientLayer.animateGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: bounds.height
        )
        gradientLayer.animateGradient()
    }
}
