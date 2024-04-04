import SwiftUI
import Foundation

struct Product: Identifiable , Codable {
    let id: String
    let name: String
    let category: String
    let description: String
    let price: Double
    let image: String
}

struct ProductListView: View {
    @State private var searchText: String = ""
    @State private var selectedCategory: String = "All"
    @State private var sortOrder: SortOrder = .name
    @State private var showFilterSheet = false
    @State private var showProfile = false
    
    var sortedProducts: [Product] {
        switch sortOrder {
        case .name:
            return products.sorted { $0.name < $1.name }
        case .price:
            return products.sorted { $0.price < $1.price }
        }
    }
    
    var filteredProducts: [Product] {
        let filtered = sortedProducts.filter { $0.category == selectedCategory || selectedCategory == "All" }
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    func fetchProducts() {
        guard let url = URL(string: "http://localhost:8080/product/") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("No data received:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(ProductResponse.self, from: data)
                DispatchQueue.main.async {
                    print("Fetched data:", result.data)
                }
                
            } catch {
                print("Error decoding JSON:", error)
            }
        }.resume()
    }
    
    var body: some View {
        NavigationView {
            List {
                SearchBar(searchText: $searchText)
                
                ForEach(filteredProducts) { product in
                    NavigationLink(destination: ProductDetailView(productId: product.id)) {
                        ProductRow(product: product)
                    }
                }
            }
            .navigationTitle("Clothify")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showProfile.toggle()
                    }) {
                        Image(systemName: "person.circle")
                    }
                    .sheet(isPresented: $showProfile) {
                        ProfileView()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            showFilterSheet.toggle()
                        }) {
                            Image(systemName: "slider.horizontal.3")
                        }
                        
                        NavigationLink(destination: CartView()) {
                            Image(systemName: "cart")
                        }
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterView(selectedCategory: $selectedCategory, sortOrder: $sortOrder)
            }
            .onAppear {
            }
        }
    }
    
    struct ProductRow: View {
        let product: Product
        
        var body: some View {
            HStack(spacing: 10) {
                AsyncImage(url: URL(string: product.image)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                } placeholder: {
                    // Placeholder while image is loading
                    ProgressView()
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(product.name)
                        .font(.headline)
                    Text(product.description)
                        .font(.subheadline)
                    Text("$\(product.price)")
                        .font(.subheadline)
                }
                
            }
            .padding(.vertical, 5)
        }
    }
    
    struct FilterView: View {
        @Binding var selectedCategory: String
        @Binding var sortOrder: SortOrder
        
        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Filter by Category")) {
                        Picker("Category", selection: $selectedCategory) {
                            Text("All").tag("All")
                            Text("Clothing").tag("Clothing")
                            Text("Footwear").tag("Footwear")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Section(header: Text("Sort Order")) {
                        Picker("Sort Order", selection: $sortOrder) {
                            Text("Name").tag(SortOrder.name)
                            Text("Price").tag(SortOrder.price)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                .navigationTitle("Filter & Sort")
                .navigationBarItems(trailing:
                                        Button("Done") {
                
                }
                )
            }
        }
    }
    
    enum SortOrder {
        case name
        case price
    }
    
    struct ProductResponse: Codable {
        let data: Product
        let statusCode: Int
        let success: Bool
        let message: String
        
        enum CodingKeys: String, CodingKey {
            case data
            case statusCode
            case success
            case message
        }
        
    }
    
    struct ProductListView_Previews: PreviewProvider {
        static var previews: some View {
            ProductListView()
        }
    }
    
}

let products = [
    Product(id: "1", name: "T-Shirt", category: "Clothing", description: "Comfortable cotton t-shirt", price: 19.99, image: "https://burst.shopifycdn.com/photos/clothes-on-a-rack-in-a-clothing-store.jpg?width=1000&format=pjpg&exif=0&iptc=0"),
    Product(id: "2", name: "Sweater", category: "Clothing", description: "Warm woolen sweater", price: 29.99, image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2rbysGxaCcR9rScfaQF3feQbbXj3JbluhuN0pPDU8ym3y-H_NLtgxCAEwEeFuAeEv850&usqp=CAU"),
    Product(id: "3", name: "Jeans", category: "Clothing", description: "Stylish denim jeans", price: 39.99, image: "https://cdn.mitchellstores.com/rails/active_storage/representations/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBemowREE9PSIsImV4cCI6bnVsbCwicHVyIjoiYmxvYl9pZCJ9fQ==--d64f9249a47b9dfad756948c67f9c6269715a504/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdDam9MWm05eWJXRjBTU0lJYW5CbkJqb0dSVlE2QzNKbGMybDZaVWtpRHpJNE1EQjROREl3TUQ0R093WlVPZ3B6ZEhKcGNGUTZFR0YxZEc4dGIzSnBaVzUwVkRvTWNYVmhiR2wwZVVraUNEYzFKUVk3QmxRPSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--2194f4ba90266e988b82b869a61bc64b50c6873c/uploading-1292910-jpg20210416-4-dny14r.jpg"),
    Product(id: "4", name: "Dress", category: "Clothing", description: "Elegant evening dress", price: 49.99, image: "https://media.istockphoto.com/id/137198526/photo/purple-dress.jpg?s=170667a&w=0&k=20&c=GdpmWNHJYW-vNMFtnn2UD68I_Xa37voKHJ7lvGgFx5I="),
    Product(id: "5", name: "Running Shoes", category: "Footwear", description: "Lightweight running shoes", price: 59.99, image: "https://productimage001.snowandrock.com/productimages/316x474/l2114415_4010_b.jpg"),
    Product(id: "6", name: "Backpack", category: "Accessories", description: "Durable backpack for everyday use", price: 79.99, image: "https://static-01.daraz.lk/p/b20ece1a5c026d242a0d07d6bb9fbe70.jpg")
]
