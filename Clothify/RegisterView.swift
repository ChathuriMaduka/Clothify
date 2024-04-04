import SwiftUI

struct RegisterView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var registrationStatus: String = ""
    @State private var isRegistered: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
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
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()
            
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()
            
            Button(action: {
                performRegistration()
            }) {
                Text("Register")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitle("Register")
        .navigationViewStyle(StackNavigationViewStyle())
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: $isRegistered, content: {
            ProductListView()
        })
    }
    
    private func performRegistration() {
        guard validateInputs() else { return }
        
        // Perform API call
        guard let url = URL(string: "http://localhost:8080/user/") else {
            showErrorAlert(message: "Invalid URL")
            return
        }
        
        let parameters = ["email": email, "password": password]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            showErrorAlert(message: "Error serializing JSON data")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                showErrorAlert(message: "Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Parse response
            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    // Registration successful
                    registrationStatus = "Registration successful"
                    isRegistered = true
                } else {
                    // Registration failed
                    registrationStatus = "Registration failed: \(httpResponse.statusCode)"
                    showErrorAlert(message: registrationStatus)
                }
            }
        }.resume()
    }
    
    private func validateInputs() -> Bool {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            showErrorAlert(message: "Please fill in all fields")
            return false
        }
        
        guard password == confirmPassword else {
            showErrorAlert(message: "Passwords do not match")
            return false
        }
        
        return true
    }
    
    private func showErrorAlert(message: String) {
        errorMessage = message
        showErrorAlert = true
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
