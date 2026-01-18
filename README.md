# 📱 PhoneWork

A **location-based labour hiring mobile application** built with Flutter. PhoneWork connects workers with nearby job opportunities, making it easy for work seekers to find reliable labour and for workers to discover jobs in their area.

---

## ✨ Features

### 👷 For Workers
- **Browse nearby jobs** - Find work opportunities based on your location
- **Apply to jobs** - Quick and easy job application process
- **Track applications** - Monitor the status of your applied jobs
- **Job history** - View completed jobs and earnings
- **KYC verification** - Build trust with verified identity

### 🏢 For Work Seekers (Employers)
- **Post jobs** - Create job listings with details and requirements
- **Find workers nearby** - Location-based matching to find workers in your area
- **Manage applications** - Review and accept worker applications
- **Job completion OTP** - Secure job completion verification

### 🤖 AI Assistant
- Built-in **AI chatbot** powered by Google Generative AI for assistance

---

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform mobile framework |
| **Dart** | Programming language |
| **AWS Amplify** | Backend services |
| **AWS Cognito** | Authentication |
| **Provider** | State management |
| **Google Generative AI** | AI chatbot integration |
| **Shared Preferences** | Local storage |

---

## 📁 Project Structure

```
lib/
├── core/              # Core utilities and constants
├── data/              # Data models and repositories
├── providers/         # State management (Provider)
├── screens/
│   ├── admin/         # Admin panel
│   ├── ai/            # AI chatbot
│   ├── auth/          # Authentication screens
│   ├── booking/       # Job bookings
│   ├── home/          # Home, categories, activity
│   ├── job/           # Job details and management
│   ├── kyc/           # KYC verification
│   ├── profile/       # User profile
│   └── worker/        # Worker-specific screens
├── services/          # API and external services
└── widgets/           # Reusable UI components
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.9.2)
- Dart SDK
- Android Studio / VS Code
- AWS Amplify CLI (for backend)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Manushanth1/PhoneWork.git
   cd PhoneWork
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Amplify** (if using backend)
   ```bash
   amplify init
   amplify push
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 📱 Screenshots

*Coming soon*

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Manushanth M**
- GitHub: [@Manushanth1](https://github.com/Manushanth1)
- Email: manushanth20@gmail.com

---

<p align="center">Made with ❤️ using Flutter</p>
