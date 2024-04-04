import SwiftUI

struct ProfileView: View {
    @State private var isLoggedOut = false
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: "https://www.befunky.com/images/wp/wp-2021-01-linkedin-profile-picture-after.jpg?auto=avif,webp&format=jpg&width=944")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 250, height: 250)
                        } placeholder: {
                            // Placeholder while image is loading
                            ProgressView()
                        }
            Text("John Doe")
                .font(.title)
                .padding(.bottom, 10)
            
            Text("johndoe@example.com")
                .font(.headline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Button(action: {
                // Perform logout action here
                isLoggedOut = true
            }) {
                Text("Logout")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .navigationTitle("Profile")
        .fullScreenCover(isPresented: $isLoggedOut) {
            LoginView()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
