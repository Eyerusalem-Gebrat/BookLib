# BookLib 📚

BookLib is a book management application that helps users organize their reading lists and track their reading progress through a web application and a Flutter mobile app.

## Features

- User registration, login, and email verification
- Add, view, edit, and delete books
- Organize books by reading status
- Track reading progress by pages
- Upload book cover images
- Access the same books through the web and mobile app
- Secure mobile API authentication using Laravel Passport
- Password recovery
- Admin dashboard with user request statistics

## Technologies Used

- **Backend:** Laravel 13, PHP
- **Frontend:** React, TypeScript, Inertia.js
- **Database:** MySQL
- **Mobile:** Flutter, Dart
- **Authentication:** Laravel Passport
- **Build Tool:** Vite

## Project Structure

```text
BookLib/
├── src/           # Laravel backend and web application
├── booklib_app/   # Flutter mobile application
└── README.md
```

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/Eyerusalem-Gebrat/BookLib.git
cd BookLib/src
```

### 2. Set up Laravel

```bash
composer install
npm install
```

Copy `.env.example` to `.env`, configure your MySQL database and mail settings, then run:

```bash
php artisan key:generate
php artisan migrate
php artisan storage:link
```

Configure Passport and the administrator account if they have not already been set up.

### 3. Run the web application

Run these commands in separate terminals from the `src` directory:

```bash
php artisan serve
```

```bash
npm run dev
```

### 4. Run the mobile application

From the repository root:

```bash
cd booklib_app
flutter pub get
flutter run
```

Configure the mobile app's API base URL to point to your Laravel server.

### Administrator Account Setup

The administrator account is created using a Laravel seeder.

1. Add the administrator credentials to your `src/.env` file:

```env
BOOKLIB_ADMIN_EMAIL=admin@gmail.com
BOOKLIB_ADMIN_PASSWORD="YourStrongPassword"
```

Replace the example email and password with your own credentials.

2. Run the database migrations from the `src` directory:

```bash
php artisan migrate
```

3. Run the administrator seeder:

```bash
php artisan db:seed --class=AdminSeeder
```

4. Sign in to the web application using the administrator credentials. The administrator can access the admin dashboard to view user and request statistics.

**Note:** Keep the administrator password private. The seeder assigns administrator privileges to the account matching `BOOKLIB_ADMIN_EMAIL` and creates or updates that account's credentials.

## API

The API supports mobile login, password recovery, and book management. Protected endpoints require a valid Passport access token.

Main endpoints include:

- `POST /api/login`
- `POST /api/forgot-password`
- `POST /api/reset-password`
- `GET /api/books`
- `POST /api/books`
- `GET /api/books/{book}`
- `PUT/PATCH /api/books/{book}`
- `DELETE /api/books/{book}`

## Testing

Laravel:

```bash
php artisan test
```

Flutter:

```bash
flutter test
flutter analyze
```
