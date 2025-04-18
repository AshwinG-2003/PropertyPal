# PropertyPal

**A Tenant Management App for Landlord Properties**  
<!-- Developed for CSCI 4100U - Mobile Devices -->

---

## 📱 Overview

PropertyPal is a mobile application designed to help landlords easily manage their properties, tenants, and rental-related tasks. The app incorporates multiple interactive features and integrates both local and cloud-based storage systems to deliver a seamless user experience.

---

## ✅ Implemented Functions

### 📂 Multiple Screens & Navigation
- Bottom navigation bar for seamless screen transitions.
- Dedicated tabs for Properties, Home, and Settings.

### 📅 Dialogues & Pickers
- Form-based property input with:
  - **Date Picker** for tenancy start date.
  - **Duration Picker** (in months).
- **Logout Confirmation Dialog** in Settings tab.

### 🍫 Snack Bars
- Sign-up confirmation.
- Welcome message on the Home screen.
- Password change confirmation.

### 🔔 Notifications
- Notification when a property is added.
- Rent reminder sent 5 days before the due date.

### 💾 Local Storage (SQLite + Firebase Auth)
- Firebase Authentication handles local login session storage.
- Auto-login maintained unless user logs out manually.

### ☁️ Cloud Storage (Firebase)
- User-input property data and login credentials stored securely in Firebase.
- Real-time access to properties associated with each user account.

### 🌐 HTTP Requests (Google Maps API)
- Auto-completion of property addresses using the Google Maps API.
- Relevant addresses fetched via HTTP requests and shown in a dropdown.

---

## 🗂️ File Reference
- Google Maps integration: `google_maps_api/network_utility.dart`

---

## 📸 Visual References
*(Referenced images in the prototype document include: navigation bar, forms, pickers, snack bars, notifications, and Firebase DB screenshots.)*

---

## 🔒 Authentication & Data Sync
PropertyPal ensures user data is safely synced with Firebase. Local sessions are maintained using Firebase Authentication for a smooth experience.

---

## 🚀 Future Work
- More robust tenant management.
- Rent collection tracking.
- In-app communication between landlord and tenant.
- UI/UX improvements and analytics.

---

## 🛠️ Tech Stack
- **Flutter** (Assumed for mobile UI)
- **Firebase** (Auth + Cloud Firestore)
- **SQLite** (for local persistence)
- **Google Maps API** (for address suggestions)

