import UIKit
import SnapKit

class PicInPicScreenView: UIView {
    private let bgView = UIView()
    private var lyricLine1 = UITextView()
    private var lyricLine2 = UITextView()
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
        backgroundColor = .black
        layer.cornerRadius = 8
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bgView)
        bgView.backgroundColor = .black
        bgView.translatesAutoresizingMaskIntoConstraints = false
        
        bgView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        lyricLine1.backgroundColor = .black
        lyricLine1.textColor = .white
        lyricLine1.font = UIFont(name: "Hiragino Sans", size: 18)
        bgView.addSubview(lyricLine1)
        
        lyricLine2.backgroundColor = .black
        lyricLine2.textColor = .white
        lyricLine2.font = UIFont(name: "Hiragino Sans", size: 18)
        bgView.addSubview(lyricLine2)
        
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
    }
}
