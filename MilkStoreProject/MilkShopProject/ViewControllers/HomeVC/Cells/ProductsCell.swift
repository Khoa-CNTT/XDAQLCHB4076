func configCell(products: DataMilkObject) {
    // ... các config khác ...
    
    // Load ảnh
    if let imageUrl = products.imgMilk {
        productImageView.loadImage(from: imageUrl)
    }
    
    // ... các config khác ...
} 