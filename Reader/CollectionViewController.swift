//
//  CollectionViewController.swift
//  Reader
//
//  Created by Niket Shah on 30/05/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Cocoa
import JNWCollectionView

class CollectionViewController: NSViewController, JNWCollectionViewDataSource, JNWCollectionViewDelegate, JNWCollectionViewListLayoutDelegate {
	
	var collectionView: JNWCollectionView = JNWCollectionView()
	
	weak var document: Document? {
		didSet {
			if document == nil { return }
			
			if let newFigures = document?.content?.figures {
				figures = newFigures
			}
			self.collectionView.reloadData()
		}
	}
	
	private var figures: [Figure] = []
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		collectionView = JNWCollectionView(frame: view.bounds)
		collectionView.dataSource = self;
		collectionView.backgroundColor = NSColor.redColor()
		collectionView.delegate = self
		collectionView.autoresizingMask = .ViewHeightSizable
		let collectionViewLayout = JNWCollectionViewListLayout(collectionView: collectionView)
		collectionViewLayout.delegate = self
		collectionViewLayout.rowHeight = 116
		collectionView.collectionViewLayout = collectionViewLayout
		collectionView.registerClass(FigureCollectionCell.self, forCellWithReuseIdentifier: "cell")
		let nib = NSNib(nibNamed: "FigureCollectionCell", bundle: nil)
		collectionView.registerNib(nib, forCellWithReuseIdentifier: "cell")
		collectionView.animatesSelection = true
		view.addSubview(collectionView)
    }
	
	func collectionView(collectionView: JNWCollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> JNWCollectionViewCell! {
		if let cell : FigureCollectionCell = collectionView.dequeueReusableCellWithIdentifier("cell") as? FigureCollectionCell {
			let row = indexPath.jnw_item
			cell.figure = figures[row]
			return cell
		}
		return FigureCollectionCell()
	}
	
	func collectionView(collectionView: JNWCollectionView!, numberOfItemsInSection section: Int) -> UInt {
		println("count: \(figures.count)")
		return UInt(figures.count)
	}
	
	func collectionView(collectionView: JNWCollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
		println("I clicked \(indexPath.jnw_item)")
		if let splitViewController = self.parentViewController as? NSSplitViewController {
			let splitItems = splitViewController.splitViewItems
			if let splitItem = splitItems[1] as? NSSplitViewItem,
				detailViewController = splitItem.viewController as? CollectionViewDetailViewController {
				detailViewController.svg = figures[indexPath.jnw_item].svg
			}
		}
	}
    
}
