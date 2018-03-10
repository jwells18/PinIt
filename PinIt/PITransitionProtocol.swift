//
//  PITransitionProtocol.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/19/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import Foundation
import UIKit

@objc protocol PITransitionProtocol{
    func transitionCollectionView() -> UICollectionView!
}

@objc protocol PITansitionWaterfallGridViewProtocol{
    func snapShotForTransition() -> UIView!
}

@objc protocol PIWaterFallViewControllerProtocol : PITransitionProtocol{
    func viewWillAppearWithPageIndex(_ pageIndex : NSInteger)
}

@objc protocol PIPinDetailControllerProtocol : PITransitionProtocol{
    func pageViewCellScrollViewContentOffset() -> CGPoint
}
