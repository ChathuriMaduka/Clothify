import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    
    @State private var isEmailValid: Bool = true
    @State private var isPasswordValid: Bool = true
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Image(systemName: "person.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)
                    .padding()
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isEmailValid ? Color.clear : Color.red, lineWidth: 1)
                    )
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isPasswordValid ? Color.clear : Color.red, lineWidth: 1)
                    )
                
                // Error message display
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                
                Button(action: {
                    login()
                }) {
                    Text("Sign In")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding()
                }
                .disabled(email.isEmpty || password.isEmpty)
                
                Spacer()
                
                NavigationLink(destination: RegisterView()) {
                    Text("Don't have an account? Sign Up")
                        .foregroundColor(.blue)
                }
                .padding()
                .navigationBarHidden(true)
            }
            .padding()
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $isLoggedIn, content: {
            ProductListView()
        })
    }
    
    func login() {
        // Input validation
        guard isValidEmail(email) else {
            isEmailValid = false
            errorMessage = "Invalid email format"
            return
        }
        
        guard isValidPassword(password) else {
            isPasswordValid = false
            errorMessage = "Password must be at least 8 characters long"
            return
        }
        
        // Reset error messages
        isEmailValid = true
        isPasswordValid = true
        errorMessage = ""
        
        guard let url = URL(string: "http://localhost:8080/user/login") else {
            print("Invalid URL")
            return
        }
        
        let parameters = ["email": email, "password": password]
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("No data in response: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let decodedResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                print("Token: \(decodedResponse.token)")
                print("Message: \(decodedResponse.message)")
                
                DispatchQueue.main.async {
                    isLoggedIn = true
                }
            } else {
                print("Failed to decode response from server")
            }
        }.resume()
    }
    
    // Function to validate email format
    func isValidEmail(_ email: String) -> Bool {
        // Basic email format validation
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // Function to validate password length
    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }

}

struct LoginResponse: Codable {
    let token: String
    let message: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
