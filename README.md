# 🌍 Travel Connect - Multi-Role Tourism Platform


A modern Flutter application that connects **Travellers, Drivers, and Local Guides** on a single platform to create a seamless travel experience.

The platform provides transportation services, guide booking, AI-powered travel assistance, route planning, social interaction, and location-based travel support.

---

## 🚀 Features

### 👤 Authentication & User Management

* Role-based authentication
* Traveller registration and login
* Driver registration and login
* Guide registration and login
* Secure user session management

### 🧳 Traveller Features

* Discover local guides
* Book travel guides
* Search people and travel companions
* AI travel assistant
* Transport planning
* Ride booking
* Ride tracking
* Social travel feed
* Real-time chat

### 🚖 Driver Features

* Driver dashboard
* Manage vehicles
* Accept or reject ride requests
* Rental request management
* Ride tracking
* Payment history
* Earnings management

### 🗺️ Guide Features

* Create tour packages
* Manage travel packages
* Guide profile management
* Traveller communication
* Package listings
* Booking management

### 🤖 AI Travel Assistant

* Smart travel recommendations
* Travel planning support
* Destination guidance
* Route suggestions
* Trip assistance

### 📍 Location & Navigation

* Real-time location services
* Route planning
* Transport assistance
* Nearby travel support

### 💬 Communication

* Real-time messaging
* Guide-to-traveller chat
* Travel discussions
* Social interaction features

---

## 🏗️ Architecture

This project follows a Feature-First Clean Architecture approach.

```text
lib/
├── app/
├── core/
├── features/
│   ├── auth/
│   ├── traveller/
│   ├── driver/
│   └── guide/
└── shared/
```

### Layers

#### Presentation Layer

* Screens
* Widgets
* GetX Controllers

#### Domain Layer

* Entities
* Repository Contracts
* Use Cases

#### Data Layer

* Models
* Repositories
* Data Sources

---

## 🛠️ Tech Stack

### Frontend

* Flutter
* Dart

### State Management

* GetX

### Backend Services

* Firebase Authentication
* Cloud Firestore
* Firebase Storage

### APIs & Services

* Google Maps
* Location Services
* AI Integration
* Payment Gateway Integration

### Architecture

* Feature First Architecture
* Clean Architecture Principles
* Dependency Injection
* Repository Pattern

---

## 📱 Supported Roles

| Role      | Features                                        |
| --------- | ----------------------------------------------- |
| Traveller | Guide Booking, Ride Booking, AI Assistant, Chat |
| Driver    | Ride Management, Vehicle Management             |
| Guide     | Package Creation, Traveller Support             |
| Admin     | Platform Monitoring & Management                |

---

## ⚙️ Installation

### Clone Repository

```bash
git clone https://github.com/gudhate-shravani/Smart-Travel-And-Booking-Application
```

### Navigate to Project

```bash
cd your-repository
```

### Install Dependencies

```bash
flutter pub get
```

### Run Project

```bash
flutter run
```

---

## 🔥 Firebase Configuration

Create and configure:

* Firebase Authentication
* Cloud Firestore
* Firebase Storage

Add:

```text
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

before running the application.

---

## 📂 Project Highlights

✔ Multi-role Architecture

✔ Clean Architecture

✔ GetX State Management

✔ Firebase Integration

✔ Scalable Folder Structure

✔ AI Integration

✔ Real-time Features

✔ Production Ready Codebase

---

## 📸 Screenshots

Add screenshots here after deployment.

```text
screenshots/
├── login.png
├── traveller_home.png
├── guide_dashboard.png
├── driver_dashboard.png
└── ai_assistant.png
```

---

## 🤝 Contributing

Contributions, suggestions, and improvements are welcome.

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push your branch
5. Create a Pull Request

---

## 📄 License

This project is intended for educational and portfolio purposes.

---

## 👩‍💻 Developer

Developed with Flutter, Firebase, and GetX.

Made for building a smarter and more connected travel ecosystem.

