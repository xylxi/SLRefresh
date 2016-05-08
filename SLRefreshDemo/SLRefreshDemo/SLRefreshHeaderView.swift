//
//  SLRefreshHeaderView.swift
//  SLRefreshDemo
//
//  Created by WangZHW on 16/5/8.
//  Copyright © 2016年 RobuSoft. All rights reserved.
//

import UIKit

public typealias RefreshingBlock = ()->()

enum RefreshState {
    case Normal // 默认状态
    case Pulling // 松手就可以刷新
    case Refreshing //正在刷新的
}

class RefreshHeaderView: UIView {
    private let headerView: HeaderView
    private let distance: CGFloat
    weak var scrollView: UIScrollView!
    init(scrollView: UIScrollView, haveNav: Bool = false) {
        self.scrollView   = scrollView
        if haveNav {
            self.offset = 64
        }else {
            self.offset = 0
        }
        self.distance     = 64
        let frame = CGRectMake(0, 0, scrollView.bounds.width, 64)
        headerView = HeaderView(frame: frame, progressText: "Great pain shapes Legend", gradientText: "Great pain shapes Legend")
        super.init(frame: CGRectMake(0, -64, scrollView.bounds.width, 64))
        self.scrollView.insertSubview(self, atIndex: 0)
        self.addSubview(headerView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // tableView的contentInset
    private var offset:CGFloat
    private var progress: CGFloat! = 0.0 {
        didSet {
            self.headerView.progress(progress)
        }
    }
    
    private var oldState: RefreshState = .Normal
    private var state: RefreshState = .Pulling {
        didSet {
            switch state {
            case .Normal:
                if oldState == .Refreshing {
                    UIView.animateWithDuration(0.25, animations: {
                        var contentInset = self.scrollView!.contentInset
                        contentInset.top -= self.distance
                        self.scrollView?.contentInset = contentInset
                        }, completion: { (finish) in
                        self.headerView.stop()
                    })
                }
                self.headerView.progress(progress)
            case .Pulling:
                self.headerView.progress(1.0)
            case .Refreshing:
                self.headerView.enterLoading()
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    var contentInset = self.scrollView!.contentInset
                    contentInset.top += self.distance
                    self.scrollView?.contentInset = contentInset
                })
                self.refreshClosure?()
            }
            oldState = state
        }
    }
    /// 结束刷新
    func endRefreshing(){
        self.state = .Normal
    }
    
    func starRefreshing() {
        self.state = .Refreshing
    }
 
    var refreshClosure:RefreshingBlock?
    
    private var addObserve = false
    override func didMoveToWindow() {
        if addObserve == false {
            scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.New, .Old], context: nil)
            self.addObserve = true
        }else {
            scrollView.removeObserver(self, forKeyPath: "contentOffset")
        }
    }
    deinit {
        print("\(self.dynamicType)")
    }
}

extension RefreshHeaderView {
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "contentOffset" {
            if let change = change {
                if let contentOffset = change[NSKeyValueChangeNewKey]?.CGPointValue {
                    if contentOffset.y + offset <= 0 {
                        progress = max(0.0, min(fabs(contentOffset.y+offset)/distance, 1.0))
                    }
                }
            }
            let dis = self.scrollView.contentOffset.y + self.offset + self.distance
            // 拖动
            if self.scrollView.dragging {
                if state == .Normal && dis < 0 {
                    // 松手就能刷新
                    state = .Pulling
                    print(dis)
                }else if state == .Pulling && dis > 0 {
                    // 松手不能刷新
                    state = .Normal
                }
            }else {
                if state == .Pulling {
                    state = .Refreshing
                }
            }
        }
    }
}




