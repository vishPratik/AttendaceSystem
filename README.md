# MarkMe - Smart Digital Attendance System

![App Logo](https://github.com/vishPratik/AttendaceSystem/blob/main/assets/Logo.jpeg) <!-- Replace with your actual logo -->

A Flutter-based attendance system that uses QR codes for student check-ins, with an admin portal for generating attendance sessions.

## Features

- **Student Portal**: QR attendance submission
- **Admin Portal**: Session management
- **Google Sheets Backend**: Real-time data logging
- **ESP8266 Integration**: Physical QR display

## Google Apps Script Setup

### 1. Create a New Script
1. Go to [script.google.com](https://script.google.com)
2. Create a new project 

### 2. Complete Script Code
Replace the default code with:

```javascript
const SHEET_ID = "YOUR_GOOGLE_SHEET_ID";
const SHEET_NAME = "Attendance";
```javascript

- **Student Portal**:
  - QR code scanning for attendance
  - Student ID verification
  - Real-time attendance submission

- **Admin Portal**:
  - Secure login system
  - QR code generation for classes
  - ESP8266 integration for physical QR display
  - Session management with countdown timer

- **Technical**:
  - Google Apps Script backend
  - ESP8266 WiFi integration
  - Responsive Flutter UI

## Screenshots

| Role Selection | Student Portal | Admin Login |
|----------------|----------------|-------------|
| ![Role Selection](https://github.com/vishPratik/AttendaceSystem/blob/main/assets/Main%20Page.jpeg) | ![Student Portal](https://github.com/vishPratik/AttendaceSystem/blob/main/assets/Student%20Dashboard.jpeg) | ![Admin Login](https://github.com/vishPratik/AttendaceSystem/blob/main/assets/Admin%20Login.jpeg) |

| Admin Dashboard | QR Scanner | QR Generation |
|-----------------|------------|---------------|
| ![Admin Dashboard](https://github.com/vishPratik/AttendaceSystem/blob/main/assets/Admin%20Dashboard.jpeg) | ![QR Scanner](https://github.com/vishPratik/AttendaceSystem/blob/main/assets/QR_SCAN.jpeg) | ![QR Generation](https://github.com/vishPratik/AttendaceSystem/blob/main/assets/QR.jpeg) |

| Attendance | Dashboard | 
|------------|-----------|
| ![Attendance](https://github.com/vishPratik/AttendaceSystem/blob/main/assets/Attendance%20log.png) | ![Dashboard](https://github.com/vishPratik/AttendaceSystem/blob/main/assets/Attendance%20Dashboard.png) |

## Installation

### Prerequisites
- Flutter SDK (v3.0.0 or higher)
- Dart (v2.17.0 or higher)
- ESP8266 with compatible firmware (for QR display)

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/markme-attendance.git
   cd markme-attendance
