# 🎟️ Eventify — Event Booking & Ticket Management

Eventify is a Flutter application for browsing events, booking seats, managing reservations, and validating digital tickets. It uses a local SQLite database to store event and booking information.

## ✨ Features

* **Event Discovery:** Browse available events and view event details.
* **Search & Filtering:** Search events, filter by category, and sort results.
* **Seat Selection:** Select available seats for an event.
* **Booking Management:** Create bookings and generate unique booking references.
* **Discount Calculation:** Apply a 10% discount when the booking total is ₹2,000 or more.
* **Digital Tickets:** View booking details and QR codes.
* **Ticket Validation:** Validate booking references and check ticket status.
* **Check-In:** Mark confirmed tickets as checked in and prevent repeat check-ins.
* **Booking History:** View previous bookings.
* **Cancellation:** Cancel eligible bookings up to two hours before the event and release reserved seats.
* **Local Storage:** Store event, seat, booking, and favourite data in SQLite.

## 🛠️ Technologies Used

* Flutter
* Dart
* GetX — State management and navigation
* SQLite
* sqflite — Local database operations
* UUID — Booking reference generation

## 🏗️ Architecture

The project separates responsibilities into feature screens, controllers, models, repositories, and database management.

```text
lib/
├── data/
│   ├── database/
│   └── repositories/
├── features/
│   ├── events/
│   ├── bookings/
│   └── tickets/
└── routes/
```

## 🚀 Getting Started

### Prerequisites

* Flutter SDK
* Dart SDK
* Android Studio or VS Code
* An Android emulator or physical device

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/munawir7/eventify-flutter.git
   ```

2. Navigate to the project directory:

   ```bash
   cd eventify-flutter
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the application:

   ```bash
   flutter run
   ```

## 🗄️ Database

Eventify uses SQLite for local data persistence. Its database includes tables for events, seats, bookings, booking-seat relationships, and favourites.

The core booking operations work locally without requiring a remote backend API.

## 🧪 Code Analysis

Run Flutter's static analyzer with:

```bash
flutter analyze
```

## 📌 Project Limitations

* Booking data is stored locally on the device.
* Bookings are not synchronized between devices.
* The project does not currently provide centralized server-side booking validation or payment processing.

## 👨‍💻 Developer

Developed as a Flutter learning and development project.
