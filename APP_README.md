# Check Writer Web Application

A modern web application for generating professional checks in PDF format. Built with React frontend and Sinatra backend.

## Features

- Interactive form for filling out check information
- Real-time PDF generation
- Preview generated checks in the browser
- Download checks as PDF files
- Clean, responsive UI design

## Prerequisites

- Ruby (1.9.3 or higher)
- Node.js (14 or higher)
- npm or yarn

## Installation

### 1. Install Ruby Dependencies

```bash
bundle install
```

### 2. Install JavaScript Dependencies

```bash
cd frontend
npm install
cd ..
```

## Running the Application

### Development Mode

You need to run both the backend and frontend servers:

**Terminal 1 - Backend (Sinatra):**
```bash
ruby server.rb
```
The backend will run on http://localhost:4567

**Terminal 2 - Frontend (React):**
```bash
cd frontend
npm run dev
```
The frontend will run on http://localhost:3000

Now visit http://localhost:3000 in your browser.

### Production Mode

Build the frontend and run everything from the Sinatra server:

```bash
# Build the React app
cd frontend
npm run build
cd ..

# Run the Sinatra server
ruby server.rb
```

Now visit http://localhost:4567 in your browser.

## API Endpoints

### POST /api/generate-check

Generate a check PDF from the provided data.

**Request Body:**
```json
{
  "number": "12345",
  "date": "2025-10-21",
  "payee_name": "John Smith",
  "payee_address": "123 Main St\nCity, State, Zip",
  "payor_name": "Payor Name",
  "payor_address": "456 Company Ave\nCity, State, Zip",
  "bank_name": "Bank of America",
  "bank_address": "789 Bank St\nCity, State, Zip",
  "bank_fraction": "12-9876/1234",
  "routing_number": "123456789",
  "account_number": "123456789",
  "amount": "1003.23",
  "memo": "Memo: Void after 60 days"
}
```

**Response:**
```json
{
  "success": true,
  "pdf": "base64-encoded-pdf-data",
  "message": "Check generated successfully"
}
```

### GET /api/health

Check if the API is running.

**Response:**
```json
{
  "status": "ok",
  "message": "Check Writer API is running"
}
```

## Project Structure

```
check_writer/
├── frontend/               # React frontend
│   ├── src/
│   │   ├── App.jsx        # Main React component
│   │   ├── App.css        # Styles
│   │   └── main.jsx       # Entry point
│   ├── index.html         # HTML template
│   ├── package.json       # Node dependencies
│   └── vite.config.js     # Vite configuration
├── lib/                   # Check writer library
│   └── check_writer/
│       ├── check.rb       # Check generation logic
│       └── attribute_formatting.rb
├── server.rb              # Sinatra API server
├── Gemfile                # Ruby dependencies
└── APP_README.md          # This file
```

## Usage

1. Open the application in your browser
2. Fill out all required fields (marked with *)
3. Click "Generate Check" to create the PDF
4. Preview the check in the browser
5. Click "Download PDF" to save the check to your computer

## Required Fields

- Check Number
- Date
- Amount
- Payee Name
- Payor Name
- Bank Name
- Routing Number (9 digits)
- Account Number

## Notes

- This uses the GnuMICR font for printing MICR numbers at the bottom of checks
- For actual check printing, use check stock paper with magnetic ink
- See the main README.rdoc for more information about the check_writer gem

## Troubleshooting

### Port Already in Use

If you see "Address already in use" errors:

**For Sinatra (port 4567):**
```bash
lsof -ti:4567 | xargs kill -9
```

**For React (port 3000):**
```bash
lsof -ti:3000 | xargs kill -9
```

### Bundle Install Errors

Make sure you have all system dependencies installed. On Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install ruby-dev build-essential
```

### NPM Install Errors

Try clearing the npm cache:
```bash
cd frontend
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
```

## License

See LICENSE.txt in the root directory.
