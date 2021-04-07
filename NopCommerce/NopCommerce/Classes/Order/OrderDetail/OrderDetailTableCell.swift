//
//  OrderDetailTableCell.swift
//  NopCommerce
//
//  Created by Jayesh on 10/03/20.
//  Copyright © 2020 Chirag Patel. All rights reserved.
//

import UIKit

class OrderDetailTableCell: ConstrainedTableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var lblOrderTotal: UILabel!
    @IBOutlet weak var lblOrderDiscount: UILabel!
    @IBOutlet weak var lblOrderSubTotal: UILabel!
    @IBOutlet weak var lblOrderTax: UILabel!
    @IBOutlet weak var lblOrderDelivery: UILabel!
    @IBOutlet weak var lblOrderEarn: UILabel!
    @IBOutlet weak var lblOrderPayable: UILabel!
    
    @IBOutlet weak var lblOrderTotalTitle: UILabel!
    @IBOutlet weak var lblOrderTaxTitle: UILabel!
    @IBOutlet weak var lblOrderSubTotalTitle: UILabel!
    @IBOutlet weak var lblOrderDeliveryTitle: UILabel!
    @IBOutlet weak var lblOrderEarnTitle: UILabel!
    @IBOutlet weak var lblOrderPayableTitle: UILabel!
    @IBOutlet weak var lblCoupanDiscountTitle: UILabel!
    
    @IBOutlet weak var btnReOrder: UIButton!
    @IBOutlet weak var btnReturnItem: UIButton!
    
    weak var parent: OrderDetailVC!
    weak var parentCheckOut: CheckOutVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func preparePaymentSumary(data: OrderDetail) {
        lblOrderTotalTitle.text = getLocalizedKey(str: "checkout.placedorderdetails")
        lblOrderSubTotalTitle.text = getLocalizedKey(str: "messages.order.subtotal")
        lblOrderTaxTitle.text = getLocalizedKey(str: "messages.order.tax")
        lblOrderDeliveryTitle.text = "Delivery"
        lblOrderEarnTitle.text = getLocalizedKey(str: "shoppingcart.totals.rewardpoints.willearn")
        lblOrderPayableTitle.text = "Total Payable"
        lblCoupanDiscountTitle.text = "Coupan Discount"//getLocalizedKey(str: "")
        
        lblOrderTotal.text = data.orderTotal
        lblOrderDiscount.text = data.orderDiscount.isEmpty ? "0.00" : data.orderDiscount
        lblOrderSubTotal.text = data.subTotal
        lblOrderTax.text = data.tax
        lblOrderDelivery.text = data.delivery
        lblOrderEarn.text = "\(data.earnPoints) \(getLocalizedKey(str: "rewardpoints.fields.points"))"
        lblOrderPayable.text = data.orderTotal
    }
    
    func prepareCheckOutSumary(data: OrderTotalDetail) {
        lblOrderTotalTitle.text = getLocalizedKey(str: "checkout.placedorderdetails")
        lblOrderSubTotalTitle.text = getLocalizedKey(str: "messages.order.subtotal")
        lblOrderTaxTitle.text = getLocalizedKey(str: "messages.order.tax")
        lblOrderDeliveryTitle.text = "Delivery"
        lblOrderEarnTitle.text = getLocalizedKey(str: "shoppingcart.totals.rewardpoints.willearn")
        lblOrderPayableTitle.text = "Total Payable"
        lblCoupanDiscountTitle.text = "Coupan Discount"//getLocalizedKey(str: "")

        lblOrderTotal.text = data.orderTotal
        lblOrderDiscount.text = data.discount.isEmpty ? "0.00" : data.discount
        lblOrderSubTotal.text = data.orderSubTotal
        lblOrderTax.text = data.tax
        lblOrderDelivery.text = data.shipping
        lblOrderEarn.text = "0.00 \(getLocalizedKey(str: "rewardpoints.fields.points"))"
        lblOrderPayable.text = data.orderTotal
    }
    
    func prepareOrderDetailUI(idx: Int) {
        if idx == 2 {
            prepareButtonUI()
        } else if idx == 3 {
            collectionView.reloadData()
        } else {
            preparePaymentSumary(data: parent.orderDetail)
        }
    }
    
    func prepareButtonUI() {
        btnReOrder.setTitle(getLocalizedKey(str: "order.reorder"), for: .normal)
        btnReturnItem.setTitle(getLocalizedKey(str: "order.returnitems"), for: .normal)
        btnReOrder.isHidden = !parent.orderDetail.isReOrderAllowed
        btnReturnItem.isHidden = !parent.orderDetail.isReturnRequestAllowed
    }
}

extension OrderDetailTableCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: OrderDetailCollCell
        let cellId = indexPath.row % 2 == 0 ? "cell" : "peymentCell"
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! OrderDetailCollCell
        if cellId.isEqual(str: "cell") {
            let address: Address
            if parentCheckOut == nil {
                 address = (indexPath.row == 0 ? parent.orderDetail.billingAddress : parent.orderDetail.shippingAddress)!
            } else {
                address = (indexPath.row == 0 ? parentCheckOut.objConfirmOrder.billingAddress : parentCheckOut.objConfirmOrder.shippingAddress)!
            }
            cell.prepareAddressUI(data: address, index: indexPath.row)
        } else {
            if parentCheckOut == nil {
                cell.paymentShippingUI(data: parent.orderDetail, index: indexPath.row)
            } else {
                cell.paymentShippingUI(data: parentCheckOut.objConfirmOrder.orderDetail!, index: indexPath.row)
            }
        }
        return cell
    }
    
}

extension OrderDetailTableCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width - 1
        var height: CGFloat = 0
        if parentCheckOut == nil {
            height = parent.orderDetail.billingAddress!.getAddressHeight()
        } else {
            height = parentCheckOut.objConfirmOrder.billingAddress!.getAddressHeight()
        }
        return CGSize(width: width / 2, height: height)
    }
}

class OrderDetailCollCell: ConstrainedCollectionViewCell {
    
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblFormatAddress: UILabel!
    
    @IBOutlet weak var lblmethodTitle: UILabel!
    @IBOutlet weak var lblStatusTitle: UILabel!
    
    @IBOutlet weak var lblmethod: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    
    func prepareAddressUI(data: Address, index: Int) {
        lblHeader.text = index == 0 ? getLocalizedKey(str: "order.billingaddress") : getLocalizedKey(str: "order.shippingaddress")
        lblName.text = data.fullName
        lblFormatAddress.text = data.formattedAdress
    }
    
    func paymentShippingUI(data: OrderDetail, index: Int) {
        lblHeader.text = index == 1 ? getLocalizedKey(str: "order.payment") : getLocalizedKey(str: "order.shipping")
        lblmethodTitle.text = index == 1 ? getLocalizedKey(str: "order.payment.method") : getLocalizedKey(str: "order.shipments.shippingmethod")
        lblStatusTitle.text = index == 1 ? getLocalizedKey(str: "order.payment.status") : getLocalizedKey(str: "order.shipping.status")
        lblmethod.text = index == 1 ? data.paymentMethod : data.shippingMethod
        lblStatus.text = index == 1 ? data.paymentMethodStatus : data.shippingMethodStatus
    }
}
