import SwiftUI

struct ProductDetailView: View {
    @State var cartItems: [CartItem] = []

    let productId: String
    
    func getProductDetails(for productId: String) -> Product? {
        return products.first { $0.id == productId }
    }

    private func addToCart(product: Product) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[index].quantity += 1
        } else {
            let newCartItem = CartItem(id: String(cartItems.count + 1), product: product, quantity: 1)
            cartItems.append(newCartItem)
        }
    }
    
    var body: some View {
        if let product = getProductDetails(for: productId) {
            VStack {
                AsyncImage(url: URL(string: product.image)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 350, height: 500)
                            } placeholder: {
                                // Placeholder while image is loading
                                ProgressView()
                            }
                
                Text(product.name)
                    .font(.title)
                    .padding(.bottom, 5)
                
                Text(product.description)
                    .font(.body)
                    .padding(.horizontal)
                
                Spacer()
                
                HStack {
                    Text("$\(product.price)")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Spacer()
        
                    Button(action: {
                        addToCart(product: product)
                    }) {
                        Text("Add to Cart")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle(product.name)
            .navigationBarItems(trailing: NavigationLink(destination: CartView()) {
                Image(systemName: "cart")
            })
        } else {
            Text("Product not found")
        }
    }
}

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(productId: "1")
    }
}
