# BookLib

BookLib is a personal book management web application that helps users organize their reading lists and track their reading progress.

## Features

* Add, edit, and delete books.
* Organize books by reading status.
* Track reading progress by pages.
* Upload book cover images.
* User authentication and email verification.

## Tech Stack

* Laravel 13
* React and TypeScript
* Inertia.js
* MySQL
* Vite

## Getting Started

Clone the repository:

```bash
git clone https://github.com/YOUR-USERNAME/BookLib.git
cd BookLib
```

Install dependencies:

```bash
composer install
npm install
```

Configure your `.env` file and database, then run:

```bash
php artisan key:generate
php artisan migrate
php artisan storage:link
```

Start the development servers in separate terminals:

```bash
php artisan serve
```

```bash
npm run dev
```

## Project Goal

BookLib is a full-stack web development project focused on building practical skills with Laravel, React, database management, and authentication.
