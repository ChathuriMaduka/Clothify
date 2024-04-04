import SwiftUI

struct CartItem: Identifiable {
    let id: String
    let product: Product
    var quantity: Int
}

struct CartView: View {
    @State private var cartItems: [CartItem] = [

        CartItem(id: "1", product: Product(id: "1", name: "T-Shirt", category: "Clothing", description: "Clothing" ,  price: 19.99, image: "tshirt"), quantity: 2)
    ]

    var totalAmount: Double {
        cartItems.reduce(0) { $0 + Double($1.quantity) * $1.product.price }
    }
    
    var body: some View {
        VStack {
            if cartItems.isEmpty {
                Text("Your cart is empty")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(cartItems.indices, id: \.self) { index in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(cartItems[index].product.name)
                                    .font(.headline)
                                Text("$\(cartItems[index].product.price * Double(cartItems[index].quantity))")
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            HStack {
                                Button(action: {
                                    if cartItems[index].quantity > 1 {
                                        cartItems[index].quantity -= 1
                                    } else {
                                        cartItems.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "minus.circle")
                                        .font(.system(size: 20))
                                }
                                .foregroundColor(.blue)
                                
                                Text("\(cartItems[index].quantity)")
                                    .font(.headline)
                                
                                Button(action: {
                                    cartItems[index].quantity += 1
                                }) {
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: 20))
                                }
                                .foregroundColor(.blue)
                                
                                Button(action: {
                                    cartItems.remove(at: index)
                                }) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 20))
                                }
                                .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(InsetListStyle())
                .padding()
                
                Divider()
                
                HStack {
                    Text("Total:")
                        .font(.headline)
                    Spacer()
                    Text("$\(totalAmount, specifier: "%.2f")")
                        .font(.headline)
                }
                .padding()
                
                Button(action: {
                    // Add action for checkout
                }) {
                    Text("Checkout")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            
            Spacer()
        }
        .navigationTitle("Cart")
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
    }
}
