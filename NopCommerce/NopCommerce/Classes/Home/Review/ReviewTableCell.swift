//
//  ReviewTableCell.swift
//  NopCommerce
//
//  Created by Chirag Patel on 23/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class ReviewTableCell: ConstrainedTableViewCell {
    
    @IBOutlet weak var lblProductReviewFor: UILabel!
    @IBOutlet weak var lblWriteYourReview: UILabel!
    @IBOutlet weak var lblProductTitle: UILabel!
    @IBOutlet weak var tfReviewTitle: UITextField!
    @IBOutlet weak var txtReviewView: UITextView!
    @IBOutlet weak var lblPlaceHolder: UILabel!
    
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblBad: UILabel!
    @IBOutlet weak var lblExcellent: UILabel!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var reviewView: FloatRatingView!
    
    weak var parent: ReviewVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureReviewUI(idx: IndexPath) {
        if idx.row == 0 {
            lblProductReviewFor.text = getLocalizedKey(str: "reviews.productreviewsfor")
            lblWriteYourReview.text = getLocalizedKey(str: "reviews.write")
            lblProductTitle.text = parent.proName
        } else if idx.row == 1 {
            tfReviewTitle.placeholder = getLocalizedKey(str: "reviews.fields.title")
            tfReviewTitle.text = parent.data.title
        } else if idx.row == 2 {
            lblPlaceHolder.text = getLocalizedKey(str: "reviews.fields.reviewtext")
            txtReviewView.text = parent.data.text
            lblPlaceHolder.isHidden = !parent.data.text.isEmpty
        } else if idx.row == 3 {
            lblRating.text = getLocalizedKey(str: "reviews.fields.rating")
            lblBad.text = getLocalizedKey(str: "reviews.fields.rating.bad")
            lblExcellent.text = getLocalizedKey(str: "reviews.fields.rating.excellent")
            reviewView.delegate = self
            reviewView.rating = parent.data.rating.doubleValue ?? 0
        } else {
            btnSubmit.setTitle(getLocalizedKey(str: "reviews.submitbutton"), for: .normal)
        }
    }
}

extension ReviewTableCell: FloatRatingViewDelegate {
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        parent.data.rating = "\(rating.intValue ?? 4)"
    }
}

extension ReviewTableCell: UITextFieldDelegate {
    
    @IBAction func tfEditingChange(_ textField: UITextField) {
        let str = textField.text!.trimmedString()
        parent.data.title = str
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension ReviewTableCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let str = textView.text.trimmedString()
        parent.data.text = str
        lblPlaceHolder.isHidden = !parent.data.text.isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        parent.tableView.scrollToRow(at: IndexPath(row: 2, section: 0), at: .top, animated: true)
    }
}
